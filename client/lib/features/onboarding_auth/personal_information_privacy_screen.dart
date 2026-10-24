import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/tokens/ne_tokens.dart';

/// Screen 10: Personal Information & Privacy Introduction
/// Authoritative Stitch Design: personal_information_privacy_introduction
class PersonalInformationPrivacyScreen extends StatelessWidget {
  const PersonalInformationPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NETokens.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Account Security Protocol',
          style: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: NETokens.onSurface,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: NETokens.primary,
              child: const Icon(Icons.person, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: NETokens.space20, vertical: NETokens.space12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: NETokens.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ACCOUNT SECURITY & PRIVACY',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          color: NETokens.secondary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Step 05 of 06',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: NETokens.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: NETokens.space16),

              Text(
                'Your context, your choice.',
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: NETokens.onSurface,
                ),
              ),
              const SizedBox(height: NETokens.space8),
              Text(
                'A little context can make nutrition guidance more relevant. You decide what to share and can provide more information when it becomes useful.',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: NETokens.onSurfaceVariant,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: NETokens.space20),

              // 3 Context Cards
              _ContextCard(
                icon: Icons.shield_rounded,
                title: 'Health context',
                description:
                    'Share a health concern or relevant context when it helps answer your question.',
              ),
              const SizedBox(height: NETokens.space12),
              _ContextCard(
                icon: Icons.eco_rounded,
                title: 'Food and nutrition preferences',
                description:
                    'Tell us about dietary preferences, restrictions, or foods you need to avoid when relevant.',
              ),
              const SizedBox(height: NETokens.space12),
              _ContextCard(
                icon: Icons.track_changes_rounded,
                title: 'Goals and daily routine',
                description:
                    'Add goals and practical constraints so recommendations can better fit your circumstances.',
              ),

              const SizedBox(height: NETokens.space20),

              // Privacy Reassurance Box
              Container(
                padding: const EdgeInsets.all(NETokens.space16),
                decoration: BoxDecoration(
                  color: NETokens.primaryContainer,
                  borderRadius: BorderRadius.circular(NETokens.radiusMd),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified_user_rounded, size: 18, color: Color(0xFFC5EBDD)),
                        const SizedBox(width: 8),
                        Text(
                          'PRIVACY REASSURANCE',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: const Color(0xFFC5EBDD),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: NETokens.space8),
                    Text(
                      'Share only what is necessary for your needs. Review the information you provide and use the privacy controls available in the product.',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        height: 1.4,
                        color: const Color(0xFFA9CEC2),
                      ),
                    ),
                    const SizedBox(height: NETokens.space10),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFFBBEDDC),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Client-side encryption enabled',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            color: const Color(0xFFBBEDDC),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: NETokens.space24),

              // Buttons
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NETokens.secondary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(NETokens.radiusMd),
                    ),
                  ),
                  onPressed: () => context.go('/onboarding/goals'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
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
              const SizedBox(height: NETokens.space8),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/research'),
                  child: Text(
                    'Do this later',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: NETokens.secondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContextCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _ContextCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(NETokens.space16),
      decoration: BoxDecoration(
        color: NETokens.surfaceContainer,
        borderRadius: BorderRadius.circular(NETokens.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: NETokens.secondaryContainer,
              borderRadius: BorderRadius.circular(NETokens.radiusSm),
            ),
            child: Icon(icon, size: 20, color: NETokens.onSecondaryContainer),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: NETokens.onSurface,
                  ),
                ),
                const SizedBox(height: NETokens.space4),
                Text(
                  description,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    height: 1.4,
                    color: NETokens.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
