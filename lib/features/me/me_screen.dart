import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/lifecycle/app_lifecycle_notifier.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/biological_profile_provider.dart';
import '../../core/models/app_models.dart';
import '../../core/services/user_state_engine.dart';
import '../../core/providers/app_providers.dart';

class MeScreen extends ConsumerWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // AG-11 Bug 3: name reads from appUserProvider (users_profile.full_name),
    // not from Google auth user metadata.
    final appUser = ref.watch(appUserProvider).value;
    final healthId = ref.watch(healthIdentityProvider);

    // Derive display name: prefer healthIdentity.name, then appUser.fullName
    final healthIdName = healthId?.name.trim();
    final appUserName = appUser?.fullName?.trim();
    final displayName = (healthIdName != null && healthIdName.isNotEmpty)
        ? healthIdName
        : (appUserName != null && appUserName.isNotEmpty)
            ? appUserName
            : appUser?.email ?? '';

    if (healthId == null) {
      return const Scaffold(
        backgroundColor: NEColors.background,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_outline_rounded, color: Colors.white38, size: 64),
                SizedBox(height: 16),
                Text(
                  'No profile data found',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Complete onboarding to view your biological profile.',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: NEColors.background,
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            backgroundColor: NEColors.background,
            pinned: true,
            title: Text('Me'),
            centerTitle: false,
          ),
          // Profile header — AG-11 Bug 3: reads from profile, not Google metadata
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: NEColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: NEColors.accentSurface,
                      child: Text(
                        (displayName.isNotEmpty ? displayName.substring(0, 1) : 'A').toUpperCase(),
                        style: const TextStyle(
                          color: NEColors.accent,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
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
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            appUser?.email ?? 'guest@nutrientearth.local',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Stats row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      label: 'Goal',
                      value: healthId.primaryGoal,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                      label: 'Activity',
                      value: healthId.activityLevel,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                      label: 'Sleep',
                      value: _getSleepHoursString(healthId),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Settings sections
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: NEColors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _SettingsItem(
                      icon: Icons.person_outline_rounded,
                      label: 'Health Profile',
                      onTap: () => _showEditProfileSheet(context, ref, healthId),
                    ),
                    const Divider(color: Colors.white12, height: 1),
                    _SettingsItem(
                      icon: Icons.feedback_outlined,
                      label: 'Alpha Feedback Hub',
                      onTap: () => context.push('/feedback-hub'),
                    ),
                    const Divider(color: Colors.white12, height: 1),
                    _SettingsItem(
                      icon: Icons.privacy_tip_outlined,
                      label: 'Privacy Policy',
                      onTap: () => context.push('/legal/privacy'),
                    ),
                    const Divider(color: Colors.white12, height: 1),
                    _SettingsItem(
                      icon: Icons.description_outlined,
                      label: 'Terms of Service',
                      onTap: () => context.push('/legal/terms'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // DEVELOPER PLAYGROUND (DO NOT SHIP)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push('/dev/playground');
                },
                icon: const Icon(Icons.developer_mode, color: Colors.white),
                label: const Text('Developer Playground', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[900],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),

          // Sign out
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: GestureDetector(
                onTap: () async {
                  HapticFeedback.mediumImpact();
                  await ref.read(appLifecycleProvider.notifier).signOut();
                  if (context.mounted) context.go('/auth');
                },
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: NEColors.statusRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(
                      color: NEColors.statusRed,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Version
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Center(
                child: Text(
                  'Nutrient Earth v2.0',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  String _getSleepHoursString(HealthIdentity identity) {
    try {
      final sleepParts = identity.sleepTime.split(':');
      final wakeParts = identity.wakeTime.split(':');
      final sleepMin = int.parse(sleepParts[0]) * 60 + int.parse(sleepParts[1]);
      final wakeMin = int.parse(wakeParts[0]) * 60 + int.parse(wakeParts[1]);
      int diff = wakeMin - sleepMin;
      if (diff < 0) diff += 24 * 60;
      final hours = diff / 60.0;
      return '${hours.toStringAsFixed(1)}h';
    } catch (_) {
      return '8.0h';
    }
  }

  void _showEditProfileSheet(BuildContext context, WidgetRef ref, HealthIdentity healthId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditProfileSheet(identity: healthId),
    );
  }
}

// ─── Edit Profile Sheet ───────────────────────────────────────────────────────
//
// AG-11 Bug 1: The save button was previously at the bottom of a
// SingleChildScrollView and scrolled off screen. Fixed by splitting the sheet
// into a Column with:
//   1. Expanded(SingleChildScrollView) — scrollable form fields
//   2. A sticky footer — always visible, holds the save button
// The sheet itself is a DraggableScrollableSheet so the user can expand it
// without the keyboard causing layout shifts.

class _EditProfileSheet extends ConsumerStatefulWidget {
  final HealthIdentity identity;
  const _EditProfileSheet({required this.identity});

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late TextEditingController _nameController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _ageController;
  late TextEditingController _cityController;
  late TextEditingController _occupationController;

  String _gender = 'Male';
  String _goal = 'General Health';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.identity.name);
    _weightController = TextEditingController(text: widget.identity.weight.toString());
    _heightController = TextEditingController(text: widget.identity.height.toString());
    _ageController = TextEditingController(text: widget.identity.age.toString());
    _cityController = TextEditingController(text: widget.identity.city);
    _occupationController = TextEditingController(text: widget.identity.occupation);

    _gender = widget.identity.gender;
    if (_gender.isEmpty) _gender = 'Male';

    _goal = widget.identity.primaryGoal;
    if (_goal.isEmpty) _goal = 'General Health';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    _cityController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final weight = double.tryParse(_weightController.text) ?? widget.identity.weight;
      final height = double.tryParse(_heightController.text) ?? widget.identity.height;
      final age = int.tryParse(_ageController.text) ?? widget.identity.age;
      final name = _nameController.text.trim();
      final city = _cityController.text.trim();
      final occupation = _occupationController.text.trim();

      final updatedIdentity = HealthIdentity(
        userId: widget.identity.userId,
        name: name,
        age: age,
        gender: _gender,
        height: height,
        weight: weight,
        country: widget.identity.country,
        city: city,
        occupation: occupation,
        primaryGoal: _goal,
        sleepTime: widget.identity.sleepTime,
        wakeTime: widget.identity.wakeTime,
        activityLevel: widget.identity.activityLevel,
        exercise: widget.identity.exercise,
        smoking: widget.identity.smoking,
        alcohol: widget.identity.alcohol,
        stressLevel: widget.identity.stressLevel,
        dietPreference: widget.identity.dietPreference,
        waterIntake: widget.identity.waterIntake,
        mealTiming: widget.identity.mealTiming,
        supplements: widget.identity.supplements,
        hasDiabetesRisk: widget.identity.hasDiabetesRisk,
        hasHeartDiseaseRisk: widget.identity.hasHeartDiseaseRisk,
        hasCancerRisk: widget.identity.hasCancerRisk,
        hasThyroidRisk: widget.identity.hasThyroidRisk,
        hasBloodPressureRisk: widget.identity.hasBloodPressureRisk,
        updatedAt: DateTime.now(),
      );
      await ref.read(healthIdentityProvider.notifier).updateIdentity(updatedIdentity);

      // Refresh system user understanding database on save
      await ref.read(userStateEngineProvider).updateUnderstandingFromSystem();

      if (!mounted) return;
      HapticFeedback.mediumImpact();
      Navigator.pop(context);

      // Show success confirmation — AG-11: user now knows the save worked
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: NEColors.accent, size: 18),
              SizedBox(width: 10),
              Text(
                'Profile synced ✓',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: NEColors.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Save failed: $e', style: const TextStyle(color: Colors.white)),
          backgroundColor: NEColors.statusRed.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final goals = [
      'Longevity', 'Performance', 'Mental Clarity',
      'Recovery', 'Metabolic Health', 'Biological Resilience', 'General Health'
    ];

    // AG-11 Bug 1: viewInsets.bottom ensures the sticky footer rides above the keyboard
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: NEColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ──
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Scrollable form fields ── (AG-11: form scrolls, button stays fixed)
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Biological Calibration',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  _buildField('Full Name', _nameController, keyboardType: TextInputType.name),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildField('Weight (kg)', _weightController, keyboardType: TextInputType.number)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildField('Height (cm)', _heightController, keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildField('Age', _ageController, keyboardType: TextInputType.number)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Gender', style: TextStyle(color: NEColors.textTertiary, fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: NEColors.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _gender.toLowerCase() == 'male' ? 'Male' : (_gender.toLowerCase() == 'female' ? 'Female' : 'Other'),
                                  dropdownColor: NEColors.surface,
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) setState(() => _gender = val);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildField('City', _cityController, keyboardType: TextInputType.text),
                  const SizedBox(height: 16),
                  _buildField('Occupation', _occupationController, keyboardType: TextInputType.text),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Primary Goal', style: TextStyle(color: NEColors.textTertiary, fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: NEColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: goals.contains(_goal) ? _goal : 'General Health',
                            dropdownColor: NEColors.surface,
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
                            isExpanded: true,
                            items: goals.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _goal = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Bottom padding so the last field clears the sticky footer
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Sticky Save Footer ── (AG-11 Bug 1: always visible, above keyboard)
          Container(
            padding: EdgeInsets.fromLTRB(24, 12, 24, keyboardHeight > 0 ? keyboardHeight + 12 : 24),
            decoration: const BoxDecoration(
              color: NEColors.surface,
              border: Border(top: BorderSide(color: Colors.white12, width: 0.5)),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NEColors.accent,
                    disabledBackgroundColor: NEColors.accent.withValues(alpha: 0.5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text(
                          'Sync Biological Data',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {required TextInputType keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: NEColors.textTertiary, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: NEColors.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label, value;
  const _StatTile({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NEColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: NEColors.textSecondary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: NEColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
