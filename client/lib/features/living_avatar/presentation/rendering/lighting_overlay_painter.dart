// ==============================================================================
// Nutrient Earth — Lighting & Atmospheric Weather Overlay Painter
// Renders directional solar/lunar lighting washes, ambient depth vignette,
// and procedural weather particles (rain, mist, snow, evening fireflies).
// ==============================================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/entities/world_state.dart';

class LightingOverlayPainter extends CustomPainter {
  final WorldState world;
  final double animationTimeSeconds;

  const LightingOverlayPainter({
    required this.world,
    required this.animationTimeSeconds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.width / 2.0;

    // 1. Directional Solar / Lunar Light Wash
    _paintDirectionalLightWash(canvas, size, rect);

    // 2. Weather Particles (Rain, Snow, Mist, Fireflies)
    _paintWeatherParticles(canvas, size);

    // 3. Perimeter Ambient Occlusion & Glass Vignette
    _paintPerimeterVignette(canvas, center, radius);
  }

  void _paintDirectionalLightWash(Canvas canvas, Size size, Rect rect) {
    final lighting = world.lighting;
    final astronomy = world.astronomy;

    // Determine light direction vector from azimuth (azimuth 0 = North/Up, 90 = East/Right, 180 = South/Down, 270 = West/Left)
    final double lightAzimuthRad = (astronomy.solarAltitude > -6.0 ? astronomy.solarAzimuth : astronomy.lunarAzimuth) * math.pi / 180.0;
    final Alignment lightSourceAlignment = Alignment(
      math.sin(lightAzimuthRad) * 0.9,
      -math.cos(lightAzimuthRad) * 0.9,
    );

    final lightPaint = Paint()
      ..shader = RadialGradient(
        center: lightSourceAlignment,
        radius: 1.2,
        colors: [
          lighting.ambientWashColor.withValues(alpha: (lighting.lightIntensity * 0.28).clamp(0.0, 0.45)),
          lighting.ambientWashColor.withValues(alpha: 0.0),
        ],
      ).createShader(rect)
      ..blendMode = BlendMode.softLight;

    canvas.drawRect(rect, lightPaint);
  }

  void _paintWeatherParticles(Canvas canvas, Size size) {
    final weather = world.weather;

    if (weather.isRaining) {
      _paintRain(canvas, size, weather.rainIntensity);
    } else if (weather.isSnowing) {
      _paintSnow(canvas, size);
    } else if (weather.fogDensity > 0.15) {
      _paintMistHaze(canvas, size, weather.fogDensity);
    } else if (world.astronomy.isNight && world.weather.cloudCoverFraction < 0.4) {
      // Clear nocturnal sky: draw subtle bio-luminescent fireflies / motes
      _paintFireflies(canvas, size);
    }
  }

  void _paintRain(Canvas canvas, Size size, double intensity) {
    final rainPaint = Paint()
      ..color = const Color(0xC0D6E6F2)
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;

    final int dropCount = (14 * intensity.clamp(0.2, 1.0)).toInt().clamp(6, 20);
    final double angleRad = (75.0 + math.sin(animationTimeSeconds * 0.5) * 5.0) * math.pi / 180.0;
    final double dx = math.cos(angleRad) * 9.0;
    final double dy = math.sin(angleRad) * 9.0;

    for (int i = 0; i < dropCount; i++) {
      final double seed = i * 47.19;
      final double x0 = ((seed + animationTimeSeconds * 65.0) % size.width);
      final double y0 = ((seed * 1.73 + animationTimeSeconds * 220.0) % size.height);

      canvas.drawLine(
        Offset(x0, y0),
        Offset(x0 + dx, y0 + dy),
        rainPaint,
      );
    }
  }

  void _paintSnow(Canvas canvas, Size size) {
    final snowPaint = Paint()
      ..color = const Color(0xEEFFFFFF)
      ..style = PaintingStyle.fill;

    const int flakeCount = 14;
    for (int i = 0; i < flakeCount; i++) {
      final double seed = i * 29.3;
      final double sway = math.sin(animationTimeSeconds * 1.5 + seed) * 4.0;
      final double x = ((seed * 3.7 + sway) % size.width);
      final double y = ((seed * 2.1 + animationTimeSeconds * 28.0) % size.height);
      final double flakeRadius = 0.8 + (i % 3) * 0.5;

      canvas.drawCircle(Offset(x, y), flakeRadius, snowPaint);
    }
  }

  void _paintMistHaze(Canvas canvas, Size size, double density) {
    final mistPaint = Paint()
      ..color = Color.lerp(
        const Color(0x35E0EAE5),
        const Color(0x559FA8A3),
        density.clamp(0.0, 1.0),
      )!
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final double mistOffset = math.sin(animationTimeSeconds * 0.4) * 6.0;
    final path = Path()
      ..moveTo(-10, size.height * 0.55 + mistOffset)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.45 - mistOffset,
        size.width + 10,
        size.height * 0.6 + mistOffset,
      )
      ..lineTo(size.width + 10, size.height + 10)
      ..lineTo(-10, size.height + 10)
      ..close();

    canvas.drawPath(path, mistPaint);
  }

  void _paintFireflies(Canvas canvas, Size size) {
    final glowPaint = Paint()..style = PaintingStyle.fill;

    const int fireflyCount = 6;
    for (int i = 0; i < fireflyCount; i++) {
      final double seed = i * 71.3;
      final double phase = animationTimeSeconds * 1.8 + seed;
      final double brightness = (math.sin(phase) * 0.5 + 0.5); // 0.0 to 1.0 pulse

      if (brightness < 0.15) continue;

      final double x = size.width * 0.2 + (math.cos(animationTimeSeconds * 0.35 + seed) * 0.5 + 0.5) * (size.width * 0.6);
      final double y = size.height * 0.4 + (math.sin(animationTimeSeconds * 0.25 + seed * 1.5) * 0.5 + 0.5) * (size.height * 0.5);

      // Soft glowing aura
      glowPaint.color = const Color(0xFFC7EBB3).withValues(alpha: brightness * 0.5);
      canvas.drawCircle(Offset(x, y), 2.8, glowPaint);

      // Core spark
      glowPaint.color = const Color(0xFFFAFFE6).withValues(alpha: brightness * 0.95);
      canvas.drawCircle(Offset(x, y), 1.0, glowPaint);
    }
  }

  void _paintPerimeterVignette(Canvas canvas, Offset center, double radius) {
    // Elegant deep green ambient vignette around perimeter for photographic depth
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: const [
          Color(0x000A2E1F),
          Color(0x040A2E1F),
          Color(0x180A2E1F),
          Color(0x380A2E1F),
        ],
        stops: const [0.0, 0.70, 0.90, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, vignettePaint);

    // Rim highlight for subtle glass depth
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = const Color(0x28FFFFFF);
    canvas.drawCircle(center, radius - 0.5, rimPaint);
  }

  @override
  bool shouldRepaint(covariant LightingOverlayPainter oldDelegate) {
    return oldDelegate.animationTimeSeconds != animationTimeSeconds ||
        oldDelegate.world != world;
  }
}
