import 'package:flutter/material.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import 'health_sync_card.dart';

/// Modal bottom sheet showcasing native health synchronization.
Future<void> showHealthSyncModal(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.only(
        left: NETokens.space16,
        right: NETokens.space16,
        top: NETokens.space16,
        bottom: MediaQuery.of(context).viewInsets.bottom + NETokens.space24,
      ),
      decoration: BoxDecoration(
        color: NETokens.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(NETokens.radiusLg),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: NETokens.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: NETokens.space16),

              // Title & Description
              const Text(
                'Native Health Sync',
                style: TextStyle(
                  fontFamily: 'Fraunces',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: NETokens.deepestForest,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Seamlessly synchronizes steps, workouts, heart rate, and sleep from your device hardware into your evidence intelligence profile.',
                style: TextStyle(
                  fontSize: 13,
                  color: NETokens.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: NETokens.space16),

              // Health Sync Card
              const HealthSyncCard(),
            ],
          ),
        ),
      ),
    ),
  );
}
