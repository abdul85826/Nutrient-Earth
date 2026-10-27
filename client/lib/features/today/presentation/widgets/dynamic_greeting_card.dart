import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../../../core/services/diurnal_service.dart';

class DynamicGreetingCard extends StatelessWidget {
  final DiurnalContext diurnal;

  const DynamicGreetingCard({
    super.key,
    required this.diurnal,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '${diurnal.formattedDate}, ${diurnal.greeting.replaceAll('\n', ' ')}. Let\'s find evidence-based answers for a healthier you.',
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
                    "Let's find evidence-based answers for a healthier you.",
                    style: GoogleFonts.manrope(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: NETokens.textSecondary,
                      height: 1.3,
                    ),
                  ),
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
