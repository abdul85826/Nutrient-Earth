import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import 'models/body_state.dart';
import 'providers/body_controller.dart';
import 'widgets/body_scene.dart';
import 'navigation/body_navigator.dart';

// ─── AG-13: BodyPage converted to ConsumerStatefulWidget ─────────────────────
// Adds: searchable organ list, Levenshtein fuzzy matching, suggestion overlay,
// organ working animation in detail view.

class BodyPage extends ConsumerStatefulWidget {
  const BodyPage({super.key});

  @override
  ConsumerState<BodyPage> createState() => _BodyPageState();
}

class _BodyPageState extends ConsumerState<BodyPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showSuggestions = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── AG-13: Levenshtein distance (pure Dart, no package needed) ──────────────
  static int _levenshtein(String a, String b) {
    final al = a.toLowerCase();
    final bl = b.toLowerCase();
    if (al == bl) return 0;
    if (al.isEmpty) return bl.length;
    if (bl.isEmpty) return al.length;

    final prev = List<int>.generate(bl.length + 1, (i) => i);
    final curr = List<int>.filled(bl.length + 1, 0);

    for (int i = 1; i <= al.length; i++) {
      curr[0] = i;
      for (int j = 1; j <= bl.length; j++) {
        final cost = al[i - 1] == bl[j - 1] ? 0 : 1;
        curr[j] = [curr[j - 1] + 1, prev[j] + 1, prev[j - 1] + cost]
            .reduce((a, b) => a < b ? a : b);
      }
      for (int j = 0; j <= bl.length; j++) { prev[j] = curr[j]; }
    }
    return prev[bl.length];
  }

  /// Rank and filter systems by query. Prefix matches come first,
  /// then small edit-distance matches (<= threshold). Capped at 5.
  List<BodySystem> _fuzzySearch(List<BodySystem> systems, String query) {
    if (query.isEmpty) return [];
    final q = query.toLowerCase().trim();
    const threshold = 3; // max edit distance to still suggest

    final prefixMatches = <BodySystem>[];
    final editMatches = <MapEntry<int, BodySystem>>[];

    for (final sys in systems) {
      final name = sys.name.toLowerCase();
      if (name.startsWith(q)) {
        prefixMatches.add(sys);
      } else {
        final dist = _levenshtein(q, name.substring(0, name.length.clamp(0, q.length + 2)));
        if (dist <= threshold) {
          editMatches.add(MapEntry(dist, sys));
        }
      }
    }

    editMatches.sort((a, b) => a.key.compareTo(b.key));
    final results = [
      ...prefixMatches,
      ...editMatches.map((e) => e.value),
    ];
    return results.toSet().toList().take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bodyState = ref.watch(bodyControllerProvider);

    return Scaffold(
      backgroundColor: NEColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Your Body', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      body: _buildBodyContent(context, ref, bodyState),
    );
  }

  Widget _buildBodyContent(BuildContext context, WidgetRef ref, BodyState state) {
    switch (state) {
      case BodyLoading():
        return const Center(
          child: CircularProgressIndicator(color: NEColors.accent),
        );
      case BodyEmpty():
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.query_stats, color: Colors.white24, size: 64),
                SizedBox(height: 16),
                Text(
                  'No systems state available',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Complete daily check-ins to build baseline metrics.',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      case BodyUnavailable(:final message):
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.settings_applications, color: Colors.amber, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Body Module Unavailable',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(color: Colors.white30, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      case BodyError(:final message):
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load body systems',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(color: Colors.white30, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      case BodyReady(:final systems, :final selectedSystemKey):
        return _buildReadyDashboard(context, ref, systems, selectedSystemKey);
    }
  }

  Widget _buildReadyDashboard(
    BuildContext context,
    WidgetRef ref,
    List<BodySystem> systems,
    String? selectedSystemKey,
  ) {
    final controller = ref.read(bodyControllerProvider.notifier);
    final suggestions = _fuzzySearch(systems, _searchQuery);

    final selectedSystem = selectedSystemKey != null
        ? systems.where((sys) => sys.key == selectedSystemKey).firstOrNull
        : null;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            // ── AG-13: Search bar ──────────────────────────────────────────
            _buildSearchBar(),
            const SizedBox(height: 16),

            // AG-14: Interactive Jarvis-style 3D body model
            SizedBox(
              height: 440,
              child: BodyScene(
                selectedSystemKey: selectedSystemKey,
                interactive: true,
                onSystemSelected: (key) {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                    _showSuggestions = false;
                  });
                  controller.selectSystem(key);
                  final sys = systems.where((s) => s.key == key).firstOrNull;
                  final displayName = sys?.name ?? key.toUpperCase();
                  BodyNavigator.showOrganDetail(context, key, displayName);
                },
              ),
            ),
            const SizedBox(height: 24),

            // System Detail Card OR Systems List
            if (selectedSystem != null) ...[
              _buildSystemDetailCard(context, selectedSystem, () => controller.clearSelection()),
            ] else ...[
              const Text(
                'Biological Overview',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Select a system node on the figure above, or search below.',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 16),
              ...systems.map((sys) => _buildSystemSummaryPill(context, sys, () {
                setState(() {
                  _searchQuery = '';
                  _searchController.clear();
                  _showSuggestions = false;
                });
                controller.selectSystem(sys.key);
                BodyNavigator.showOrganDetail(context, sys.key, sys.name);
              })),
            ],
            const SizedBox(height: 24),
            _buildWearablesDisclaimer(context),
          ],
        ),

        // ── AG-13: Fuzzy suggestion overlay ───────────────────────────────
        if (_showSuggestions && suggestions.isNotEmpty)
          Positioned(
            top: 62, // just below the search bar
            left: 24,
            right: 24,
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: NEColors.surfaceLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: suggestions.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final sys = entry.value;
                    return InkWell(
                      onTap: () {
                        // AG-13: selecting via search → identical result to tapping model
                        setState(() {
                          _searchQuery = '';
                          _searchController.clear();
                          _showSuggestions = false;
                        });
                        final controller = ref.read(bodyControllerProvider.notifier);
                        controller.selectSystem(sys.key);
                        BodyNavigator.showOrganDetail(context, sys.key, sys.name);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: idx < suggestions.length - 1
                              ? const Border(bottom: BorderSide(color: Colors.white10, width: 0.5))
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(sys.icon, color: NEColors.accent, size: 18),
                            const SizedBox(width: 12),
                            Text(
                              sys.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.north_west_rounded, color: Colors.white24, size: 14),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── AG-13: Search bar ──────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      onChanged: (val) {
        setState(() {
          _searchQuery = val;
          _showSuggestions = val.isNotEmpty;
        });
      },
      onTap: () {
        if (_searchQuery.isNotEmpty) {
          setState(() => _showSuggestions = true);
        }
      },
      decoration: InputDecoration(
        hintText: 'Search an organ (try "hrt" or "livr")',
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
        prefixIcon: const Icon(Icons.search_rounded, color: Colors.white38, size: 20),
        suffixIcon: _searchQuery.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                    _showSuggestions = false;
                  });
                },
                child: const Icon(Icons.close_rounded, color: Colors.white38, size: 18),
              )
            : null,
        filled: true,
        fillColor: NEColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  // ── AG-13: Organ detail card with generic animation + personal data ─────────
  Widget _buildSystemDetailCard(BuildContext context, BodySystem system, VoidCallback onClose) {
    final percentage = (system.score * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NEColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(system.icon, color: NEColors.accent, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    system.name,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white30, size: 20),
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── AG-13 SECTION 1: Generic illustrative animation ──────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: NEColors.background.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.animation_rounded, color: Colors.white38, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Illustrative — not a real-time scan of your organ',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: SizedBox(
                    height: 100,
                    child: _OrganAnimation(systemKey: system.key),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── AG-13 SECTION 2: User's personal score + data ───────────────
          const Text(
            'Your Personal Data',
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            system.description,
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 16),

          if (system.score == 0) ...[
            // Empty state: no data yet
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.hourglass_empty_rounded, color: Colors.white24, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Not enough data yet — complete daily check-ins',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('System Score', style: TextStyle(color: Colors.white54, fontSize: 12)),
                Text('$percentage%', style: const TextStyle(color: NEColors.accent, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: system.score,
                backgroundColor: Colors.white10,
                color: NEColors.accent,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 20),
            const Text('Tracked Metrics', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...system.metrics.map(
              (metric) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.circle, color: NEColors.accent, size: 6),
                    const SizedBox(width: 8),
                    Text(metric, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Clinical Recommendations', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...system.recommendations.map(
              (rec) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline, color: NEColors.accent, size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rec,
                        style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSystemSummaryPill(BuildContext context, BodySystem system, VoidCallback onTap) {
    final percentage = (system.score * 100).toInt();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: NEColors.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(system.icon, color: NEColors.accent, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    system.name,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: system.score,
                      backgroundColor: Colors.white10,
                      color: NEColors.accent,
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$percentage%',
              style: const TextStyle(color: NEColors.accent, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWearablesDisclaimer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Disclaimer & Context', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(
            'System scores are derived from subjective, self-reported daily check-ins. '
            'Connect wearable hardware sensors to obtain objective physiology data.',
            style: TextStyle(color: Colors.white38, fontSize: 11, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ─── AG-13: Generic organ working animation ───────────────────────────────────
//
// Shows a looping illustrative animation per organ type.
// Clearly labeled as illustrative, not a real-time physiological scan.

class _OrganAnimation extends StatefulWidget {
  final String systemKey;
  const _OrganAnimation({required this.systemKey});

  @override
  State<_OrganAnimation> createState() => _OrganAnimationState();
}

class _OrganAnimationState extends State<_OrganAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _anim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => CustomPaint(
        painter: _OrganPainter(
          systemKey: widget.systemKey,
          progress: _anim.value,
        ),
        size: const Size(double.infinity, 100),
      ),
    );
  }
}

class _OrganPainter extends CustomPainter {
  final String systemKey;
  final double progress; // 0.0 → 1.0

  _OrganPainter({required this.systemKey, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    switch (systemKey) {
      case 'cardiovascular':
        // Beating heart: pulsing red circle
        final r = 18 + progress * 10;
        final paint = Paint()
          ..color = const Color(0xFFEF5350).withValues(alpha: 0.8)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(Offset(cx, cy), r, paint);
        canvas.drawCircle(
          Offset(cx, cy),
          r * 0.55,
          Paint()..color = const Color(0xFFEF5350),
        );
        break;

      case 'respiratory':
        // Inflating/deflating lungs: two ovals expanding
        final scaleX = 0.7 + progress * 0.6;
        final scaleY = 0.8 + progress * 0.4;
        final lPaint = Paint()
          ..color = const Color(0xFF4DD0E1).withValues(alpha: 0.7)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx - 20, cy), width: 32 * scaleX, height: 52 * scaleY),
          lPaint,
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx + 20, cy), width: 32 * scaleX, height: 52 * scaleY),
          lPaint,
        );
        break;

      case 'nervous':
        // Radial neural pulse
        for (int i = 1; i <= 3; i++) {
          final r = (i * 16).toDouble() + progress * 10;
          final alpha = ((1.0 - progress) * 0.6 / i);
          canvas.drawCircle(
            Offset(cx, cy),
            r,
            Paint()
              ..color = const Color(0xFFCE93D8).withValues(alpha: alpha)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5,
          );
        }
        canvas.drawCircle(
          Offset(cx, cy),
          6,
          Paint()..color = const Color(0xFFCE93D8),
        );
        break;

      case 'digestive':
        // Peristaltic shimmer: waving line
        final path = Path();
        path.moveTo(cx - 40, cy);
        for (double x = -40; x <= 40; x += 4) {
          final y = cy + 12 * sin((x / 20 + progress * 2) * 3.14159);
          path.lineTo(cx + x, y);
        }
        canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0xFFFFB300).withValues(alpha: 0.8)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round,
        );
        break;

      default:
        // Musculoskeletal: contracting/expanding bar
        final barW = 24 + progress * 20;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(cx, cy), width: barW, height: 14),
            const Radius.circular(7),
          ),
          Paint()..color = const Color(0xFF69F0AE).withValues(alpha: 0.8),
        );
    }
  }

  // Use dart:math sin directly (imported at top of file as 'math')
  double sin(double x) => math.sin(x);

  @override
  bool shouldRepaint(covariant _OrganPainter old) =>
      old.progress != progress || old.systemKey != systemKey;
}
