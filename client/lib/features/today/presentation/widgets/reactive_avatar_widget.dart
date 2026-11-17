// ==============================================================================
// Nutrient Earth — Reactive Circadian Avatar Engine & Creation Modal
// Strict Ralph Graph Unidirectional Flow & CodeRabbit Null Safety
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../profile/presentation/widgets/avatar_state_switcher.dart';

export '../../../profile/presentation/widgets/avatar_state_switcher.dart';

final avatarSkinToneProvider = StateProvider<Color>((ref) => const Color(0xFFE0AC69));
final isAvatarCreatedProvider = StateProvider<bool>((ref) => false);

class ReactiveAvatarWidget extends ConsumerWidget {
  const ReactiveAvatarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AvatarStateSwitcher(size: 110.0);
  }
}

  Widget _buildCreateAvatarPrompt(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openCreationModal(context, ref),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.accessibility_new_rounded,
              size: 26,
              color: Color(0xFF0B2B26),
            ),
            SizedBox(height: 3),
            Text(
              'Create\nAvatar',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0B2B26),
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _deriveAmbientBg(double temp) {
    if (temp >= 28) return const Color(0xFFFBECE6); // Warm terracotta tint
    if (temp <= 16) return const Color(0xFFE8F2F5); // Crisp cool tint
    return const Color(0xFFE2EDE5); // Baseline sage green
  }

  void _openCreationModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFBF9F4),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => const _AvatarCreationBottomSheet(),
    );
  }
}

class _AvatarCreationBottomSheet extends ConsumerWidget {
  const _AvatarCreationBottomSheet();

  static const skinTones = [
    Color(0xFFFFDFC4),
    Color(0xFFF0D5BE),
    Color(0xFFEECEB3),
    Color(0xFFE0AC69),
    Color(0xFFC68642),
    Color(0xFF8D5524),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTone = ref.watch(avatarSkinToneProvider);
    final profile = ref.watch(todayNotifierProvider).userProfile;

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
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFC1C8C4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Create Your Health Avatar',
            style: TextStyle(
              fontFamily: 'Newsreader',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF051F20),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'We automatically mapped your profile baseline. Choose your complexion tone to activate real-time telemetry animation.',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              color: Color(0xFF4F6359),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Synced Profile Tags (Height / Weight / Routine)
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildMetricChip('Height', '${profile?.heightCm?.round() ?? 175} cm'),
              _buildMetricChip('Weight', '${profile?.weightKg?.round() ?? 70} kg'),
              _buildMetricChip('Activity', profile?.activityLevel ?? 'Moderate'),
            ],
          ),

          const SizedBox(height: 20),
          const Text(
            'SELECT SKIN TONE',
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF051F20),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: skinTones.map((tone) {
              final isSelected = selectedTone.value == tone.value;
              return GestureDetector(
                onTap: () => ref.read(avatarSkinToneProvider.notifier).state = tone,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: tone,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF0B2B26) : Colors.white,
                      width: isSelected ? 3 : 1.5,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B2B26),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: () {
                ref.read(isAvatarCreatedProvider.notifier).state = true;
                Navigator.of(context).pop();
              },
              child: const Text(
                'Generate Live Character Rig',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF5F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E9E2)),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF166534),
        ),
      ),
    );
  }
}

/// 60fps Parametric Avatar Rig Painter
class AvatarRigPainter extends CustomPainter {
  final Color skinTone;
  final int hour;
  final int aqi;

  const AvatarRigPainter({
    required this.skinTone,
    required this.hour,
    required this.aqi,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // 1. Posture offset calculation according to circadian rhythm
    double headYOffset = 0;
    if (hour >= 5 && hour < 12) {
      headYOffset = -2; // Morning uplifted alert posture
    } else if (hour >= 20 || hour < 5) {
      headYOffset = 2; // Evening restful relaxation
    }

    // 2. High AQI Protective Aura or Clear Radiance
    if (aqi > 100) {
      final alertPaint = Paint()
        ..color = const Color(0x33C62828)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(Offset(cx, cy), size.width / 2 - 3, alertPaint);
    } else {
      final vitalityPaint = Paint()
        ..color = const Color(0x33166534)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(cx, cy), size.width / 2 - 3, vitalityPaint);
    }

    final skinPaint = Paint()..color = skinTone;
    final clothingPaint = Paint()..color = const Color(0xFF1A3B32);

    // Torso / Shoulders
    final torsoPath = Path()
      ..moveTo(cx - 28, size.height)
      ..quadraticBezierTo(cx - 20, cy + 14 + headYOffset, cx, cy + 14 + headYOffset)
      ..quadraticBezierTo(cx + 20, cy + 14 + headYOffset, cx + 28, size.height)
      ..close();
    canvas.drawPath(torsoPath, clothingPaint);

    // Neck
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(cx, cy + 6 + headYOffset),
        width: 14,
        height: 12,
      ),
      skinPaint,
    );

    // Head
    canvas.drawCircle(Offset(cx, cy - 8 + headYOffset), 20, skinPaint);

    // Hair Cap
    final hairPaint = Paint()..color = const Color(0xFF2C1B18);
    final hairPath = Path()
      ..addArc(
        Rect.fromCircle(center: Offset(cx, cy - 8 + headYOffset), radius: 21),
        3.14159,
        3.14159,
      );
    canvas.drawPath(hairPath, hairPaint);
  }

  @override
  bool shouldRepaint(covariant AvatarRigPainter oldDelegate) =>
      oldDelegate.skinTone != skinTone ||
      oldDelegate.hour != hour ||
      oldDelegate.aqi != aqi;
}
