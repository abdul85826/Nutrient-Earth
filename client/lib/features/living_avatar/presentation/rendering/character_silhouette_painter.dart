// ==============================================================================
// Nutrient Earth — Character Silhouette & Vitality Painter
// Renders the permanent, immutable character identity with procedural vitality:
// sinusoidal breathing, irregular natural blinks, facial expressions, and props.
// ==============================================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/entities/avatar_identity.dart';
import '../../domain/entities/avatar_appearance.dart';
import '../../domain/entities/avatar_behaviour.dart';
import '../../domain/entities/world_state.dart';

class CharacterSilhouettePainter extends CustomPainter {
  final AvatarIdentity identity;
  final AvatarAppearance appearance;
  final AvatarBehaviour behaviour;
  final WorldState world;
  final double animationTimeSeconds;

  const CharacterSilhouettePainter({
    required this.identity,
    required this.appearance,
    required this.behaviour,
    required this.world,
    required this.animationTimeSeconds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2.0;
    final cy = size.height / 2.0;

    // 1. Procedural Breathing Kinematics
    // Natural sinusoidal respiratory movement
    final double breathingPeriodSeconds = 60.0 / behaviour.breathingRateBpm;
    final double breathingPhase = (animationTimeSeconds % breathingPeriodSeconds) / breathingPeriodSeconds;
    // Inhalation is slightly shorter than exhalation (natural 1:1.3 ratio)
    final double breathCycle = math.sin(breathingPhase * 2.0 * math.pi);
    final double chestYOffset = -breathCycle * 1.8; // Chest expands upward by up to 1.8px
    final double shoulderWidthExpansion = breathCycle * 0.8;

    // 2. Procedural Natural Blinking Cycle
    // Blinks every ~4s with a 140ms duration
    final double blinkCycleDuration = behaviour.blinkFrequencySeconds;
    final double timeInBlinkCycle = animationTimeSeconds % blinkCycleDuration;
    bool isBlinking = timeInBlinkCycle < 0.14 && behaviour.gaze != EyeGazeState.softlyClosed;
    if (behaviour.gaze == EyeGazeState.softlyClosed) {
      isBlinking = true;
    }

    // 3. Head Tilt & Micro-Saccade
    final double headTiltRad = (behaviour.headTiltDegrees + math.sin(animationTimeSeconds * 0.3) * 0.8) * math.pi / 180.0;

    // Resolve Colors
    final Color skinColor = _parseColor(identity.skinToneHex, const Color(0xFFE0AC69));
    final Color shadowSkinColor = Color.lerp(skinColor, const Color(0xFF1B2C24), 0.22)!;
    final Color hairColor = _parseColor(identity.hairColorHex, const Color(0xFF1B1C19));
    final Color clothingColor = _parseColor(appearance.clothingColorHex, const Color(0xFF0B2B26));
    final Color eyeColor = _parseColor(identity.eyeColorHex, const Color(0xFF2C1E14));

    // 4. Draw Torso & Clothing
    _drawTorso(
      canvas: canvas,
      cx: cx,
      cy: cy,
      size: size,
      chestYOffset: chestYOffset,
      shoulderExpansion: shoulderWidthExpansion,
      clothingColor: clothingColor,
      clothing: appearance.clothing,
    );

    // 5. Draw Neck & Throat
    _drawNeck(
      canvas: canvas,
      cx: cx,
      cy: cy,
      chestYOffset: chestYOffset,
      skinColor: skinColor,
      shadowSkinColor: shadowSkinColor,
    );

    // 6. Draw Head & Face with Head Tilt
    canvas.save();
    canvas.translate(cx, cy - 8.0 + chestYOffset * 0.4);
    canvas.rotate(headTiltRad);

    _drawHeadAndFace(
      canvas: canvas,
      identity: identity,
      behaviour: behaviour,
      skinColor: skinColor,
      hairColor: hairColor,
      eyeColor: eyeColor,
      isBlinking: isBlinking,
      time: animationTimeSeconds,
    );

    canvas.restore();

    // 7. Draw Hand Attachments / Props
    _drawHandAttachments(
      canvas: canvas,
      cx: cx,
      cy: cy,
      size: size,
      appearance: appearance,
      time: animationTimeSeconds,
      chestYOffset: chestYOffset,
    );
  }

  void _drawTorso({
    required Canvas canvas,
    required double cx,
    required double cy,
    required Size size,
    required double chestYOffset,
    required double shoulderExpansion,
    required Color clothingColor,
    required ClothingType clothing,
  }) {
    final double leftShoulderX = cx - 36.0 * identity.shoulderWidthRatio - shoulderExpansion;
    final double rightShoulderX = cx + 36.0 * identity.shoulderWidthRatio + shoulderExpansion;
    final double shoulderY = cy + 22.0 + chestYOffset;

    final torsoPath = Path()
      ..moveTo(cx - 45.0, size.height + 4.0)
      ..lineTo(leftShoulderX, shoulderY + 4.0)
      ..quadraticBezierTo(leftShoulderX + 6.0, shoulderY - 4.0, cx - 14.0, shoulderY - 2.0)
      ..lineTo(cx + 14.0, shoulderY - 2.0)
      ..quadraticBezierTo(rightShoulderX - 6.0, shoulderY - 4.0, rightShoulderX, shoulderY + 4.0)
      ..lineTo(cx + 45.0, size.height + 4.0)
      ..close();

    final clothingPaint = Paint()..color = clothingColor;
    canvas.drawPath(torsoPath, clothingPaint);

    // Subtle clothing folds & collar styling
    final collarPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    if (clothing == ClothingType.organicKurta) {
      // Mandarin / Bandhgala vertical placket
      canvas.drawLine(Offset(cx, shoulderY - 2.0), Offset(cx, cy + 42.0), collarPaint);
      canvas.drawLine(Offset(cx - 10.0, shoulderY), Offset(cx, shoulderY + 8.0), collarPaint);
      canvas.drawLine(Offset(cx + 10.0, shoulderY), Offset(cx, shoulderY + 8.0), collarPaint);
    } else {
      // Classic tailored neckline
      final vNeckPath = Path()
        ..moveTo(cx - 12.0, shoulderY - 2.0)
        ..quadraticBezierTo(cx, shoulderY + 12.0, cx + 12.0, shoulderY - 2.0);
      canvas.drawPath(vNeckPath, collarPaint);
    }
  }

  void _drawNeck({
    required Canvas canvas,
    required double cx,
    required double cy,
    required double chestYOffset,
    required Color skinColor,
    required Color shadowSkinColor,
  }) {
    const double neckWidth = 16.0;
    const double neckHeight = 18.0;
    final neckRect = Rect.fromCenter(
      center: Offset(cx, cy + 12.0 + chestYOffset * 0.6),
      width: neckWidth,
      height: neckHeight,
    );

    // Base neck skin
    final neckPaint = Paint()..color = skinColor;
    canvas.drawRect(neckRect, neckPaint);

    // Ambient Occlusion shadow under jaw
    final shadowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [shadowSkinColor.withValues(alpha: 0.65), Colors.transparent],
      ).createShader(neckRect);
    canvas.drawRect(neckRect, shadowPaint);
  }

