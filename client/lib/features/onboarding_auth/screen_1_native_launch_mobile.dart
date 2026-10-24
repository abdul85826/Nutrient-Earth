import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/tokens/ne_tokens.dart';

/// Screen 1: Native Launch / Splash Screen
/// Authoritative Stitch Design: screen_1_native_launch_mobile
class Screen1NativeLaunchMobile extends StatefulWidget {
  const Screen1NativeLaunchMobile({super.key});

  @override
  State<Screen1NativeLaunchMobile> createState() =>
      _Screen1NativeLaunchMobileState();
}

class _Screen1NativeLaunchMobileState extends State<Screen1NativeLaunchMobile>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  Timer? _tickerTimer;
  int _logIndex = 0;

  final List<String> _diagnosticLogs = [
    'CALIBRATING SPECTRAL SENSORS...',
    'ESTABLISHING BOTANICAL LINK...',
    'VERIFYING SOIL CRYPTOGRAPHY...',
    'READYING DIAGNOSTIC ENGINE...',
  ];

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _tickerTimer = Timer.periodic(const Duration(milliseconds: 2200), (timer) {
      if (mounted) {
        setState(() {
          _logIndex = (_logIndex + 1) % _diagnosticLogs.length;
        });
      }
    });

    // Auto-advance after initialization sequence (or user can tap)
    _autoNavTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        context.go('/welcome');
      }
    });
  }

  Timer? _autoNavTimer;

  @override
  void dispose() {
    _spinController.dispose();
    _tickerTimer?.cancel();
    _autoNavTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NETokens.primaryContainer,
      body: SafeArea(
        child: InkWell(
          onTap: () => context.go('/welcome'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: NETokens.space24, vertical: NETokens.space24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Atmospheric Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                          'ENV::PROD_BIO_NODE',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            letterSpacing: 1.5,
                            color: const Color(0xFF9FD1C1).withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'v4.2.0-STABLE',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        letterSpacing: 1.5,
                        color: const Color(0xFF9FD1C1).withOpacity(0.6),
                      ),
                    ),
                  ],
                ),

                // Center Emblem & Spinner
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Circular Emblem Container with Halo
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: NETokens.secondary.withOpacity(0.2),
                            blurRadius: 36,
                            spreadRadius: 8,
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFFBBEDDC).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: NETokens.secondary,
                              child: const Icon(
                                Icons.eco_rounded,
                                size: 64,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: NETokens.space40),

                    // Minimalist Precision Ring Spinner
                    RotationTransition(
                      turns: _spinController,
                      child: Container(
                        width: 32,
                        height: 32,
                        padding: const EdgeInsets.all(3),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFBBEDDC),
                          ),
                          backgroundColor: const Color(0xFF9FD1C1).withOpacity(0.2),
                        ),
                      ),
                    ),
                    const SizedBox(height: NETokens.space16),

                    // System Status Monospace Tracker
                    Text(
                      'INITIALIZING SYSTEM',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.8,
                        color: const Color(0xFFBBEDDC),
                      ),
                    ),
                    const SizedBox(height: NETokens.space6),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _diagnosticLogs[_logIndex],
                        key: ValueKey<int>(_logIndex),
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          letterSpacing: 1.2,
                          color: const Color(0xFF9FD1C1).withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),

                // Bottom Global Signature
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 1,
                      color: const Color(0xFF9FD1C1).withOpacity(0.2),
                    ),
                    const SizedBox(height: NETokens.space8),
                    Text(
                      'NUTRIENT EARTH • SECURE INTELLIGENCE ENGINE',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        letterSpacing: 2.0,
                        color: const Color(0xFF9FD1C1).withOpacity(0.4),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
