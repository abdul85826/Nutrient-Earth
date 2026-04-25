import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/ai_service.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import './widgets/runway_stepper.dart';
import './widgets/success_stories_carousel.dart';
import 'dart:ui';
import '../../engine/health_engine.dart';

final aiServiceProvider = Provider((ref) => AIService());

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen>
    with TickerProviderStateMixin {
  bool _hasData = false;
  final TextEditingController _inputController = TextEditingController();
  final Set<String> _selectedTags = {};

  HealthState? _healthState;

  final List<String> _quickTags = [
    "tired",
    "heavy",
    "stressed",
    "fresh",
    "burning",
    "dry",
  ];

  late AnimationController _orbController;
  late AnimationController _entryController;
  late AnimationController _backgroundController;

  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(_entryController);

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _entryController.forward();

    _loadSavedState();
    _loadInitialData();
  }

  Future<void> _loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    final lastText = prefs.getString('last_input_text') ?? "";
    final lastTags = prefs.getStringList('last_tags') ?? [];
    final hasData = prefs.getBool('has_data') ?? false;

    if (hasData) {
      setState(() {
        _inputController.text = lastText;
        _selectedTags.addAll(lastTags);
        _healthState = HealthEngine.interpret(
          text: lastText,
          tags: lastTags,
        );
        _hasData = true;
      });
    }
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_input_text', _inputController.text);
    await prefs.setStringList('last_tags', _selectedTags.toList());
    await prefs.setBool('has_data', _hasData);
  }

  void _interpretInput() {
    if (_inputController.text.isEmpty && _selectedTags.isEmpty) return;

    final newState = HealthEngine.interpret(
      text: _inputController.text,
      tags: _selectedTags.toList(),
    );

    setState(() {
      _healthState = newState;
      _hasData = true;
    });

    // Inject dynamic tasks into Runway
    ref.read(actionProvider.notifier).updateSteps(newState.recommendedTasks);

    _saveState();
  }

  Future<void> _loadInitialData() async {
    final ai = ref.read(aiServiceProvider);

    await ai.getDayInsight(
      condition: "Sugar Sensitivity",
      goal: "Organ Recovery",
      language: "en",
    );

    bool missedDay = false;

    try {
      final streakData = await Supabase.instance.client
          .from('streaks')
          .select('last_active_date')
          .limit(1)
          .maybeSingle();

      if (streakData != null) {
        final lastActive =
            DateTime.parse(streakData['last_active_date'].toString());
        final today = DateTime.now();
        final diff = today.difference(lastActive).inDays;

        if (diff > 1) {
          missedDay = true;
        }
      }
    } catch (_) {
      missedDay = true;
    }

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(missedDay
                ? 'Your body resets every day. Let\'s continue recovery.\n⚠️ Missing yesterday slowed progress.'
                : 'Your body resets every day. Let\'s continue recovery.'),
            backgroundColor: AppColors.surface,
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _orbController.dispose();
    _entryController.dispose();
    _backgroundController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProgressProvider);
    final isComplete = userProfile.isComplete;

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(),
                      const SizedBox(height: 24),
                      _buildMissionHook(isComplete),
                      const SizedBox(height: 28),
                      
                      // Progress Lock Gating
                      if (isComplete)
                        (_hasData && _healthState != null)
                            ? _buildLiveStateCard()
                            : _buildEmptyStateGuidance()
                      else
                        _buildLockedEnginePreview(userProfile.completionPercentage),

                      const SizedBox(height: 28),
                      _buildEnvironmentalStrip(),
                      const SizedBox(height: 28),
                      _buildNaturalInputSection(),
                      const SizedBox(height: 32),
                      const RunwayStepper(),
                      const SizedBox(height: 32),

                      Text(
                        'PROOFS OF CONTROL',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 16),

                      const SuccessStoriesCarousel(),
                      const SizedBox(height: 48),

                      Center(child: _buildAssistantOrb()),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Arjun,',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Biological recovery is active.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        Container(
          width: 48,
          height: 48,
          decoration: AppTheme.glassStyle(opacity: 0.1, borderRadius: 16),
          child: const Icon(Icons.notifications_none, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildEnvironmentalStrip() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassStyle(opacity: 0.03),
      child: Row(
        children: [
          _buildEnvItem(Icons.air, 'AQI 42', 'GOOD', Colors.greenAccent),
          _buildVerticalDivider(),
          _buildEnvItem(Icons.thermostat, '28°C', 'OPTIMAL', AppColors.nutrientGreen),
          _buildVerticalDivider(),
          _buildEnvItem(Icons.water_drop_outlined, '65%', 'HUMID', Colors.blueAccent),
        ],
      ),
    );
  }

  Widget _buildEnvItem(IconData icon, String value, String status, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 2),
          Text(status, style: TextStyle(color: color.withValues(alpha: 0.6), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: AppColors.glassBorder,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildLockedEnginePreview(double progress) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: AppTheme.glassStyle(),
      child: Stack(
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Opacity(
              opacity: 0.2,
              child: _buildDemoStateContent(),
            ),
          ),
          Positioned.fill(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.nutrientGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.nutrientGreen.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      "${(progress * 100).toInt()}% COMPLETE",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "UNLOCK BIOLOGICAL ENGINE",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Finish your profile to see your real-time body state.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go('/body'),
                      child: const Text("COMPLETE PROFILE"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoStateContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Hydration: NORMAL", style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 12),
          Text("Biological recovery active. Cellular resonance is stabilizing.", style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          const Text("• Drink structured water", style: TextStyle(color: AppColors.nutrientGreen)),
          const Text("• Morning light exposure", style: TextStyle(color: AppColors.nutrientGreen)),
        ],
      ),
    );
  }

  Widget _buildEmptyStateGuidance() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: AppTheme.glassStyle(),
      child: Column(
        children: [
          const Icon(Icons.bubble_chart_outlined, color: AppColors.nutrientGreen, size: 48),
          const SizedBox(height: 20),
          const Text(
            "Sync with your body",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            "How are you feeling right now? Your input drives the biological engine.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStateCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: AppTheme.glassStyle(opacity: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.nutrientGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.nutrientGreen.withValues(alpha: 0.2)),
                ),
                child: Text(
                  "HYDRATION: ${_healthState?.hydration}",
                  style: const TextStyle(color: AppColors.nutrientGreen, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.glassBorder),
                ),
                child: Text(
                  "ENERGY: ${_healthState?.energy}",
                  style: const TextStyle(color: Colors.blueAccent, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
              const Spacer(),
              const Icon(Icons.analytics_outlined, color: Colors.white24, size: 20),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            _healthState?.reason ?? '',
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5, height: 1.2),
          ),
          const SizedBox(height: 20),
          _buildInsightRow(Icons.psychology_outlined, 'METABOLIC WHY', _healthState?.metabolicWhy ?? ''),
          const SizedBox(height: 16),
          _buildInsightRow(Icons.warning_amber_rounded, 'BIOLOGICAL IMPACT', _healthState?.biologicalImpact ?? ''),
          const SizedBox(height: 32),
          const Divider(color: AppTheme.glassBorder),
          const SizedBox(height: 24),
          ...?_healthState?.actions.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.nutrientGreen.withValues(alpha: 0.1)),
                      child: const Icon(Icons.bolt_rounded, color: AppColors.nutrientGreen, size: 14),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        a,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildInsightRow(IconData icon, String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.nutrientGreen.withValues(alpha: 0.5), size: 14),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13, height: 1.4),
        ),
      ],
    );
  }

  void _showAssistantSummary() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          border: Border.all(color: AppTheme.glassBorder),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 100, spreadRadius: 20),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                const Text('NE ASSISTANT PROTOCOL', style: TextStyle(color: AppColors.nutrientGreen, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 10)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white24),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              _healthState?.reason ?? 'System analysis complete.',
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.2),
            ),
            const SizedBox(height: 32),
            _buildSheetInsight('METABOLIC REASONING', _healthState?.metabolicWhy ?? ''),
            const SizedBox(height: 24),
            _buildSheetInsight('EXPECTED IMPACT', _healthState?.biologicalImpact ?? ''),
            const SizedBox(height: 40),
            const Text('REQUIRED ACTIONS', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 10)),
            const SizedBox(height: 20),
            ...?_healthState?.actions.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                children: [
                  const Icon(Icons.add_circle_outline_rounded, color: AppColors.nutrientGreen, size: 20),
                  const SizedBox(width: 16),
                  Expanded(child: Text(a, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600))),
                ],
              ),
            )),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/explore');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.nutrientGreen,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('DEPLOY PROTOCOL', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetInsight(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.nutrientGreen, fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 9)),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 15, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildBackground() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, _) {
        final value = _backgroundController.value;
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.4 - value * 0.3, -0.7),
              radius: 1.5,
              colors: [
                const Color(0xFF143026),
                const Color(0xFF0A1F16),
                AppColors.background,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMissionHook(bool isComplete) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassStyle(opacity: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '7-DAY REVERSAL MISSION',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Text(
                "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",
                style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            isComplete 
              ? 'Biological engine active.' 
              : 'Complete your profile.',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            isComplete 
              ? 'Your metrics are being processed in real-time.' 
              : 'We need more data to interpret your body accurately.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (!isComplete) ...[
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: ref.watch(userProgressProvider).completionPercentage,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation(AppColors.nutrientGreen),
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNaturalInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "HOW DO YOU FEEL TODAY?",
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _inputController,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: const InputDecoration(
            hintText: "E.g. I feel a bit dry and low on energy...",
          ),
          onSubmitted: (_) => _interpretInput(),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _quickTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedTags.remove(tag);
                  } else {
                    _selectedTags.add(tag);
                  }
                });
                _interpretInput();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.nutrientGreen
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.nutrientGreen
                        : AppColors.glassBorder,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(color: AppColors.nutrientGreen.withValues(alpha: 0.3), blurRadius: 10, spreadRadius: 1)
                  ] : [],
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAssistantOrb() {
    final hasWarning = _healthState?.hydration == "LOW" || _healthState?.energy == "LOW";
    
    return AnimatedBuilder(
      animation: _orbController,
      builder: (context, _) {
        final scale = 1 + (_orbController.value * 0.1);
        final glow = _orbController.value * 30;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Glow effect
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (hasWarning ? Colors.orangeAccent : AppColors.nutrientGreen)
                        .withValues(alpha: 0.2 + (_orbController.value * 0.1)),
                    blurRadius: 50 + glow,
                    spreadRadius: 10 + glow,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                if (_healthState != null) {
                  _showAssistantSummary();
                } else {
                  _interpretInput();
                }
              },
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        hasWarning ? Colors.orangeAccent : AppColors.nutrientGreen,
                        hasWarning ? Colors.deepOrange : const Color(0xFF8CEE4B),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 2)
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'NE',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 22, letterSpacing: 3),
                    ),
                  ),
                ),
              ),
            ),
            if (_healthState != null)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: hasWarning ? Colors.orangeAccent : AppColors.nutrientGreen,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Text(
                    hasWarning ? 'ACTION' : 'GOOD',
                    style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}