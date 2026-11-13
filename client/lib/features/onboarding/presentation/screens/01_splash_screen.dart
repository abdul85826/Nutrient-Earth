// ==============================================================================
// Nutrient Earth — Screen 01: Brand Splash Screen (Canonical Mobile & Web Engine)
// Deep botanical forest canvas, specimen core emblem, clinical telemetry pulse,
// authoritative StartupCoordinator state machine integration, and smooth auto-advance.
// ==============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../../../core/services/startup_coordinator.dart';

class SplashScreen extends ConsumerStatefulWidget {
  final bool autoAdvance;

  const SplashScreen({
    super.key,
    this.autoAdvance = true,
  });

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _glowAnimation;

  Timer? _minDwellTimer;
  bool _minDwellElapsed = false;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutCubic),
    );

    _glowAnimation = Tween<double>(begin: 0.12, end: 0.28).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    // Guaranteed minimum display duration so brand branding and telemetry are legible
    if (widget.autoAdvance) {
      _minDwellTimer = Timer(const Duration(milliseconds: 1600), () {
        if (!mounted) return;
        setState(() {
          _minDwellElapsed = true;
        });
        _tryAdvance();
      });
    } else {
      _minDwellElapsed = true;
    }
  }

  @override
  void dispose() {
    _minDwellTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _tryAdvance() {
    if (!widget.autoAdvance || !_minDwellElapsed) return;

    final status = ref.read(startupCoordinatorProvider);
    if (!status.isReady) return;

    final coordinator = ref.read(startupCoordinatorProvider.notifier);
    if (coordinator.markNavigated()) {
      if (mounted) {
        context.go(status.targetRoute);
      }
    }
  }

  void _handleManualTap() {
    final status = ref.read(startupCoordinatorProvider);
    if (status.state == StartupState.recoverableError) {
      ref.read(startupCoordinatorProvider.notifier).retry();
      return;
    }

    if (status.isReady) {
      final coordinator = ref.read(startupCoordinatorProvider.notifier);
      if (coordinator.markNavigated()) {
        if (mounted) {
          context.go(status.targetRoute);
        }
      }
    }
  }

  String _telemetryLabelFor(StartupState state) {
    switch (state) {
      case StartupState.initializing:
        return 'SYS.VER 4.8.2 • INITIALIZING KNOWLEDGE CORES';
      case StartupState.restoringSession:
        return 'SYS.VER 4.8.2 • VERIFYING CLINICAL SESSION';
      case StartupState.checkingOnboarding:
        return 'SYS.VER 4.8.2 • AUDITING ONBOARDING BIOMARKERS';
      case StartupState.showingWelcome:
      case StartupState.showingOnboarding:
      case StartupState.showingMainApplication:
        return 'SYS.VER 4.8.2 • PROTOCOL SYNCHRONIZED';
      case StartupState.recoverableError:
        return 'SYS.VER 4.8.2 • CONNECTION ANOMALY DETECTED';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to startup state changes
    ref.listen<StartupStatus>(startupCoordinatorProvider, (previous, next) {
      if (next.isReady && _minDwellElapsed) {
        _tryAdvance();
      }
    });

    final status = ref.watch(startupCoordinatorProvider);
    final isError = status.state == StartupState.recoverableError;

    return Scaffold(
      backgroundColor: const Color(0xFF021410),
      body: GestureDetector(
        onTap: _handleManualTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // Ambient Botanical Canvas Background
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF051F20),
                      Color(0xFF00251D),
                      Color(0xFF021410),
                    ],
                  ),
                ),
              ),
            ),

            // Soft Ambient Top Radial Aura
            Positioned(
              top: -80,
              left: 0,
              right: 0,
              height: 320,
              child: AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, _) => Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF38675A)
                        .withValues(alpha: _glowAnimation.value),
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top Telemetry Header Pill
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius:
                              BorderRadius.circular(NETokens.radiusFull),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isError
                                    ? const Color(0xFFE57373)
                                    : const Color(0xFFB8EADA),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isError
                                  ? 'OFFLINE TOLERANCE ACTIVE'
                                  : 'CLINICAL BIOANALYTICS • VERIFIED',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: isError
                                    ? const Color(0xFFE57373)
                                    : const Color(0xFF9FD1C1),
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Central Specimen Core Emblem & Typography
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Pulse Aura
                              AnimatedBuilder(
                                animation: _glowAnimation,
                                builder: (context, _) => Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF38675A).withValues(
                                        alpha: _glowAnimation.value * 0.8),
                                  ),
                                ),
                              ),

                              // Specimen Emblem Container
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(32),
                                  color: Colors.white.withValues(alpha: 0.06),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.45),
                                      blurRadius: 30,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(22),
                                    child: Image.asset(
                                      'assets/images/app_logo.png',
                                      width: 84,
                                      height: 84,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(
                                        Icons.spa_rounded,
                                        size: 54,
                                        color: Color(0xFFB8EADA),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Specimen Core Sub-badge
                              Positioned(
                                bottom: -2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF021511),
                                    borderRadius: BorderRadius.circular(
                                        NETokens.radiusFull),
                                    border: Border.all(
                                      color: const Color(0xFF38675A)
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Text(
                                    'SPECIMEN CORE',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF9FD1C1),
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          'Nutrient Earth',
                          style: GoogleFonts.manrope(
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                width: 18,
                                height: 1,
                                color: const Color(0xFF38675A)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                'EVIDENCE COMPANION',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF9FD1C1),
                                  letterSpacing: 2.2,
                                ),
                              ),
                            ),
                            Container(
                                width: 18,
                                height: 1,
                                color: const Color(0xFF38675A)),
                          ],
                        ),
                      ],
                    ),

                    // Footer Telemetry & Recovery Actions
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isError) ...[
                            Text(
                              status.errorMessage ??
                                  'Unable to initialize session.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.manrope(
                                fontSize: 13,
                                color: const Color(0xFFEF9A9A),
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: _handleManualTap,
                              icon: const Icon(Icons.refresh_rounded,
                                  size: 16, color: Color(0xFFB8EADA)),
                              label: Text(
                                'Retry Connection',
                                style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFB8EADA),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: Color(0xFF38675A)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      NETokens.radiusFull),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: () {
                                if (mounted) context.go('/welcome');
                              },
                              child: Text(
                                'Continue to Welcome Screen →',
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  color: const Color(0xFF9FD1C1),
                                ),
                              ),
                            ),
                          ] else ...[
                            Text(
                              'Nutrition, grounded in science.',
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFFB8EADA)
                                    .withValues(alpha: 0.85),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _telemetryLabelFor(status.state),
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 9.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.4),
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Micro progress bar
                            Container(
                              width: 80,
                              height: 3,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: status.isReady
                                  ? Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFB8EADA),
                                        borderRadius:
                                            BorderRadius.circular(2),
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