  void _drawHeadAndFace({
    required Canvas canvas,
    required AvatarIdentity identity,
    required AvatarBehaviour behaviour,
    required Color skinColor,
    required Color hairColor,
    required Color eyeColor,
    required bool isBlinking,
    required double time,
  }) {
    // 1. Face Oval Geometry
    double jawWidth = 18.5 * identity.jawWidthRatio;
    double headHeight = 25.0;
    if (identity.faceGeometry == FaceGeometryType.round) {
      jawWidth *= 1.08;
      headHeight *= 0.96;
    } else if (identity.faceGeometry == FaceGeometryType.angular) {
      jawWidth *= 0.94;
    }

    final facePath = Path()
      ..moveTo(-jawWidth, -4.0)
      ..quadraticBezierTo(-jawWidth * 1.05, headHeight * 0.4, 0.0, headHeight)
      ..quadraticBezierTo(jawWidth * 1.05, headHeight * 0.4, jawWidth, -4.0)
      ..quadraticBezierTo(jawWidth, -headHeight * 0.9, 0.0, -headHeight)
      ..quadraticBezierTo(-jawWidth, -headHeight * 0.9, -jawWidth, -4.0)
      ..close();

    final facePaint = Paint()..color = skinColor;
    canvas.drawPath(facePath, facePaint);

    // 2. Eyes & Eyebrows
    final double eyeSpacing = 8.5 * identity.eyeSpacingRatio;
    const double eyeY = 1.0;

    _drawEye(canvas, -eyeSpacing, eyeY, isBlinking, eyeColor, true);
    _drawEye(canvas, eyeSpacing, eyeY, isBlinking, eyeColor, false);

    // Eyebrows
    final browPaint = Paint()
      ..color = hairColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.6;

    final double browArch = (behaviour.expression == FacialExpressionType.gentleCuriosity) ? -1.2 : 0.0;
    canvas.drawLine(Offset(-eyeSpacing - 5.0, eyeY - 4.5 + browArch), Offset(-eyeSpacing + 5.0, eyeY - 4.0), browPaint);
    canvas.drawLine(Offset(eyeSpacing - 5.0, eyeY - 4.0), Offset(eyeSpacing + 5.0, eyeY - 4.5 + browArch), browPaint);

    // 3. Nose
    final nosePaint = Paint()
      ..color = Color.lerp(skinColor, const Color(0xFF1B2C24), 0.18)!
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.3;
    final nosePath = Path()
      ..moveTo(0.0, eyeY)
      ..lineTo(0.0, eyeY + 6.5)
      ..lineTo(1.8, eyeY + 7.5);
    canvas.drawPath(nosePath, nosePaint);

    // 4. Lips / Expression
    final lipPaint = Paint()
      ..color = Color.lerp(skinColor, const Color(0xFFB04A38), 0.35)!
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.6;

    final double smileCurve = (behaviour.expression == FacialExpressionType.sereneContentment ||
            behaviour.expression == FacialExpressionType.calmAwake)
        ? 1.5
        : 0.3;

    final lipPath = Path()
      ..moveTo(-4.5, eyeY + 14.0)
      ..quadraticBezierTo(0.0, eyeY + 14.0 + smileCurve, 4.5, eyeY + 14.0);
    canvas.drawPath(lipPath, lipPaint);

    // 5. Permanent Hairstyle Rig
    _drawHair(canvas, identity.hairIdentity, hairColor);
  }

