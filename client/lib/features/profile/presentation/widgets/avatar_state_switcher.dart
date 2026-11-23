// ==============================================================================
// Nutrient Earth — AvatarStateSwitcher & "Meet Your Companion" Creation Modal
// Living Avatar Engine: Step 1 (Trigger) & Step 2 (God-Mode Onboarding Modal)
// Pixel perfection: #FAF8F5 canvas, #EAF0EC cards, #0A2E1F dark green borders
// ==============================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/personalization/user_profile_context.dart';
import '../../../today/state/today_state.dart';
import 'package:nutrient_earth_client/features/living_avatar/application/controllers/living_avatar_controller.dart';
import 'package:nutrient_earth_client/features/living_avatar/presentation/widgets/living_avatar_view.dart';

/// Active skin tone choice state for avatar preview and creation
final avatarSelectedSkinToneProvider = StateProvider<String>((ref) => '#E0AC69');

/// AvatarStateSwitcher Widget
/// Bounded within a strict 110x110px circle.
/// State A (No Avatar): Glassmorphic button (#0A2E1F dark green border) with user-outline icon and "Create Avatar" label.
/// State B (Avatar Exists): Live animated character bounded in 110x110px circle.
class AvatarStateSwitcher extends ConsumerWidget {
  final double size;
  final VoidCallback? onAvatarTap;
  final bool enableAnimation;

  const AvatarStateSwitcher({
    super.key,
    this.size = 110.0,
    this.onAvatarTap,
    this.enableAnimation = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayState = ref.watch(todayNotifierProvider);
    final userProfile = todayState.userProfile;
    final hasAvatar = userProfile?.hasAvatar ?? false;

    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: hasAvatar
            ? _buildStateBAvatar(context, ref, userProfile, todayState)
            : _buildStateACreateButton(context, ref),
      ),
    );
  }

  /// State A: Glassmorphic circular button with #0A2E1F dark green border
  Widget _buildStateACreateButton(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showCompanionCreationModal(context, ref),
        borderRadius: BorderRadius.circular(size / 2),
        splashColor: const Color(0x220A2E1F),
        highlightColor: const Color(0x110A2E1F),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xCCFBF9F4), // 80% opacity glassmorphic base
            border: Border.all(
              color: const Color(0xFF0A2E1F), // Strict #0A2E1F dark green border
              width: 2.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x120A2E1F),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.person_outline_rounded,
                  size: 28,
                  color: Color(0xFF0A2E1F),
                ),
                SizedBox(height: 3),
                Text(
                  'Create\nAvatar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0A2E1F),
                    height: 1.15,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// State B: Live Avatar bounded within 110x110px circle
  Widget _buildStateBAvatar(
    BuildContext context,
    WidgetRef ref,
    UserProfileContext? profile,
    TodayState todayState,
  ) {
    final avatarScene = ref.watch(livingAvatarControllerProvider);
    final hexTone = profile?.skinTone ?? ref.watch(avatarSelectedSkinToneProvider);
    final effectiveScene = hexTone != avatarScene.identity.skinToneHex
        ? avatarScene.copyWith(
            identity: avatarScene.identity.copyWith(skinToneHex: hexTone),
          )
        : avatarScene;

    return LivingAvatarView(
      scene: effectiveScene,
      size: size,
      onTap: onAvatarTap ?? () => showCompanionCreationModal(context, ref),
      enableAnimation: enableAnimation,
    );
  }
}

/// Step 2: "Meet Your Companion" God-Mode Creation Modal
void showCompanionCreationModal(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFFFAF8F5), // Exact #FAF8F5 canvas
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => const _CompanionCreationSheet(),
  );
}

class _CompanionCreationSheet extends ConsumerStatefulWidget {
  const _CompanionCreationSheet();

  @override
  ConsumerState<_CompanionCreationSheet> createState() =>
      _CompanionCreationSheetState();
}

class _CompanionCreationSheetState extends ConsumerState<_CompanionCreationSheet> {
  bool _isSaving = false;

