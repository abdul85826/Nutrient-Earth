import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/tokens/ne_tokens.dart';

/// Screen 5: Account Entry Gateway
/// Authoritative Stitch Design: screen_5_account_entry_mobile
class Screen5AccountEntryMobile extends StatelessWidget {
  const Screen5AccountEntryMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NETokens.primaryContainer,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: NETokens.space20, vertical: NETokens.space16),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => context.pop(),
                    borderRadius: BorderRadius.circular(NETokens.radiusSm),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_back_ios, size: 16, color: Color(0xFFC5EBDD)),
                          const SizedBox(width: 4),
                          Text(
                            'BACK',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFC5EBDD),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF002614),
                      borderRadius: BorderRadius.circular(NETokens.radiusFull),
                    ),
                    child: Row(
                      children: [
                        ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 18,
                            height: 18,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.eco, size: 14, color: Color(0xFFC5EBDD)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'NUTRIENT EARTH',
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: const Color(0xFFC5EBDD),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Central Shield Emblem
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF002614),
                      borderRadius: BorderRadius.circular(NETokens.radiusLg),
                      border: Border.all(
                        color: const Color(0xFFBBEDDC).withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.verified_user_rounded,
                        size: 38,
                        color: Color(0xFFBBEDDC),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFFBBEDDC),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: NETokens.space24),

              // Title & Supporting Copy
              Text(
                'Your journey starts with a secure account.',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFC5EBDD),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: NETokens.space8),
              Text(
                'Create an account to access your research and goals across supported sessions and devices.',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  color: const Color(0xFFA9CEC2),
                ),
              ),

              const SizedBox(height: NETokens.space28),

              // Privacy & Isolation Card
              Container(
                padding: const EdgeInsets.all(NETokens.space16),
                decoration: BoxDecoration(
                  color: const Color(0xFF002614),
                  borderRadius: BorderRadius.circular(NETokens.radiusMd),
                  border: Border.all(
                    color: const Color(0xFFBBEDDC).withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: NETokens.primaryContainer,
                        borderRadius: BorderRadius.circular(NETokens.radiusSm),
                      ),
                      child: const Icon(Icons.lock, size: 18, color: Color(0xFFBBEDDC)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Privacy & Identity Isolation',
                                style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFC5EBDD),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: NETokens.primaryContainer,
                                  borderRadius: BorderRadius.circular(NETokens.radiusXs),
                                ),
                                child: Text(
                                  'L3 CRYPTO',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFBBEDDC),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Onboarding preferences are linked only after explicit authentication. No guest profiles or unverified sessions are created.',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              height: 1.4,
                              color: const Color(0xFFA9CEC2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NETokens.secondary,
                    foregroundColor: const Color(0xFFC3ECCF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(NETokens.radiusMd),
                    ),
                  ),
                  onPressed: () => context.go('/auth/signup'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Create account',
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: NETokens.space12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFC5EBDD),
                    side: BorderSide(
                      color: const Color(0xFFBBEDDC).withOpacity(0.3),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(NETokens.radiusMd),
                    ),
                  ),
                  onPressed: () => context.go('/auth/signin'),
                  child: Text(
                    'I already have an account — Sign in',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: NETokens.space16),

              Text(
                'Federated authentication options (Apple / Google) render conditionally based on deployment configuration.',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  color: const Color(0xFF9FD1C1).withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