  void _drawEye(Canvas canvas, double x, double y, bool isBlinking, Color irisColor, bool isLeft) {
    if (isBlinking) {
      // Closed Eye (gentle curved line)
      final closedPaint = Paint()
        ..color = const Color(0xFF2C1E14)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1.3;
      final closedPath = Path()
        ..moveTo(x - 3.8, y)
        ..quadraticBezierTo(x, y + 1.2, x + 3.8, y);
      canvas.drawPath(closedPath, closedPaint);
      return;
    }

    // Open Eye: Sclera
    final eyeBgPaint = Paint()..color = const Color(0xFFFBFBF9);
    final eyeRect = Rect.fromCenter(center: Offset(x, y), width: 7.6, height: 4.8);
    canvas.drawOval(eyeRect, eyeBgPaint);

    // Iris
    final irisPaint = Paint()..color = irisColor;
    canvas.drawCircle(Offset(x, y), 2.1, irisPaint);

    // Pupil
    final pupilPaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(x, y), 1.1, pupilPaint);

    // Corneal Specular Highlight (matching directional sun)
    final highlightPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(x + 0.7, y - 0.7), 0.6, highlightPaint);
  }

  void _drawHair(Canvas canvas, HairstyleIdentity style, Color hairColor) {
    final hairPaint = Paint()..color = hairColor;

    switch (style) {
      case HairstyleIdentity.wavyMedium:
        // Elegant wavy frame
        final hairPath = Path()
          ..moveTo(-21.0, 10.0)
          ..quadraticBezierTo(-23.0, -18.0, 0.0, -25.5)
          ..quadraticBezierTo(23.0, -18.0, 21.0, 10.0)
          ..quadraticBezierTo(16.0, 1.0, 14.0, -11.0)
          ..quadraticBezierTo(0.0, -17.0, -14.0, -11.0)
          ..quadraticBezierTo(-16.0, 1.0, -21.0, 10.0)
          ..close();
        canvas.drawPath(hairPath, hairPaint);
        break;

      case HairstyleIdentity.straightShort:
        // Clean short side-part
        final hairPath = Path()
          ..moveTo(-19.0, 2.0)
          ..quadraticBezierTo(-20.0, -20.0, 0.0, -24.0)
          ..quadraticBezierTo(20.0, -20.0, 19.0, 2.0)
          ..quadraticBezierTo(14.0, -8.0, 0.0, -14.0)
          ..quadraticBezierTo(-14.0, -8.0, -19.0, 2.0)
          ..close();
        canvas.drawPath(hairPath, hairPaint);
        break;

      case HairstyleIdentity.topKnot:
        // Top Knot / Restorative Bun
        final hairPath = Path()
          ..moveTo(-18.0, -2.0)
          ..quadraticBezierTo(-19.0, -21.0, 0.0, -24.0)
          ..quadraticBezierTo(19.0, -21.0, 18.0, -2.0)
          ..quadraticBezierTo(0.0, -14.0, -18.0, -2.0)
          ..close();
        canvas.drawPath(hairPath, hairPaint);
        // Bun
        canvas.drawCircle(const Offset(0.0, -28.0), 7.5, hairPaint);
        break;

      default:
        // Natural tapered crop
        final hairPath = Path()
          ..moveTo(-19.0, -4.0)
          ..quadraticBezierTo(-20.0, -22.0, 0.0, -24.5)
          ..quadraticBezierTo(20.0, -22.0, 19.0, -4.0)
          ..quadraticBezierTo(0.0, -14.0, -19.0, -4.0)
          ..close();
        canvas.drawPath(hairPath, hairPaint);
        break;
    }
  }

  void _drawHandAttachments({
    required Canvas canvas,
    required double cx,
    required double cy,
    required Size size,
    required AvatarAppearance appearance,
    required double time,
    required double chestYOffset,
  }) {
    // Right Hand Attachment (held slightly in foreground)
    final rightProp = appearance.rightHandAttachment;
    if (rightProp != HandAttachmentType.none) {
      final Offset propPos = Offset(cx + 28.0, cy + 32.0 + chestYOffset * 0.7);

      if (rightProp == HandAttachmentType.waterGlass) {
        // Mineral Water Glass
        final glassRect = Rect.fromCenter(center: propPos, width: 14.0, height: 20.0);
        final glassPaint = Paint()
          ..color = const Color(0x33FFFFFF)
          ..style = PaintingStyle.fill;
        canvas.drawRRect(RRect.fromRectAndRadius(glassRect, const Radius.circular(3.0)), glassPaint);

        // Water level inside (teal-blue tint)
        final waterRect = Rect.fromLTRB(glassRect.left + 1.5, glassRect.top + 5.0, glassRect.right - 1.5, glassRect.bottom - 1.5);
        final waterPaint = Paint()..color = const Color(0x66166534);
        canvas.drawRect(waterRect, waterPaint);

        final rimPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawRRect(RRect.fromRectAndRadius(glassRect, const Radius.circular(3.0)), rimPaint);
      } else if (rightProp == HandAttachmentType.herbalTeaCup) {
        // Ceramic Tea Mug with subtle steam
        final mugRect = Rect.fromCenter(center: propPos, width: 16.0, height: 14.0);
        final mugPaint = Paint()..color = const Color(0xFFF7F5EE);
        canvas.drawRRect(RRect.fromRectAndRadius(mugRect, const Radius.circular(4.0)), mugPaint);

        // Delicate steam wisps
        final steamPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.35 + 0.15 * math.sin(time * 3.0))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;
        final steamPath = Path()
          ..moveTo(propPos.dx - 2.0, propPos.dy - 8.0)
          ..quadraticBezierTo(propPos.dx - 4.0, propPos.dy - 13.0, propPos.dx - 1.0, propPos.dy - 18.0)
          ..moveTo(propPos.dx + 2.0, propPos.dy - 8.0)
          ..quadraticBezierTo(propPos.dx + 4.0, propPos.dy - 14.0, propPos.dx + 1.0, propPos.dy - 19.0);
        canvas.drawPath(steamPath, steamPaint);
      } else if (rightProp == HandAttachmentType.leatherJournal) {
        // Bound Wellness Journal
        final journalRect = Rect.fromCenter(center: propPos, width: 18.0, height: 24.0);
        final journalPaint = Paint()..color = const Color(0xFF382315);
        canvas.drawRRect(RRect.fromRectAndRadius(journalRect, const Radius.circular(2.5)), journalPaint);

        // Gold foil leaf emblem on cover
        final goldPaint = Paint()..color = const Color(0xFFD4AF37);
        canvas.drawCircle(propPos, 2.5, goldPaint);
      }
    }
  }

  static Color _parseColor(String? hex, Color fallback) {
    if (hex == null || hex.isEmpty) return fallback;
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse(clean.length == 6 ? 'FF$clean' : clean, radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  @override
  bool shouldRepaint(covariant CharacterSilhouettePainter oldDelegate) {
    return oldDelegate.identity != identity ||
        oldDelegate.appearance != appearance ||
        oldDelegate.behaviour != behaviour ||
        oldDelegate.world != world ||
        (oldDelegate.animationTimeSeconds - animationTimeSeconds).abs() > 0.03;
  }
}
