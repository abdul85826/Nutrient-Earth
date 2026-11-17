// ==============================================================================
// Nutrient Earth — Live 4-Pillar Telemetry Strip Widget
// Open-Meteo Weather + Reactive AQI Canvas Gauge + Circadian Solar Stream
// Strict Ralph Graph Unidirectional Flow & CodeRabbit Null Safety
// ==============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../today/state/today_state.dart';

/// 1-Second Periodic Stream for Live Device Clock & Circadian Transitions
final liveClockProvider = StreamProvider.autoDispose<DateTime>((ref) {
  final controller = StreamController<DateTime>();
  controller.add(DateTime.now());
  final timer = Timer.periodic(const Duration(seconds: 1), (_) {
    controller.add(DateTime.now());
  });
  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });
  return controller.stream;
});

class LiveTelemetryStripWidget extends ConsumerWidget {
  const LiveTelemetryStripWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayState = ref.watch(todayNotifierProvider);
    final telemetry = todayState.telemetry;
    final nowAsync = ref.watch(liveClockProvider);
    final now = nowAsync.value ?? DateTime.now();
    final timeStr = DateFormat('h:mm a').format(now);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E9E2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080B2B26),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Row(
        children: [
          // 1. Solar / Circadian Clock Column
          Expanded(
            child: _TelemetryColumn(
              iconBgColor: const Color(0xFFFEF9EC),
              icon: const Icon(
                Icons.wb_sunny_rounded,
                size: 15,
                color: Color(0xFFD97706),
              ),
              primaryText: timeStr,
              secondaryText: _deriveSolarState(now),
            ),
          ),
          const _VerticalDivider(),

          // 2. Live AQI Visual Gauge Column
          Expanded(
            child: _TelemetryColumn(
              iconBgColor: const Color(0xFFEEF5F0),
              customIcon: SizedBox(
                width: 20,
                height: 20,
                child: CustomPaint(
                  painter: AqiGaugePainter(aqi: telemetry.aqi),
                ),
              ),
              primaryText: telemetry.aqi > 0 ? '${telemetry.aqi}' : '--',
              badgeColor: _deriveAqiColor(telemetry.aqi),
              secondaryText: telemetry.aqiLabel.isNotEmpty
                  ? telemetry.aqiLabel
                  : 'Awaiting sync',
            ),
          ),
          const _VerticalDivider(),

          // 3. Local Weather Column
          Expanded(
            child: _TelemetryColumn(
              iconBgColor: const Color(0xFFF3F7F5),
              icon: Icon(
                _deriveWeatherIcon(telemetry.weatherCondition),
                size: 15,
                color: const Color(0xFF166534),
              ),
              primaryText: telemetry.temperatureCelsius > 0
                  ? '${telemetry.temperatureCelsius.round()}°C'
                  : '--°C',
              secondaryText: telemetry.weatherCondition.isNotEmpty
                  ? telemetry.weatherCondition
                  : 'Updating...',
            ),
          ),
          const _VerticalDivider(),

          // 4. Longitudinal Streak Column
          Expanded(
            child: _TelemetryColumn(
              iconBgColor: const Color(0xFFFAF0EB),
              icon: const Icon(
                Icons.local_fire_department_rounded,
                size: 15,
                color: Color(0xFFC85A32),
              ),
              primaryText: telemetry.streakDays > 0
                  ? '${telemetry.streakDays} days'
                  : '1 day',
              secondaryText: telemetry.streakLabel.isNotEmpty
                  ? telemetry.streakLabel
                  : 'Keep going',
            ),
          ),
        ],
      ),
    );
  }

  static String _deriveSolarState(DateTime time) {
    final hour = time.hour;
    if (hour >= 5 && hour < 9) return 'Sunrise';
    if (hour >= 9 && hour < 16) return 'Radiant';
    if (hour >= 16 && hour < 19) return 'Golden Hour';
    return 'Restful Night';
  }

  static Color _deriveAqiColor(int aqi) {
    if (aqi <= 50) return const Color(0xFF2E7D32); // Green
    if (aqi <= 100) return const Color(0xFFF9A825); // Moderate Amber
    return const Color(0xFFC62828); // Sensitive / Unhealthy Red
  }

  static IconData _deriveWeatherIcon(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('rain') || c.contains('shower')) return Icons.grain_rounded;
    if (c.contains('cloud')) return Icons.cloud_rounded;
    if (c.contains('clear') || c.contains('sun')) return Icons.wb_sunny_rounded;
    return Icons.cloud_queue_rounded;
  }
}

class _TelemetryColumn extends StatelessWidget {
  final Color iconBgColor;
  final Widget? icon;
  final Widget? customIcon;
  final String primaryText;
  final String secondaryText;
  final Color? badgeColor;

  const _TelemetryColumn({
    required this.iconBgColor,
    this.icon,
    this.customIcon,
    required this.primaryText,
    required this.secondaryText,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: customIcon ?? icon,
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              primaryText,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF051F20),
                height: 1.1,
              ),
            ),
            if (badgeColor != null) ...[
              const SizedBox(width: 3),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          secondaryText,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Color(0xFF7D8F85),
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 38,
      color: const Color(0xFFECEFEA),
    );
  }
}

/// Custom 60fps Canvas Painter for the Dynamic AQI Leaf & Ring Indicator
class AqiGaugePainter extends CustomPainter {
  final int aqi;

  const AqiGaugePainter({required this.aqi});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    Color gaugeColor;
    if (aqi <= 50) {
      gaugeColor = const Color(0xFF2E7D32);
    } else if (aqi <= 100) {
      gaugeColor = const Color(0xFFF9A825);
    } else {
      gaugeColor = const Color(0xFFC62828);
    }

    final bgPaint = Paint()
      ..color = gaugeColor.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    canvas.drawCircle(center, radius, bgPaint);

    final sweepAngle = (aqi.clamp(0, 300) / 300) * 2 * 3.14159265;
    final arcPaint = Paint()
      ..color = gaugeColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.5;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159265 / 2,
      sweepAngle,
      false,
      arcPaint,
    );

    // Inner Botanical Leaf Node
    final leafPaint = Paint()..color = gaugeColor;
    final leafPath = Path()
      ..moveTo(center.dx, center.dy - 4)
      ..quadraticBezierTo(center.dx + 4, center.dy, center.dx, center.dy + 4)
      ..quadraticBezierTo(center.dx - 4, center.dy, center.dx, center.dy - 4);
    canvas.drawPath(leafPath, leafPaint);
  }

  @override
  bool shouldRepaint(covariant AqiGaugePainter oldDelegate) =>
      oldDelegate.aqi != aqi;
}
