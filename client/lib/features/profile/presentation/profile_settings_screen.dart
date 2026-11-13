// ==============================================================================
// Nutrient Earth — Profile & Settings Screen
// Authoritative, accessible profile management and account settings.
// Integrates with currentProfileProvider & onboardingJourneyProvider.
// Provides frictionless editing via returnTo=/profile routing.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../../../core/domain/personalization/user_profile_context.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/profile_repository.dart';
import '../../onboarding/state/onboarding_journey_state.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  final int initialTab; // 0: Profile, 1: Settings
  const ProfileSettingsScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);
    final currentUser = ref.watch(currentUserProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final journey = ref.watch(onboardingJourneyProvider);
    final profileAsync = ref.watch(currentProfileProvider);

    // Merge authentic profile data with in-flight journey state
    final profile = profileAsync.valueOrNull;

    final displayName = journey.firstName.trim().isNotEmpty
        ? journey.firstName.trim()
        : (profile?.displayName.isNotEmpty == true && profile?.displayName != 'User'
            ? profile!.displayName
            : (currentUser?.email?.split('@').first ?? 'Explorer'));

    final email = currentUser?.email ?? 'Unauthenticated Explorer';
    final isVerified = isAuthenticated && (profile?.onboardingCompleted == true || journey.onboardingFinished);

    return Scaffold(
      backgroundColor: NETokens.background,
      appBar: AppBar(
        backgroundColor: NETokens.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: NETokens.deepestForest),
          tooltip: 'Back to Today',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/today');
            }
          },
        ),
        title: const Text(
          'Profile & Settings',
          style: TextStyle(
            color: NETokens.deepestForest,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: NETokens.deepestForest,
          unselectedLabelColor: NETokens.onSurfaceVariant,
          indicatorColor: NETokens.botanicalTeal,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          tabs: const [
            Tab(text: 'Health Calibration', icon: Icon(Icons.spa_rounded, size: 20)),
            Tab(text: 'Account & Security', icon: Icon(Icons.shield_outlined, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHealthCalibrationTab(
            context: context,
            displayName: displayName,
            isVerified: isVerified,
            journey: journey,
            profile: profile,
          ),
          _buildAccountSecurityTab(
            context: context,
            displayName: displayName,
            email: email,
            isAuthenticated: isAuthenticated,
            currentUser: currentUser,
            authService: authService,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthCalibrationTab({
    required BuildContext context,
    required String displayName,
    required bool isVerified,
    required OnboardingJourneyState journey,
    required UserProfileContext? profile,
  }) {
    // Resolve fields prioritizing in-flight journey then database profile
    final goals = journey.healthGoals.isNotEmpty
        ? journey.healthGoals.toList()
        : (profile?.primaryGoals ?? const <String>[]);

    final difficulties = journey.difficulties.isNotEmpty
        ? journey.difficulties.toList()
        : (profile?.difficulties ?? const <String>[]);

    final difficultiesNote = journey.difficultiesNote.isNotEmpty
        ? journey.difficultiesNote
        : (profile?.difficultiesNote ?? '');

    final diet = journey.dietaryPattern.isNotEmpty
        ? journey.dietaryPattern
        : (profile?.dietaryPreference.isNotEmpty == true ? profile!.dietaryPreference : 'None specified');

    final avoid = journey.foodsToAvoid.isNotEmpty
        ? journey.foodsToAvoid.toList()
        : const <String>[];

    final intolerances = journey.foodIntolerances.isNotEmpty
        ? journey.foodIntolerances.toList()
        : const <String>[];

    final allergens = journey.allergens.isNotEmpty
        ? journey.allergens.toList()
        : (profile?.allergies ?? const <String>[]);

    final heightCm = journey.heightCm ?? profile?.heightCm;
    final weightKg = journey.weightSkipped ? null : (journey.weightKg ?? profile?.weightKg);
    final age = journey.age > 0 ? journey.age : (profile?.age ?? 0);

    final routine = journey.eatingRoutine.isNotEmpty
        ? journey.eatingRoutine
        : (profile?.eatingRoutine.isNotEmpty == true ? profile!.eatingRoutine : 'None selected');

    final activity = journey.activityLevel.isNotEmpty
        ? journey.activityLevel
        : (profile?.activityLevel.isNotEmpty == true ? profile!.activityLevel : 'None selected');

    final sleep = journey.sleepQuality.isNotEmpty
        ? journey.sleepQuality
        : (profile?.sleepQuality.isNotEmpty == true ? profile!.sleepQuality : 'None selected');

    final knowledge = journey.knowledgeLevel.isNotEmpty
        ? journey.knowledgeLevel
        : (profile?.knowledgeLevel.isNotEmpty == true ? profile!.knowledgeLevel : 'None selected');

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        // Header Identity Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE4E9E2)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A051F20),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: NETokens.paleMint,
                ),
                child: Center(
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'E',
                    style: const TextStyle(
                      color: NETokens.deepestForest,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: NETokens.deepestForest,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isVerified ? const Color(0xFFEAF5EF) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isVerified ? const Color(0xFF38675A) : const Color(0xFFD1D5DB),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isVerified ? Icons.verified_rounded : Icons.info_outline_rounded,
                            size: 14,
                            color: isVerified ? const Color(0xFF166534) : const Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isVerified ? 'Profile Verified' : 'Calibrated Guest Profile',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isVerified ? const Color(0xFF166534) : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Section 1: Physiology & Measurements
        _buildSectionCard(
          title: 'Physiology & Measurements',
          icon: Icons.person_outline_rounded,
          editRoute: '/onboarding/personal-details?returnTo=/profile',
          editLabel: 'Edit Name & Age',
          secondaryEditRoute: '/onboarding/body-measurements?returnTo=/profile',
          secondaryEditLabel: 'Edit Measurements',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDataRow('First Name', displayName),
              const Divider(height: 16, color: Color(0xFFF0EEE9)),
              _buildDataRow('Age', age > 0 ? '$age years' : 'Not specified'),
              const Divider(height: 16, color: Color(0xFFF0EEE9)),
              _buildDataRow(
                'Height',
                heightCm != null ? '${heightCm.round()} cm (${(heightCm / 30.48).toStringAsFixed(1)} ft)' : 'Not specified',
              ),
              const Divider(height: 16, color: Color(0xFFF0EEE9)),
              _buildDataRow(
                'Weight',
                journey.weightSkipped
                    ? 'Prefer not to say (Skipped)'
                    : (weightKg != null ? '${weightKg.round()} kg (${(weightKg * 2.20462).round()} lb)' : 'Not specified'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Section 2: Health Goals
        _buildSectionCard(
          title: 'Health Goals',
          icon: Icons.flag_outlined,
          editRoute: '/onboarding/health-goals?returnTo=/profile',
          editLabel: 'Edit Goals',
          content: goals.isNotEmpty
              ? Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: goals.map((g) => _buildChip(_formatTitle(g), NETokens.botanicalTeal)).toList(),
                )
              : const Text(
                  'No primary health goals selected yet.',
                  style: TextStyle(color: NETokens.onSurfaceVariant, fontSize: 14),
                ),
        ),

        const SizedBox(height: 16),

        // Section 3: Difficulties & Daily Impact
        _buildSectionCard(
          title: 'Daily Difficulties & Impact',
          icon: Icons.fitness_center_outlined,
          editRoute: '/onboarding/difficulties?returnTo=/profile',
          editLabel: 'Edit Difficulties',
          secondaryEditRoute: '/onboarding/daily-impact?returnTo=/profile',
          secondaryEditLabel: 'Edit Impact Rating',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (difficulties.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: difficulties.map((d) => _buildChip(_formatTitle(d), const Color(0xFF0B2B26))).toList(),
                ),
                if (difficultiesNote.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Note: "$difficultiesNote"',
                    style: const TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: NETokens.onSurfaceVariant,
                    ),
                  ),
                ],
              ] else
                const Text(
                  'No physical difficulties or concerns reported.',
                  style: TextStyle(color: NETokens.onSurfaceVariant, fontSize: 14),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Section 4: Dietary Pattern & Nutrition
        _buildSectionCard(
          title: 'Dietary Pattern & Avoidances',
          icon: Icons.restaurant_outlined,
          editRoute: '/onboarding/food-choices?returnTo=/profile',
          editLabel: 'Edit Dietary Profile',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDataRow('Dietary Pattern', _formatTitle(diet)),
              if (intolerances.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Sensitivities & Intolerances:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: NETokens.deepestForest),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: intolerances.map((i) => _buildChip(_formatTitle(i), const Color(0xFFB45309))).toList(),
                ),
              ],
              if (avoid.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Foods Chosen to Avoid:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: NETokens.deepestForest),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: avoid.map((a) => _buildChip(_formatTitle(a), const Color(0xFFDC2626))).toList(),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Section 5: Clinical Safety & Allergens
        _buildSectionCard(
          title: 'Clinical Safety & Allergies',
          icon: Icons.warning_amber_rounded,
          editRoute: '/onboarding/food-restrictions?returnTo=/profile',
          editLabel: 'Edit Allergens',
          content: journey.strictlyNoRestrictions
              ? const Text(
                  'Strictly no known food restrictions or clinical allergies.',
                  style: TextStyle(color: Color(0xFF166534), fontWeight: FontWeight.w600, fontSize: 14),
                )
              : (allergens.isNotEmpty
                  ? Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: allergens.map((a) => _buildChip(_formatTitle(a), const Color(0xFFBA1A1A))).toList(),
                    )
                  : const Text(
                      'No specific food allergies indicated.',
                      style: TextStyle(color: NETokens.onSurfaceVariant, fontSize: 14),
                    )),
        ),

        const SizedBox(height: 16),

        // Section 6: Lifestyle, Sleep & Routine
        _buildSectionCard(
          title: 'Lifestyle, Routine & Sleep',
          icon: Icons.bedtime_outlined,
          editRoute: '/onboarding/eating-routine?returnTo=/profile',
          editLabel: 'Edit Routine',
          secondaryEditRoute: '/onboarding/daily-activity?returnTo=/profile',
          secondaryEditLabel: 'Edit Activity & Sleep',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDataRow('Eating Routine', _formatTitle(routine)),
              const Divider(height: 16, color: Color(0xFFF0EEE9)),
              _buildDataRow('Daily Activity', _formatTitle(activity)),
              const Divider(height: 16, color: Color(0xFFF0EEE9)),
              _buildDataRow('Sleep Quality', _formatTitle(sleep)),
              const Divider(height: 16, color: Color(0xFFF0EEE9)),
              _buildDataRow('Health Knowledge', _formatTitle(knowledge)),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Review Checkpoints
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F8F5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF38675A).withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.checklist_rounded, color: Color(0xFF38675A), size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Full Calibration Checkpoints',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: NETokens.deepestForest,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Review your entire Phase 1 foundational health profile or view the complete Phase 2 calibration certification.',
                style: TextStyle(fontSize: 13, color: NETokens.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF38675A),
                        side: const BorderSide(color: Color(0xFF38675A)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => context.push('/onboarding/review-phase1?returnTo=/profile'),
                      child: const Text('Review Phase 1', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF38675A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () => context.push('/onboarding/completion?returnTo=/profile'),
                      child: const Text('Completion Card', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSecurityTab({
    required BuildContext context,
    required String displayName,
    required String email,
    required bool isAuthenticated,
    required dynamic currentUser,
    required AuthService authService,
  }) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        // Account Details Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE4E9E2)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A051F20),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.account_circle_outlined, color: NETokens.botanicalTeal, size: 24),
                  SizedBox(width: 10),
                  Text(
                    'Account Identity',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: NETokens.deepestForest,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDataRow('Status', isAuthenticated ? 'Authenticated Session' : 'Guest Exploration'),
              const Divider(height: 20, color: Color(0xFFF0EEE9)),
              _buildDataRow('Email Address', email),
              const Divider(height: 20, color: Color(0xFFF0EEE9)),
              _buildDataRow(
                'User ID',
                currentUser?.id != null ? '${currentUser.id.substring(0, 8)}...' : 'Unregistered Guest',
              ),
              const Divider(height: 20, color: Color(0xFFF0EEE9)),
              _buildDataRow('Security Level', 'Clinical Account Isolation (RLS)'),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Clinical Safety & Data Architecture Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE4E9E2)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lock_outline_rounded, color: Color(0xFF166534), size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Data Protection & Privacy Architecture',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: NETokens.deepestForest,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                '• Strict account-scoped local cache prevents cross-account health data leakage.\n'
                '• Row Level Security (RLS) on public.profiles restricts PostgREST persistence strictly to auth.uid().\n'
                '• Anonymized physiological evaluation maps protect your personal identifiable information.',
                style: TextStyle(fontSize: 13, height: 1.5, color: NETokens.onSurfaceVariant),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Auth Action Buttons
        if (isAuthenticated) ...[
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFDC2626),
              side: const BorderSide(color: Color(0xFFDC2626)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.logout_rounded, size: 20),
            label: const Text('Sign Out of Nutrient Earth', style: TextStyle(fontWeight: FontWeight.w700)),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out of Nutrient Earth?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await authService.signOut();
                if (context.mounted) {
                  context.go('/welcome');
                }
              }
            },
          ),
        ] else ...[
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38675A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            icon: const Icon(Icons.login_rounded, size: 20),
            label: const Text('Sign In or Register Account', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            onPressed: () => context.push('/auth?mode=login'),
          ),
        ],

        const SizedBox(height: 16),

        // Return to Today Action
        TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: NETokens.deepestForest,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          icon: const Icon(Icons.arrow_back_rounded, size: 18),
          label: const Text('Return to Today Plan', style: TextStyle(fontWeight: FontWeight.w600)),
          onPressed: () => context.go('/today'),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required String editRoute,
    required String editLabel,
    String? secondaryEditRoute,
    String? secondaryEditLabel,
    required Widget content,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4E9E2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06051F20),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: NETokens.botanicalTeal, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: NETokens.deepestForest,
                  ),
                ),
              ),
              InkWell(
                onTap: () => context.push(editRoute),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.edit_outlined, size: 14, color: Color(0xFF38675A)),
                      const SizedBox(width: 4),
                      Text(
                        editLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF38675A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          content,
          if (secondaryEditRoute != null && secondaryEditLabel != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () => context.push(secondaryEditRoute),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.edit_outlined, size: 14, color: Color(0xFF38675A)),
                      const SizedBox(width: 4),
                      Text(
                        secondaryEditLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF38675A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: NETokens.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              color: NETokens.deepestForest,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  String _formatTitle(String raw) {
    if (raw.isEmpty) return 'None';
    return raw
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }
}
