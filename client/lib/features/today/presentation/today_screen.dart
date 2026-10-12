import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/design_system/tokens/ne_tokens.dart';
import '../../../core/design_system/components/ne_card.dart';
import '../../../core/design_system/components/ne_chip.dart';
import '../../../core/network/environmental_service.dart';
import '../../../core/localization/app_language.dart';
import '../domain/today_state.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final language = ref.watch(languageProvider);
    final todayState = ref.watch(todayStateProvider);
    final envAsync = ref.watch(ambientEnvironmentalProvider);

    return Scaffold(
      backgroundColor: NeTokens.warmIvory,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: NeTokens.spacing20,
                vertical: NeTokens.spacing12,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: NeTokens.botanicalEvergreen,
                      borderRadius: BorderRadius.circular(NeTokens.radius12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.spa_rounded,
                        color: NeTokens.warmIvory,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: NeTokens.spacing12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'Health Explorer',
                          style: const TextStyle(
                            fontFamily: NeTokens.fontFamilySans,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: NeTokens.deepForest,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          NeStrings.get('tagline', language),
                          style: const TextStyle(
                            fontFamily: NeTokens.fontFamilySans,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: NeTokens.slateMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Environmental Quick Pill
                  envAsync.when(
                    data: (env) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: NeTokens.spacing10,
                        vertical: NeTokens.spacing6,
                      ),
                      decoration: BoxDecoration(
                        color: NeTokens.pureWhite,
                        borderRadius: BorderRadius.circular(
                          NeTokens.radiusFull,
                        ),
                        border: Border.all(color: NeTokens.sandDune),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.thermostat_rounded,
                            size: 14,
                            color: NeTokens.mossGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            env != null
                                ? '${env.temperatureC.toStringAsFixed(0)}°C'
                                : '--°C',
                            style: const TextStyle(
                              fontFamily: NeTokens.fontFamilySans,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: NeTokens.deepForest,
                            ),
                          ),
                        ],
                      ),
                    ),
                    loading: () => const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: NeTokens.botanicalEvergreen,
                      ),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            // Main Scrollable Body
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: NeTokens.spacing20,
                ),
                children: [
                  const SizedBox(height: NeTokens.spacing8),

                  // Environmental Telemetry Card
                  envAsync.when(
                    data: (env) => _buildEnvironmentalCard(env),
                    loading: () => const NeCard(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(NeTokens.spacing16),
                          child: CircularProgressIndicator(
                            color: NeTokens.botanicalEvergreen,
                          ),
                        ),
                      ),
                    ),
                    error: (err, _) => NeCard(
                      child: Text('Environmental telemetry unavailable: $err'),
                    ),
                  ),

                  const SizedBox(height: NeTokens.spacing16),

                  // Health Memory Readiness Card
                  _buildReadinessCard(todayState),

                  const SizedBox(height: NeTokens.spacing20),

                  // Daily Protocols & Habits Checklist
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Daily Evidence Protocols',
                        style: TextStyle(
                          fontFamily: NeTokens.fontFamilySerif,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: NeTokens.deepForest,
                        ),
                      ),
                      Text(
                        '${todayState.habits.where((h) => h.isCompleted).length}/${todayState.habits.length}',
                        style: const TextStyle(
                          fontFamily: NeTokens.fontFamilySans,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: NeTokens.mossGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: NeTokens.spacing10),
                  ...todayState.habits.map(
                    (habit) => Padding(
                      padding: const EdgeInsets.only(bottom: NeTokens.spacing8),
                      child: InkWell(
                        onTap: () => ref
                            .read(todayStateProvider.notifier)
                            .toggleHabit(habit.id),
                        borderRadius: BorderRadius.circular(NeTokens.radius12),
                        child: NeCard(
                          padding: const EdgeInsets.all(NeTokens.spacing12),
                          child: Row(
                            children: [
                              Icon(
                                habit.isCompleted
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                color: habit.isCompleted
                                    ? NeTokens.mossGreen
                                    : NeTokens.slateMuted,
                                size: 22,
                              ),
                              const SizedBox(width: NeTokens.spacing12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      habit.title,
                                      style: TextStyle(
                                        fontFamily: NeTokens.fontFamilySans,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: habit.isCompleted
                                            ? NeTokens.slateMuted
                                            : NeTokens.deepForest,
                                        decoration: habit.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      habit.subtitle,
                                      style: const TextStyle(
                                        fontFamily: NeTokens.fontFamilySans,
                                        fontSize: 12,
                                        color: NeTokens.slateMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: NeTokens.spacing16),

                  // Prompt Inspiration Section
                  const Text(
                    'Explore Evidence & Scientific Hypotheses',
                    style: TextStyle(
                      fontFamily: NeTokens.fontFamilySerif,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: NeTokens.deepForest,
                    ),
                  ),
                  const SizedBox(height: NeTokens.spacing8),
                  Wrap(
                    spacing: NeTokens.spacing8,
                    runSpacing: NeTokens.spacing8,
                    children: [
                      NeChip(
                        label: '🔬 Pea protein vs Whey protein',
                        onTap: () => context.push(
                          '/research?q=Pea protein vs Whey protein',
                        ),
                      ),
                      NeChip(
                        label: '☀️ UV Index & Vitamin D synthesis',
                        onTap: () => context.push(
                          '/research?q=UV Index & Vitamin D synthesis',
                        ),
                      ),
                      NeChip(
                        label: '🦴 Calcium bioavailability & bone density',
                        onTap: () => context.push(
                          '/research?q=Calcium bioavailability & bone density',
                        ),
                      ),
                      NeChip(
                        label: '⚡ Magnesium glycinate for sleep',
                        onTap: () => context.push(
                          '/research?q=Magnesium glycinate for sleep',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 100), // Padding above thumb dock
                ],
              ),
            ),

            // Thumb-Reachable "Ask Earth" Composer Dock
            _buildComposerDock(context, language),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvironmentalCard(EnvironmentalMetrics? env) {
    if (env == null) return const SizedBox.shrink();

    return NeCard(
      color: NeTokens.botanicalEvergreen,
      padding: const EdgeInsets.all(NeTokens.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.public_rounded,
                    color: NeTokens.warmIvory,
                    size: 16,
                  ),
                  SizedBox(width: NeTokens.spacing6),
                  Text(
                    'LIVE AMBIENT SENSORS',
                    style: TextStyle(
                      fontFamily: NeTokens.fontFamilySans,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: NeTokens.sandDune,
                    ),
                  ),
                ],
              ),
              Text(
                env.attribution,
                style: const TextStyle(
                  fontFamily: NeTokens.fontFamilySans,
                  fontSize: 10,
                  color: NeTokens.sandDune,
                ),
              ),
            ],
          ),
          const SizedBox(height: NeTokens.spacing12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildEnvMetric(
                label: 'Temperature',
                value: '${env.temperatureC.toStringAsFixed(1)}°C',
                sub: env.weatherCondition,
              ),
              _buildEnvMetric(
                label: 'UV Index',
                value: env.uvIndex.toStringAsFixed(1),
                sub: env.uvIndex > 5.0 ? 'High' : 'Moderate',
              ),
              _buildEnvMetric(
                label: 'Air Quality (AQI)',
                value: env.usAqi?.toString() ?? 'Good',
                sub: env.aqiCategory,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnvMetric({
    required String label,
    required String value,
    required String sub,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: NeTokens.fontFamilySans,
            fontSize: 11,
            color: NeTokens.sandDune,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontFamily: NeTokens.fontFamilySans,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: NeTokens.warmIvory,
          ),
        ),
        Text(
          sub,
          style: const TextStyle(
            fontFamily: NeTokens.fontFamilySans,
            fontSize: 11,
            color: NeTokens.sandDune,
          ),
        ),
      ],
    );
  }

  Widget _buildReadinessCard(TodayState state) {
    return NeCard(
      padding: const EdgeInsets.all(NeTokens.spacing16),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: NeTokens.mossGreen, width: 3),
            ),
            child: Center(
              child: Text(
                '${state.healthReadinessScore}',
                style: const TextStyle(
                  fontFamily: NeTokens.fontFamilySerif,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: NeTokens.deepForest,
                ),
              ),
            ),
          ),
          const SizedBox(width: NeTokens.spacing16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Metabolic Readiness',
                  style: TextStyle(
                    fontFamily: NeTokens.fontFamilySans,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: NeTokens.deepForest,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Hydration baseline on track. Morning cortisol and daylight alignment optimal.',
                  style: TextStyle(
                    fontFamily: NeTokens.fontFamilySans,
                    fontSize: 12,
                    color: NeTokens.slateMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComposerDock(BuildContext context, AppLanguage language) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        NeTokens.spacing16,
        NeTokens.spacing10,
        NeTokens.spacing16,
        NeTokens.spacing12,
      ),
      decoration: BoxDecoration(
        color: NeTokens.pureWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.push('/research'),
        borderRadius: BorderRadius.circular(NeTokens.radius16),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: NeTokens.spacing16,
            vertical: NeTokens.spacing12,
          ),
          decoration: BoxDecoration(
            color: NeTokens.warmIvory,
            borderRadius: BorderRadius.circular(NeTokens.radius16),
            border: Border.all(color: NeTokens.sandDune),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search_rounded,
                color: NeTokens.mossGreen,
                size: 22,
              ),
              const SizedBox(width: NeTokens.spacing10),
              Expanded(
                child: Text(
                  NeStrings.get('ask_earth', language),
                  style: const TextStyle(
                    fontFamily: NeTokens.fontFamilySans,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: NeTokens.slateMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.camera_alt_outlined,
                color: NeTokens.deepForest,
                size: 20,
              ),
              const SizedBox(width: NeTokens.spacing12),
              const Icon(
                Icons.mic_none_rounded,
                color: NeTokens.deepForest,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
