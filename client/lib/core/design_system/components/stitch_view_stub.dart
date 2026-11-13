import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../tokens/ne_tokens.dart';
import 'stitch_view_interface.dart';

StitchViewPlatform getStitchViewPlatform() => _StitchViewStub();

class _StitchViewStub implements StitchViewPlatform {
  @override
  Widget buildView({
    required int screenIndex,
    required String initialUrl,
    required OnStitchMessageCallback onMessage,
  }) {
    return _NativeScreenFallbackWidget(
      screenIndex: screenIndex,
      initialUrl: initialUrl,
      onMessage: onMessage,
    );
  }
}

class _NativeScreenFallbackWidget extends StatelessWidget {
  final int screenIndex;
  final String initialUrl;
  final OnStitchMessageCallback onMessage;

  const _NativeScreenFallbackWidget({
    required this.screenIndex,
    required this.initialUrl,
    required this.onMessage,
  });

  String _getNextRouteFor(int index) {
    switch (index) {
      case 1:
        return '/welcome';
      case 2:
        return '/onboarding/health-goals';
      case 4:
        return '/onboarding/difficulties';
      case 5:
        return '/onboarding/impact';
      case 6:
        return '/onboarding/food-choices';
      case 7:
        return '/onboarding/review-phase1';
      case 8:
        return '/onboarding/personal-details';
      case 9:
        return '/onboarding/body-measurements';
      case 10:
        return '/onboarding/health-concerns';
      case 11:
        return '/onboarding/food-restrictions';
      case 12:
        return '/onboarding/eating-routine';
      case 13:
        return '/onboarding/daily-activity';
      case 14:
        return '/onboarding/sleep-patterns';
      case 15:
        return '/onboarding/knowledge-level';
      case 16:
        return '/onboarding/completion';
      case 17:
        return '/today';
      default:
        return '/today';
    }
  }

  @override
  Widget build(BuildContext context) {
    final nextRoute = _getNextRouteFor(screenIndex);

    return Scaffold(
      backgroundColor: NETokens.background,
      appBar: AppBar(
        backgroundColor: NETokens.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: NETokens.darkEvergreen),
          onPressed: () {
            onMessage({'type': 'NAVIGATE', 'route': '/welcome'});
          },
        ),
        title: Text(
          'STEP $screenIndex OF 17',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: NETokens.botanicalTeal,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: NETokens.surfaceContainer,
                      border: Border.all(color: NETokens.borderDefault),
                      boxShadow: NETokens.cardShadow,
                    ),
                    child: Center(
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          width: 48,
                          height: 48,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.eco_rounded,
                                  size: 32, color: NETokens.forest),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Nutrient Earth',
                    style: GoogleFonts.manrope(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: NETokens.darkEvergreen,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Step $screenIndex • Discovery Protocol',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: NETokens.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading clinical questionnaire section...',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 13.5,
                      color: NETokens.textMuted,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        onMessage({
                          'type': 'NAVIGATE',
                          'route': nextRoute,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NETokens.darkEvergreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(NETokens.radiusFull),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              'Continue to Next Step',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.manrope(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
