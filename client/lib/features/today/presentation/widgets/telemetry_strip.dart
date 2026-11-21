import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../../../core/services/telemetry_service.dart';

class TelemetryStrip extends StatelessWidget {
  final TelemetryData telemetry;
  final VoidCallback? onRefresh;

  const TelemetryStrip({
    super.key,
    required this.telemetry,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(NETokens.radiusMd),
        border: Border.all(color: NETokens.borderDefault),
        boxShadow: NETokens.cardShadow,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 12.0),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // 1. Solar / Time
            Expanded(
              child: _buildColumn(
                icon: Icons.wb_sunny_outlined,
                iconColor: NETokens.solarAmber,
                iconBg: NETokens.solarAmberBg,
                value: telemetry.formattedTime,
                label: telemetry.solarCondition,
              ),
            ),
            const VerticalDivider(color: NETokens.borderSubtle, thickness: 1, width: 1),

            // 2. AQI
            Expanded(
              child: _buildColumn(
                icon: Icons.eco_outlined,
                iconColor: NETokens.aqiGreen,
                iconBg: NETokens.aqiGreenBg,
                valueWidget: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${telemetry.aqi}',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: NETokens.primary,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: NETokens.aqiGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                label: telemetry.aqiLabel,
              ),
            ),
            const VerticalDivider(color: NETokens.borderSubtle, thickness: 1, width: 1),

            // 3. Weather
            Expanded(
              child: _buildColumn(
                icon: Icons.cloud_outlined,
                iconColor: NETokens.weatherTeal,
                iconBg: NETokens.weatherTealBg,
                value: telemetry.formattedTemperature,
                label: telemetry.weatherCondition,
              ),
            ),
            const VerticalDivider(color: NETokens.borderSubtle, thickness: 1, width: 1),

            // 4. Streak
            Expanded(
              child: _buildColumn(
                icon: Icons.local_fire_department_rounded,
                iconColor: NETokens.streakFlame,
                iconBg: NETokens.streakFlameBg,
                value: '${telemetry.streakDays} days',
                label: telemetry.streakLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColumn({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    String? value,
    Widget? valueWidget,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 14),
        ),
        const SizedBox(height: 5),
        if (valueWidget != null)
          valueWidget
        else
          Text(
            value ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: NETokens.primary,
              height: 1.1,
            ),
          ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: NETokens.textMuted,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}
