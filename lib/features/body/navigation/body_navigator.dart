import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../config/body_platform_config.dart';

class BodyNavigator {
  BodyNavigator._();

  static void showOrganDetail(BuildContext context, String organKey, String displayName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: NEColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (!BodyPlatformConfig.enableBiologyEngine) ...[
                // Biology module coming soon placeholder state
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.lock_clock, color: NEColors.accent, size: 48),
                      SizedBox(height: 12),
                      Text(
                        'Biology Module Coming Soon',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'The biological modeling engine and organ-level analysis for this anatomy node is currently in development.',
                        style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Real biology rendering (mock detail for platform placeholder fallback)
                Text(
                  'Anatomy node: $organKey is fully active. Biological health parameters and metrics analysis are loaded.',
                  style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
