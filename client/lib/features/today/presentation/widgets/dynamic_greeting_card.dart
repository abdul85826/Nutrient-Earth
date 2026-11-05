import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../../../core/services/diurnal_service.dart';

class DynamicGreetingCard extends StatelessWidget {
  final DiurnalContext diurnal;
  final String? activeGoal;

  const DynamicGreetingCard({
    super.key,
    required this.diurnal,
    this.activeGoal,
  });

  @override
  Widget build(BuildContext context) {
    final goalSubtext = activeGoal != null && activeGoal!.isNotEmpty
        ? "Personalized guidance calibrated for your $activeGoal focus."
        : "Let's find evidence-based answers for a healthier you.";

    return Semantics(
      container: true,
      label: '${diurnal.formattedDate}, ${diurnal.greeting.replaceAll('\n', ' ')}. $goalSubtext',
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(NETokens.radiusXl),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              NETokens.greetingGradientStart,
              NETokens.greetingGradientMid,
              NETokens.greetingGradientEnd,
            ],
          ),
          border: Border.all(color: NETokens.borderDefault),
          boxShadow: NETokens.cardShadow,
        ),
        padding: const EdgeInsets.all(18.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Text Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    diurnal.formattedDate,
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: NETokens.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    diurnal.greeting,
                    style: GoogleFonts.newsreader(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: NETokens.primary,
                      height: 1.16,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    goalSubtext,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: NETokens.textSecondary,
                      height: 1.3,
                    ),
                  ),
                  if (activeGoal != null && activeGoal!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: NETokens.paleMint.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(NETokens.radiusFull),
                        border: Border.all(color: const Color(0xFFC0E5CB)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.track_changes_rounded, size: 12, color: NETokens.deepestForest),
                          const SizedBox(width: 4),
                          Text(
                            activeGoal!.toUpperCase(),
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: NETokens.deepestForest,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Botanical Illustration Container
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: NETokens.illustrationBg,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: NETokens.darkEvergreen.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                diurnal.illustrationAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: NETokens.illustrationBg,
                  child: const Icon(
                    Icons.spa_rounded,
                    color: NETokens.emerald,
                    size: 40,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