  // 5 Premium diverse skin tones
  static const List<Map<String, dynamic>> skinTones = [
    {'label': 'Light', 'hex': '#FCE2C8', 'color': Color(0xFFFCE2C8)},
    {'label': 'Fair', 'hex': '#F1C27D', 'color': Color(0xFFF1C27D)},
    {'label': 'Olive', 'hex': '#E0AC69', 'color': Color(0xFFE0AC69)},
    {'label': 'Honey', 'hex': '#C68642', 'color': Color(0xFFC68642)},
    {'label': 'Espresso', 'hex': '#8D5524', 'color': Color(0xFF8D5524)},
  ];

  @override
  Widget build(BuildContext context) {
    final todayState = ref.watch(todayNotifierProvider);
    final profile = todayState.userProfile;
    final selectedHex = ref.watch(avatarSelectedSkinToneProvider);

    // Auto-fetched demographic parameters
    final heightCm = profile?.heightCm?.round() ?? 175;
    final weightKg = profile?.weightKg?.round() ?? 70;
    final gender = (profile?.biologicalSex.isNotEmpty == true &&
            profile?.biologicalSex != 'unspecified')
        ? profile!.biologicalSex[0].toUpperCase() +
            profile.biologicalSex.substring(1)
        : 'Biological Baseline';

    // Calculate BMI
    final heightM = heightCm / 100.0;
    final bmi = (weightKg / (heightM * heightM)).toStringAsFixed(1);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFC1C8C4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header: Serif Typography
          const Text(
            'Meet Your Companion',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00251D),
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your companion actively mirrors your biological baseline and responds to real-time environmental telemetry.',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13.5,
              color: Color(0xFF4F6359),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),

          // Dynamic Display: Silhouette Placeholder & Auto-Fetched Metadata
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF0EC), // #EAF0EC sage green cards
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD5E2D8)),
            ),
            child: Row(
              children: [
                // Living Avatar live preview (72x72px)
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF0A2E1F),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Consumer(
                      builder: (context, modalRef, _) {
                        final scene = modalRef.watch(livingAvatarControllerProvider);
                        final previewScene = scene.copyWith(
                          identity: scene.identity.copyWith(skinToneHex: selectedHex),
                        );
                        return LivingAvatarView(
                          scene: previewScene,
                          size: 72,
                          enableAnimation: false,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Auto-Fetched Telemetry Badges
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CALIBRATED TO YOUR PROFILE',
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF00251D).withOpacity(0.7),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _buildDemographicChip('$heightCm cm'),
                          _buildDemographicChip('$weightKg kg'),
                          _buildDemographicChip('BMI $bmi'),
                          _buildDemographicChip(gender),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Skin Tone Selection Title
          const Text(
            'COMPLEXION BASELINE',
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF00251D),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),

          // Row of 5 Premium Circular ChoiceChips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: skinTones.map((item) {
              final hex = item['hex'] as String;
              final color = item['color'] as Color;
              final isSelected = selectedHex == hex;

              return ChoiceChip(
                label: const SizedBox.shrink(),
                selected: isSelected,
                padding: EdgeInsets.zero,
                labelPadding: EdgeInsets.zero,
                shape: const CircleBorder(),
                backgroundColor: color,
                selectedColor: color,
                side: BorderSide(
                  color: isSelected ? const Color(0xFF0A2E1F) : Colors.white,
                  width: isSelected ? 3.0 : 1.5,
                ),
                avatar: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 18,
                        color: Color(0xFF0A2E1F),
                      )
                    : null,
                onSelected: (val) {
                  ref.read(avatarSelectedSkinToneProvider.notifier).state = hex;
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 26),

          // Action Button: Dark Green "Create Avatar"
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A2E1F), // Dark green #0A2E1F
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: _isSaving ? null : () => _handleCreateAvatar(selectedHex),
              child: _isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.auto_awesome, size: 20, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Create Avatar',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
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

  Widget _buildDemographicChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD5E2D8)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF00251D),
        ),
      ),
    );
  }

  Future<void> _handleCreateAvatar(String skinTone) async {
    setState(() => _isSaving = true);
    try {
      final success = await ref
          .read(todayNotifierProvider.notifier)
          .updateAvatar(skinTone: skinTone);

      if (mounted) {
        Navigator.of(context).pop();
        if (success) {
          ref.read(livingAvatarControllerProvider.notifier).updateSkinTone(skinTone);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your companion has been created and synced.'),
              backgroundColor: Color(0xFF0A2E1F),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating avatar: $e'),
            backgroundColor: const Color(0xFFBA1A1A),
          ),
        );
      }
    }
  }
}
