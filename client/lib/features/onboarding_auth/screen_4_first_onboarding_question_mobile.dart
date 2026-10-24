import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/tokens/ne_tokens.dart';

/// Screen 4: First Onboarding Question / Context Selection
/// Authoritative Stitch Design: screen_4_first_onboarding_question_mobile
class Screen4FirstOnboardingQuestionMobile extends StatefulWidget {
  const Screen4FirstOnboardingQuestionMobile({super.key});

  @override
  State<Screen4FirstOnboardingQuestionMobile> createState() =>
      _Screen4FirstOnboardingQuestionMobileState();
}

class _Screen4FirstOnboardingQuestionMobileState
    extends State<Screen4FirstOnboardingQuestionMobile> {
  String? _selectedFocus;

  final List<Map<String, dynamic>> _options = const [
    {
      'id': 'health_concern',
      'label': 'Understand a health concern',
      'icon': Icons.description_outlined,
    },
    {
      'id': 'nutrition',
      'label': 'Improve my nutrition',
      'icon': Icons.restaurant_outlined,
    },
    {
      'id': 'weight',
      'label': 'Manage my weight',
      'icon': Icons.scale_outlined,
    },
    {
      'id': 'fitness',
      'label': 'Build fitness and recovery habits',
      'icon': Icons.monitor_heart_outlined,
    },
    {
      'id': 'supplements',
      'label': 'Understand a food or supplement',
      'icon': Icons.medication_outlined,
    },
    {
      'id': 'explore_other',
      'label': 'Explore another topic',
      'icon': Icons.explore_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NETokens.primaryContainer,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: NETokens.space20, vertical: NETokens.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
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
                          const Icon(Icons.arrow_back_rounded, size: 18, color: Color(0xFFC5EBDD)),
                          const SizedBox(width: 4),
                          Text(
                            'Back',
                            style: GoogleFonts.manrope(
                              fontSize: 13,
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
                    child: Text(
                      'Context Selection',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFC3ECCF),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: NETokens.space20),

              // Question Statement
              Text(
                'What would you like help with first?',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFC5EBDD),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: NETokens.space6),
              Text(
                'Pick one to start. You can change this or add more anytime.',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFA9CEC2),
                ),
              ),

              const SizedBox(height: NETokens.space20),

              // Options List
              Expanded(
                child: ListView.separated(
                  itemCount: _options.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = _options[index];
                    final isSelected = _selectedFocus == item['id'];

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedFocus = item['id'] as String;
                        });
                      },
                      borderRadius: BorderRadius.circular(NETokens.radiusMd),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF002614)
                              : const Color(0xFF002614).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(NETokens.radiusMd),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFBBEDDC)
                                : const Color(0xFFBBEDDC).withOpacity(0.12),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item['icon'] as IconData,
                              size: 20,
                              color: isSelected
                                  ? const Color(0xFFBBEDDC)
                                  : const Color(0xFFA9CEC2),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item['label'] as String,
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected
                                      ? const Color(0xFFC5EBDD)
                                      : const Color(0xFFA9CEC2),
                                ),
                              ),
                            ),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? const Color(0xFFBBEDDC)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFBBEDDC)
                                      : const Color(0xFFBBEDDC).withOpacity(0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: isSelected
                                  ? const Center(
                                      child: Icon(
                                        Icons.circle,
                                        size: 10,
                                        color: Color(0xFF00251D),
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom Confirmation
              Text(
                'Select an option to enable continuation. No personal data will be collected.',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  color: const Color(0xFF9FD1C1).withOpacity(0.6),
                ),
              ),
              const SizedBox(height: NETokens.space12),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedFocus != null
                        ? const Color(0xFFBBEDDC)
                        : const Color(0xFF002614),
                    foregroundColor: _selectedFocus != null
                        ? const Color(0xFF002019)
                        : const Color(0xFF9FD1C1).withOpacity(0.4),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(NETokens.radiusMd),
                    ),
                  ),
                  onPressed: _selectedFocus != null
                      ? () => context.go('/auth/gateway')
                      : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
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
