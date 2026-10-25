import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';

class HeaderBar extends StatelessWidget {
  final VoidCallback onMenuPressed;
  final VoidCallback onProfilePressed;

  const HeaderBar({
    super.key,
    required this.onMenuPressed,
    required this.onProfilePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Hamburger Button
          InkWell(
            onTap: onMenuPressed,
            borderRadius: BorderRadius.circular(NETokens.radiusFull),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: NETokens.borderDefault),
                boxShadow: NETokens.buttonShadow,
              ),
              child: const Icon(
                Icons.menu_rounded,
                color: NETokens.primary,
                size: 20,
              ),
            ),
          ),

          // Center Logo & Wordmark
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: NETokens.borderDefault),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: NETokens.surfaceContainer,
                      child: const Icon(Icons.eco_rounded, size: 18, color: NETokens.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Nutrient Earth',
                        style: GoogleFonts.newsreader(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: NETokens.primary,
                          letterSpacing: -0.4,
                          height: 1.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'EVIDENCE COMPANION',
                        style: GoogleFonts.manrope(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: NETokens.textSecondary,
                          letterSpacing: 1.1,
                          height: 1.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Right Profile Avatar Button
          InkWell(
            onTap: onProfilePressed,
            borderRadius: BorderRadius.circular(NETokens.radiusFull),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: NETokens.borderDefault),
                boxShadow: NETokens.buttonShadow,
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                color: NETokens.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
