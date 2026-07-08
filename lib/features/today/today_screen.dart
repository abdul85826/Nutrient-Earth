import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/graph_provider.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/baseline_engine.dart';
import '../../core/providers/engine_providers.dart';
import '../../core/models/app_models.dart';

import '../../shared/widgets/traceability_bottom_sheet.dart';
import '../body/widgets/body_scene.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  // AG-12: profile nudge is dismissible per session
  bool _nudgeDismissed = false;

  @override
  void initState() {
    super.initState();
    // Trigger graph execution on mount if empty just to refresh context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(graphStateProvider).value == null) {
        ref.read(graphStateProvider.notifier).runGraph();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final baselineStateAsync = ref.watch(baselineStateProvider);

    return Scaffold(
      backgroundColor: NEColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Today', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () => ref.read(graphStateProvider.notifier).runGraph(),
          ),
        ],
      ),
      body: baselineStateAsync.when(
        data: (state) => _buildDashboard(state),
        loading: () => const Center(child: CircularProgressIndicator(color: NEColors.accent)),
        error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent))),
      ),
    );
  }

  Widget _buildDashboard(BaselineState state) {
    final appUser = ref.watch(appUserProvider).value;
    String name = 'You';
    if (appUser != null && appUser.fullName != null && appUser.fullName!.trim().isNotEmpty) {
      name = appUser.fullName!.trim().split(' ').first;
    } else if (appUser != null && appUser.email.isNotEmpty && appUser.email != 'guest@nutrientearth.local') {
      final prefix = appUser.email.split('@').first;
      if (prefix.isNotEmpty) name = prefix;
    }

    // AG-12: show profile nudge if profile is incomplete and not dismissed
    final showNudge = !_nudgeDismissed &&
        (appUser == null || !appUser.profileCompleted || (appUser.onboardingStep < 3));

    final actionState = ref.watch(actionProvider);
    final timelineAsync = ref.watch(observationTimelineProvider);
    final insightsAsync = ref.watch(recentInsightsProvider);
    final envState = ref.watch(environmentProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(graphStateProvider.notifier).runGraph();
        ref.read(environmentProvider.notifier).refresh();
      },
      child: timelineAsync.when(
        data: (timeline) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // ── AG-12: Greeting (time-of-day + name) ────────────────────
              _buildTodayHeader(name),
              const SizedBox(height: 12),

              // ── AG-12: Profile completion nudge (dismissible) ────────────
              if (showNudge) ...[
                _buildProfileNudge(),
                const SizedBox(height: 16),
              ],

              // ── AG-12: Live environment card (AQI / humidity / temp) ─────
              _buildEnvironmentCard(envState),
              const SizedBox(height: 16),

              // ── AG-12: Body snapshot + Coach AI sentence ─────────────────
              insightsAsync.when(
                data: (insights) => _buildBodySnapshot(insights),
                loading: () => _buildBodySnapshot([]),
                error: (_, __) => _buildBodySnapshot([]),
              ),
              const SizedBox(height: 24),

              // ── Existing content below (unchanged) ───────────────────────
              _buildDailyCheckInCard(timeline),
              const SizedBox(height: 24),

              insightsAsync.when(
                data: (insights) => _buildInsightsFeed(insights),
                loading: () => const Center(child: CircularProgressIndicator(color: NEColors.accent)),
                error: (err, _) => Center(child: Text('Error loading insights: $err', style: const TextStyle(color: Colors.redAccent))),
              ),
              const SizedBox(height: 24),

              _buildDailyMissions(actionState),
              const SizedBox(height: 24),

              insightsAsync.when(
                data: (insights) => _buildWhatWeDontKnowYet(insights),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 80),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: NEColors.accent)),
        error: (err, _) => Center(child: Text('Error loading timeline: $err', style: const TextStyle(color: Colors.redAccent))),
      ),
    );
  }

  // ── AG-12: Dynamic time-of-day greeting ────────────────────────────────────
  Widget _buildTodayHeader(String name) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, $name',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _todayDateLabel(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.38),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  String _todayDateLabel() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  // ── AG-12: Profile nudge card ────────────────────────────────────────────────
  Widget _buildProfileNudge() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(
        color: NEColors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NEColors.accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_add_alt_1_rounded, color: NEColors.accent, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Complete your profile to unlock personalised insights',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _nudgeDismissed = true),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close_rounded, color: Colors.white38, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  // ── AG-12: Live environment card ─────────────────────────────────────────────
  Widget _buildEnvironmentCard(EnvironmentState env) {
    // Detect location-declined state: still loading + default placeholder AQI
    final locationDeclined = env.isLoading && env.city == 'Detecting Location...';
    final isPlaceholder = env.aqi.aqi == 42 && env.city == 'Detecting Location...';

    if (isPlaceholder && !env.isLoading) {
      // Location permission declined or unavailable — calm prompt
      return _buildEnvLocationPrompt();
    }

    // Format timestamp
    final now = env.lastUpdated;
    final hour = now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final ampm = hour >= 12 ? 'PM' : 'AM';
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    final timeLabel = 'as of $h12:$minute $ampm';

    final aqiColor = _aqiColor(env.aqi.aqi);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NEColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          // Animated weather icon
          _WeatherIcon(description: env.weather.description, isLoading: locationDeclined),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: aqiColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'AQI ${env.aqi.aqi} · ${env.aqi.status}',
                        style: TextStyle(
                          color: aqiColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _EnvStat(label: 'Temp', value: '${env.weather.temp.round()}°'),
                    const SizedBox(width: 16),
                    _EnvStat(label: 'Humidity', value: '${env.weather.humidity}%'),
                  ],
                ),
              ],
            ),
          ),
          // Timestamp
          Text(
            timeLabel,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.28),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvLocationPrompt() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NEColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: const Row(
        children: [
          Icon(Icons.location_off_outlined, color: Colors.white38, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Enable location for local air quality data',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Color _aqiColor(int aqi) {
    if (aqi <= 50) return const Color(0xFF69F0AE);  // Good — green
    if (aqi <= 100) return const Color(0xFFFFEB3B); // Moderate — yellow
    if (aqi <= 150) return const Color(0xFFFF9800); // Sensitive — orange
    return const Color(0xFFEF5350);                 // Unhealthy+
  }

  // ── AG-12: Body snapshot + Coach AI sentence ─────────────────────────────────
  Widget _buildBodySnapshot(List<Map<String, dynamic>> insights) {
    // Derive a one-sentence Coach AI summary from top insight
    String coachSentence;
    if (insights.isEmpty) {
      coachSentence = 'Building your biological profile — check back after your first check-in.';
    } else {
      final top = insights.first;
      coachSentence = (top['message'] as String? ?? '').isNotEmpty
          ? top['message'] as String
          : 'Your biological systems are being monitored. Complete your daily check-in for insights.';
      // Trim to one sentence for brevity on the Today tab
      final firstPeriod = coachSentence.indexOf('.');
      if (firstPeriod > 0 && firstPeriod < coachSentence.length - 1) {
        coachSentence = coachSentence.substring(0, firstPeriod + 1);
      }
    }

    return GestureDetector(
      // Tapping navigates to Body tab (index 1) via GoRouter
      onTap: () {
        // Navigate to Body tab — use the router to push /body if available
        final navigator = Navigator.of(context, rootNavigator: false);
        // If using GoRouter shell, goBranch is not accessible here;
        // use a route push fallback
        try {
          navigator.pushNamed('/body');
        } catch (_) {
          // Silently ignore if route not registered — user can use tab bar
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: NEColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: NEColors.accent.withValues(alpha: 0.1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compact non-interactive body preview
            const SizedBox(
              width: 90,
              height: 140,
              child: BodyScene(
                selectedSystemKey: null,
                interactive: false,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Body Today',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    coachSentence,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Text(
                        'View full body',
                        style: TextStyle(
                          color: NEColors.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, color: NEColors.accent, size: 13),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyMissions(ActionState actionState) {
    final steps = actionState.steps;
    if (steps.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: NEColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: const Center(
          child: Text(
            'No active daily missions. Complete onboarding or check back later.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daily Missions',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        // ValueKey per step: Flutter correctly reconciles interactive widgets
        // across rebuilds, preventing MouseTracker from losing device state.
        for (final step in steps)
          _StepCard(
            key: ValueKey(step.id),
            step: step,
            onComplete: step.isCompleted
                ? null
                : () => ref.read(actionProvider.notifier).completeStep(step.id),
          ),
      ],
    );
  }

  Widget _buildInsightsFeed(List<Map<String, dynamic>> insights) {
    if (insights.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: NEColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: const Column(
          children: [
            Icon(Icons.spa_outlined, color: Colors.white38, size: 36),
            SizedBox(height: 12),
            Text(
              'No biological insights generated yet.',
              style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Complete your daily check-in to begin tracking patterns.',
              style: TextStyle(color: Colors.white38, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BIOLOGICAL TWIN SNAPSHOT',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        ...insights.map((insight) {
          final String title = insight['title']?.toString() ?? 'Insight';
          final String desc = insight['description']?.toString() ?? '';
          final String level = insight['confidence_level']?.toString() ?? 'HIGH';
          final List<String> reasoningChain = List<String>.from(insight['reasoning_chain'] ?? []);
          final List<String> citations = List<String>.from(insight['evidence_citations'] ?? []);
          final List<String> missingData = List<String>.from(insight['missing_data'] ?? []);
          final String generatedAtStr = insight['generated_at']?.toString() ?? '';

          Color badgeColor;
          String badgeText;
          if (level == 'HIGH') {
            badgeColor = Colors.indigoAccent;
            badgeText = 'High Confidence';
          } else if (level == 'MEDIUM') {
            badgeColor = Colors.teal;
            badgeText = 'Medium Confidence';
          } else if (level == 'LOW') {
            badgeColor = Colors.amber;
            badgeText = 'Early Signal';
          } else {
            badgeColor = Colors.grey;
            badgeText = 'Not Enough Data';
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: NEColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline_rounded, color: NEColors.accent, size: 20),
                      onPressed: () {
                        TraceabilityBottomSheet.show(
                          context,
                          observation: title,
                          evidence: desc,
                          confidence: badgeText,
                          lastUpdated: generatedAtStr.isNotEmpty 
                              ? DateTime.tryParse(generatedAtStr)?.toLocal().toString().split('.').first ?? 'Just now'
                              : 'Just now',
                          dataSource: 'BiologicalUnderstandingEngine & KnowledgeRepository',
                          missingInformation: missingData.isNotEmpty 
                              ? 'Missing inputs: ${missingData.join(", ")}' 
                              : 'No missing critical signals.',
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                ),
                if (reasoningChain.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 8),
                  const Text(
                    'REASONING PATHWAY',
                    style: TextStyle(color: Colors.white30, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 6),
                  ...reasoningChain.map((step) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: NEColors.accent, fontSize: 12)),
                        Expanded(
                          child: Text(
                            step,
                            style: const TextStyle(color: Colors.white54, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
                if (citations.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.menu_book_rounded, color: Colors.white30, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'Sources: ${citations.join(", ")}',
                        style: const TextStyle(color: Colors.white30, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildWhatWeDontKnowYet(List<Map<String, dynamic>> insights) {
    final Set<String> allMissingSignals = {};
    for (var insight in insights) {
      final List<String> missing = List<String>.from(insight['missing_data'] ?? []);
      allMissingSignals.addAll(missing);
    }

    if (allMissingSignals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "WHAT WE DON'T KNOW YET",
          style: TextStyle(
            color: Colors.white38,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: NEColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'These signals are missing from your evidence base. Providing them will calibrate the twin model and unlock deeper insights.',
                style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 16),
              ...allMissingSignals.map((signal) {
                String label;
                String explanation;
                IconData icon;
                if (signal == 'sleep_duration') {
                  label = 'Sleep Duration Logs';
                  explanation = 'We need daily sleep duration to compute your cumulative sleep debt.';
                  icon = Icons.bedtime_outlined;
                } else if (signal == 'water_intake') {
                  label = 'Hydration Logs';
                  explanation = 'Log your daily fluid consumption to verify cellular hydration volume.';
                  icon = Icons.local_drink_outlined;
                } else if (signal == 'wearable_hrv') {
                  label = 'Heart Rate Variability (HRV)';
                  explanation = 'Connect Oura or Apple Health to measure autonomic nervous system load.';
                  icon = Icons.favorite_border_rounded;
                } else if (signal == 'blood_glucose_logs') {
                  label = 'Post-Prandial Glucose Checks';
                  explanation = 'Input post-meal glucose logs to map direct clearance responsiveness.';
                  icon = Icons.bloodtype_outlined;
                } else {
                  label = signal.replaceAll('_', ' ');
                  explanation = 'Log this signal to improve baseline confidence.';
                  icon = Icons.help_outline_rounded;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: NEColors.accent, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              explanation,
                              style: const TextStyle(color: Colors.white38, fontSize: 11, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDailyCheckInCard(List<Map<String, dynamic>> timeline) {
    final checkIns = timeline.where((e) => e['event_type'] == 'daily_check_in').toList();
    bool hasCheckInToday = false;
    Map<String, dynamic>? latestCheckIn;
    
    if (checkIns.isNotEmpty) {
      latestCheckIn = checkIns.first; // sorted desc
      try {
        final dt = DateTime.parse(latestCheckIn['occurred_at']);
        final now = DateTime.now();
        if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
          hasCheckInToday = true;
        }
      } catch (_) {}
    }

    if (hasCheckInToday && latestCheckIn != null) {
      final payload = latestCheckIn['payload'] ?? {};
      final energy = payload['energy_level'] as int? ?? 0;
      final stress = payload['stress_level'] as int? ?? 0;
      final mood = payload['mood_level'] as int? ?? 0;
      final sleep = payload['sleep_quality'] as int? ?? 0;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: NEColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daily Check-In Completed',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        TraceabilityBottomSheet.show(
                          context,
                          observation: 'Daily Check-in Recorded',
                          evidence: 'User submitted subjective ratings.',
                          confidence: 'High (Self-reported)',
                          lastUpdated: latestCheckIn!['occurred_at'],
                          dataSource: 'IsarBiologicalEvent (type: daily_check_in)',
                          missingInformation: '',
                        );
                      },
                      child: const Icon(Icons.info_outline, color: Colors.white54, size: 20),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _showCheckInBottomSheet(context),
                      child: const Text(
                        'Edit',
                        style: TextStyle(color: NEColors.accent, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildCheckInMetricMini('Energy', energy, '/10', Colors.amber)),
                const SizedBox(width: 8),
                Expanded(child: _buildCheckInMetricMini('Stress', stress, '/10', Colors.orange)),
                const SizedBox(width: 8),
                Expanded(child: _buildCheckInMetricMini('Mood', mood, '/10', Colors.pink)),
                const SizedBox(width: 8),
                Expanded(child: _buildCheckInMetricMini('Sleep Q.', sleep, '/10', Colors.indigoAccent)),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NEColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NEColors.accent.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Check-In',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Log mood, stress, energy, & sleep quality.',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showCheckInBottomSheet(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: NEColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              minimumSize: const Size(0, 0),
            ),
            child: const Text('Log', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInMetricMini(String label, int val, String suffix, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: NEColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$val', style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
              Text(suffix, style: const TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  void _showCheckInBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CheckInBottomSheet(),
    );
  }


}

class _CheckInBottomSheet extends StatefulWidget {
  const _CheckInBottomSheet();

  @override
  State<_CheckInBottomSheet> createState() => _CheckInBottomSheetState();
}

class _CheckInBottomSheetState extends State<_CheckInBottomSheet> {
  double _energy = 5.0;
  double _stress = 5.0;
  double _mood = 5.0;
  double _sleep = 5.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: NEColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Consumer(
        builder: (context, ref, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Daily Check-In', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSlider('Energy Level', _energy, (val) => setState(() => _energy = val), Colors.amber),
              _buildSlider('Stress Level', _stress, (val) => setState(() => _stress = val), Colors.orange),
              _buildSlider('Mood Rating', _mood, (val) => setState(() => _mood = val), Colors.pink),
              _buildSlider('Sleep Quality', _sleep, (val) => setState(() => _sleep = val), Colors.indigoAccent),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    await ref.read(observationEngineProvider).logDailyCheckIn(
                      energy: _energy.toInt(),
                      stress: _stress.toInt(),
                      mood: _mood.toInt(),
                      sleepQuality: _sleep.toInt(),
                    );
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NEColors.accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Save Check-In', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSlider(String label, double val, ValueChanged<double> onChanged, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
            Text('${val.toInt()}/10', style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: val,
          min: 1.0,
          max: 10.0,
          divisions: 9,
          activeColor: color,
          inactiveColor: color.withValues(alpha: 0.15),
          onChanged: onChanged,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

/// Private card widget for a single daily mission step.
///
/// Key design decisions:
/// - StatelessWidget with a ValueKey(step.id) supplied by the parent.
///   This lets Flutter reconcile the same card across rebuilds without
///   disposing and re-creating the MouseRegion tree, which is the root
///   cause of the mouse_tracker.dart:199 assertion flood.
/// - GestureDetector on the whole card instead of IconButton:
///   IconButton creates its own MouseRegion + Semantics subtree that
///   conflicts with ListTile's GestureDetector when onPressed is null
///   (completed state), causing the tracker to lose the pointer device.
class _StepCard extends StatelessWidget {
  const _StepCard({
    super.key,
    required this.step,
    required this.onComplete,
  });

  final ActionStep step;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onComplete,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: NEColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: step.isCompleted
                ? NEColors.accent.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Completion indicator — plain Icon, no MouseRegion overhead.
              Padding(
                padding: const EdgeInsets.only(top: 2, right: 12),
                child: Icon(
                  step.isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_off_rounded,
                  color: step.isCompleted ? NEColors.accent : Colors.white30,
                  size: 22,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            step.title,
                            style: TextStyle(
                              color: step.isCompleted
                                  ? Colors.white38
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              decoration: step.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        if (step.timing != null)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: NEColors.surfaceLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              step.timing!,
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.white70),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.instruction,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Benefit: ${step.benefit}',
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── AG-12: Weather Icon animated widget ─────────────────────────────────────

class _WeatherIcon extends StatefulWidget {
  final String description;
  final bool isLoading;
  const _WeatherIcon({required this.description, required this.isLoading});

  @override
  State<_WeatherIcon> createState() => _WeatherIconState();
}

class _WeatherIconState extends State<_WeatherIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData get _icon {
    final d = widget.description.toLowerCase();
    if (d.contains('rain') || d.contains('drizzle')) return Icons.water_drop_outlined;
    if (d.contains('cloud')) return Icons.cloud_outlined;
    if (d.contains('haze') || d.contains('fog') || d.contains('mist')) return Icons.blur_on_rounded;
    if (d.contains('snow')) return Icons.ac_unit_rounded;
    if (d.contains('thunder')) return Icons.flash_on_rounded;
    return Icons.wb_sunny_outlined;
  }

  Color get _iconColor {
    final d = widget.description.toLowerCase();
    if (d.contains('rain') || d.contains('drizzle')) return Colors.lightBlue;
    if (d.contains('cloud')) return Colors.white54;
    if (d.contains('haze') || d.contains('fog')) return Colors.amber.withValues(alpha: 0.7);
    if (d.contains('snow')) return Colors.lightBlueAccent;
    if (d.contains('thunder')) return Colors.amberAccent;
    return Colors.amber;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
        child: const CircularProgressIndicator(
          strokeWidth: 1.5,
          valueColor: AlwaysStoppedAnimation(Colors.white24),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (_, child) => Transform.scale(scale: _animation.value, child: child),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _iconColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(_icon, color: _iconColor, size: 22),
      ),
    );
  }
}

// ─── AG-12: Environment stat tile ────────────────────────────────────────────

class _EnvStat extends StatelessWidget {
  final String label;
  final String value;
  const _EnvStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.38),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
