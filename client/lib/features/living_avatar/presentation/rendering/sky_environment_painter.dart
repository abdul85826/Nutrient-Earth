// ==============================================================================
// Nutrient Earth — Sky & Celestial Environment Painter
// Real-time atmospheric sky rendering: continuous diurnal sky gradients,
// solar trajectory, moon disc with accurate phase mask, and twinkling stars.
// ==============================================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/entities/world_state.dart';
import '../../domain/entities/astronomical_state.dart';

class SkyEnvironmentPainter extends CustomPainter {
  final WorldState world;
  final double animationTimeSeconds;

  const SkyEnvironmentPainter({
    required this.world,
    required this.animationTimeSeconds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.width / 2.0;

    // 1. Sky Gradient Background
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          world.lighting.skyColorTop,
          world.lighting.skyColorBottom,
        ],
      ).createShader(rect);
    canvas.drawCircle(center, radius, skyPaint);

    // 2. Stars (Visible during twilight & night)
    if (world.lighting.starVisibility > 0.05) {
      _drawStars(canvas, size, world.lighting.starVisibility, animationTimeSeconds);
    }

    // 3. Sun Disc (when altitude > -8°)
    final solar = world.astronomy;
    if (solar.solarAltitude > -8.0) {
      _drawSun(canvas, size, solar.solarAltitude, solar.solarAzimuth, world.lighting);
    }

    // 4. Moon Disc (when above horizon or in twilight)
    if (solar.isMoonAboveHorizon || solar.lunarAltitude > -10.0) {
      _drawMoon(canvas, size, solar);
    }

    // 5. Atmospheric Horizon Glow / Soft Mist
    final horizonPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.bottomCenter,
        radius: 0.9,
        colors: [
          world.lighting.directionalLightColor.withValues(alpha: 0.25 * world.lighting.lightIntensity),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawCircle(center, radius, horizonPaint);
  }

  void _drawStars(Canvas canvas, Size size, double visibility, double time) {
    final starPaint = Paint()..color = Colors.white;

    // Deterministic pseudo-random star field (24 stars)
    const starCoords = [
      Offset(0.25, 0.15), Offset(0.70, 0.12), Offset(0.45, 0.22),
      Offset(0.18, 0.32), Offset(0.82, 0.25), Offset(0.35, 0.10),
      Offset(0.60, 0.18), Offset(0.15, 0.20), Offset(0.88, 0.35),
      Offset(0.50, 0.30), Offset(0.28, 0.40), Offset(0.75, 0.42),
      Offset(0.38, 0.06), Offset(0.65, 0.08), Offset(0.52, 0.15),
      Offset(0.12, 0.10), Offset(0.85, 0.15), Offset(0.30, 0.26),
      Offset(0.72, 0.30), Offset(0.42, 0.36), Offset(0.20, 0.45),
      Offset(0.80, 0.48), Offset(0.58, 0.25), Offset(0.10, 0.38),
    ];

    for (int i = 0; i < starCoords.length; i++) {
      final base = starCoords[i];
      // Subtle organic twinkle
      final twinkle = 0.65 + 0.35 * math.sin(time * 2.5 + i * 1.7);
      final alpha = (visibility * twinkle).clamp(0.0, 1.0);
      starPaint.color = Colors.white.withValues(alpha: alpha);

      final px = base.dx * size.width;
      final py = base.dy * size.height;
      final starRadius = (i % 3 == 0) ? 1.2 : 0.8;
      canvas.drawCircle(Offset(px, py), starRadius, starPaint);
    }
  }

  void _drawSun(Canvas canvas, Size size, double altitude, double azimuth, AmbientLightingState lighting) {
    // Map altitude and azimuth into 2D circle coordinates
    // Solar altitude: 0° is at horizon (y ≈ 0.65*h), 90° is at zenith (y ≈ 0.15*h)
    final double normalizedAlt = (altitude / 90.0).clamp(-0.1, 1.0);
    final double sunY = size.height * (0.65 - normalizedAlt * 0.48);
    // Azimuth: East (90°) on right, South (180°) center, West (270°) left
    final double sunX = size.width * (0.5 + 0.38 * math.sin((azimuth - 180.0) * math.pi / 180.0));

    final sunCenter = Offset(sunX, sunY);
    final double sunRadius = (altitude <= 10.0) ? 12.0 : 9.5;

    // Atmospheric Solar Corona / Glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          lighting.directionalLightColor.withValues(alpha: 0.6 * lighting.lightIntensity),
          lighting.directionalLightColor.withValues(alpha: 0.15 * lighting.lightIntensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: sunRadius * 3.5));
    canvas.drawCircle(sunCenter, sunRadius * 3.5, glowPaint);

    // Sun Disc Core
    final discPaint = Paint()
      ..color = lighting.directionalLightColor.withValues(alpha: 0.95);
    canvas.drawCircle(sunCenter, sunRadius, discPaint);
  }

  void _drawMoon(Canvas canvas, Size size, WorldAstronomyState astronomy) {
    final double alt = astronomy.lunarAltitude;
    if (alt < -5.0) return;

    final double normalizedAlt = (alt / 90.0).clamp(0.0, 1.0);
    final double moonY = size.height * (0.60 - normalizedAlt * 0.42);
    final double moonX = size.width * (0.5 + 0.36 * math.sin((astronomy.lunarAzimuth - 180.0) * math.pi / 180.0));
    final moonCenter = Offset(moonX, moonY);
    const double moonRadius = 8.5;

    // Soft Lunar Corona
    final coronaPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFE8F4F0).withValues(alpha: 0.35 * astronomy.lunarIllumination),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: moonCenter, radius: moonRadius * 2.8));
    canvas.drawCircle(moonCenter, moonRadius * 2.8, coronaPaint);

    // Dark side base disc
    final darkDiscPaint = Paint()..color = const Color(0xFF1E332E);
    canvas.drawCircle(moonCenter, moonRadius, darkDiscPaint);

    // Illuminated Crescent / Phase
    final moonIlluminatedPaint = Paint()..color = const Color(0xFFF4FBF8);

    if (astronomy.lunarIllumination > 0.90) {
      // Full Moon
      canvas.drawCircle(moonCenter, moonRadius, moonIlluminatedPaint);
    } else if (astronomy.lunarIllumination < 0.10) {
      // New Moon (barely visible dark limb)
      final rimPaint = Paint()
        ..color = const Color(0x33A0C4B8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;
      canvas.drawCircle(moonCenter, moonRadius, rimPaint);
    } else {
      // Crescent / Gibbous Phase Mask
      canvas.save();
      final path = Path()..addOval(Rect.fromCircle(center: moonCenter, radius: moonRadius));
      canvas.clipPath(path);

      final double offsetFraction = (1.0 - astronomy.lunarIllumination * 2.0) * moonRadius;
      final phasePath = Path()
        ..addOval(Rect.fromCenter(
          center: Offset(moonCenter.dx + offsetFraction, moonCenter.dy),
          width: moonRadius * 2.0 * astronomy.lunarIllumination,
          height: moonRadius * 2.0,
        ));
      canvas.drawPath(phasePath, moonIlluminatedPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant SkyEnvironmentPainter oldDelegate) {
    return oldDelegate.world != world ||
        (oldDelegate.animationTimeSeconds - animationTimeSeconds).abs() > 0.05;
  }
}
