// ==============================================================================
// Nutrient Earth — Check Email Verification Waiting Screen
//
// Dedicated, pixel-perfect waiting experience following Stitch design language:
// 1. Heading: "Check your inbox"
// 2. Confirmation: "We've sent you a secure verification link."
// 3. Submitted email pill with edit / change email support
// 4. Three numbered verification steps:
//    1. Open your email inbox.
//    2. Open the email from Nutrient Earth.
//    3. Tap Verify Email to continue.
// 5. Authentic neutral expiration notice (no invented 5m/10m/15m countdowns)
// 6. Server-compatible 60s Resend cooldown with duplicate request protection
// 7. Multi-tab & background verification detection (WidgetsBindingObserver)
// 8. "Open email app" and "Check verification status" actions
// 9. Animated botanical halo and success confirmation transition
// ==============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/services/auth_destination_resolver.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/profile_repository.dart';

class CheckEmailScreen extends ConsumerStatefulWidget {
  final String email;
  final String? returnTo;

  const CheckEmailScreen({
    super.key,
    required this.email,
    this.returnTo,
  });

  @override
  ConsumerState<CheckEmailScreen> createState() => _CheckEmailScreenState();
}

class _CheckEmailScreenState extends ConsumerState<CheckEmailScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const int _initialCooldown = 60;
  late String _currentEmail;
  int _cooldownSeconds = _initialCooldown;
  Timer? _countdownTimer;
  StreamSubscription<AuthState>? _authServiceSubscription;
  StreamSubscription<AuthState>? _supabaseSubscription;
  bool _isResending = false;
  bool _isCheckingStatus = false;
  String? _statusBanner;
  String? _errorMessage;
  bool _sessionDetected = false;

  late AnimationController _haloController;
  late Animation<double> _haloScaleAnimation;
  late Animation<double> _haloOpacityAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentEmail = widget.email.trim();

    _haloController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _haloScaleAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _haloController, curve: Curves.easeInOut),
    );

    _haloOpacityAnimation = Tween<double>(begin: 0.35, end: 0.80).animate(
      CurvedAnimation(parent: _haloController, curve: Curves.easeInOut),
    );

    _startCooldownTimer();
    _listenToAuthSessionChanges();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfAlreadyAuthenticated();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_sessionDetected) {
      _checkIfAlreadyAuthenticated();
    }
  }

  void _startCooldownTimer([int? initialSeconds]) {
    _countdownTimer?.cancel();
    _cooldownSeconds = initialSeconds ?? _initialCooldown;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_cooldownSeconds > 0) {
        setState(() {
          _cooldownSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _listenToAuthSessionChanges() {
    // 1. Listen via Riverpod AuthService
    final authService = ref.read(authServiceProvider);
    _authServiceSubscription = authService.authStateChanges.listen((authState) {
      if (!mounted) return;
      if (authState.event == AuthChangeEvent.signedIn && authState.session != null) {
        _handleSuccessfulVerification(authState.session!.user);
      }
    });

    // 2. Listen via Supabase client if active
    final client = SupabaseConfig.client;
    if (client != null) {
      _supabaseSubscription = client.auth.onAuthStateChange.listen((authState) {
        if (!mounted) return;
        if (authState.event == AuthChangeEvent.signedIn && authState.session != null) {
          _handleSuccessfulVerification(authState.session!.user);
        }
      });
    }
  }

  Future<void> _checkIfAlreadyAuthenticated() async {
    if (_sessionDetected) return;

    final authService = ref.read(authServiceProvider);
    if (authService.currentUser != null && authService.currentSession != null) {
      _handleSuccessfulVerification(authService.currentUser!);
      return;
    }

    final client = SupabaseConfig.client;
    if (client != null && client.auth.currentSession != null) {
      _handleSuccessfulVerification(client.auth.currentSession!.user);
    }
  }

  Future<void> _handleSuccessfulVerification(User user) async {
    if (_sessionDetected) return;

    setState(() {
      _sessionDetected = true;
      _isCheckingStatus = false;
      _statusBanner = 'Email verified! Opening your personal health plan...';
    });

    try {
      final profileRepo = ref.read(profileRepositoryProvider);
      final destination = await AuthDestinationResolver.resolveDestination(
        profileRepository: profileRepo,
        userId: user.id,
        returnTo: widget.returnTo,
      );

      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 700));
        if (mounted) {
          context.go(destination);
        }
      }
    } catch (_) {
      if (mounted) {
        context.go('/onboarding/health-goals');
      }
    }
  }

  Future<void> _handleResend() async {
    if (_cooldownSeconds > 0 || _isResending || _currentEmail.isEmpty) {
      return;
    }

    setState(() {
      _isResending = true;
      _errorMessage = null;
      _statusBanner = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithOtp(
        email: _currentEmail,
        redirectTo: AppConfig.authCallbackUrl,
      );

      if (!mounted) return;
      setState(() {
        _isResending = false;
        _statusBanner = 'A fresh verification link has been sent to your email.';
      });
      _startCooldownTimer();
    } on AuthException catch (ae) {
      if (!mounted) return;
      int seconds = 60;
      final msg = ae.message.toLowerCase();
      final regex = RegExp(r'(\d+)\s*second');
      final match = regex.firstMatch(msg);
      if (match != null) {
        seconds = int.tryParse(match.group(1) ?? '60') ?? 60;
      }

      setState(() {
        _isResending = false;
        _errorMessage = ae.message;
      });
      _startCooldownTimer(seconds);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isResending = false;
        _errorMessage = 'Failed to resend verification link: $e';
      });
    }
  }

  Future<void> _checkVerificationStatus() async {
    if (_isCheckingStatus || _sessionDetected) return;

    setState(() {
      _isCheckingStatus = true;
      _errorMessage = null;
      _statusBanner = null;
    });

    try {
      final client = SupabaseConfig.client;
      if (client != null) {
        try {
          final res = await client.auth.refreshSession();
          if (res.session != null) {
            _handleSuccessfulVerification(res.session!.user);
            return;
          }
        } catch (_) {
          // Expected when session is not yet active
        }
      }

      final authService = ref.read(authServiceProvider);
      if (authService.currentUser != null && authService.currentSession != null) {
        _handleSuccessfulVerification(authService.currentUser!);
        return;
      }

      if (!mounted) return;
      setState(() {
        _isCheckingStatus = false;
        _statusBanner = 'Waiting for verification link to be tapped in your email inbox.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCheckingStatus = false;
        _errorMessage = 'Could not verify status: $e';
      });
    }
  }

  Future<void> _openEmailApp() async {
    final Uri mailUri = Uri(scheme: 'mailto');
    try {
      if (await canLaunchUrl(mailUri)) {
        await launchUrl(mailUri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not open mail app automatically. Please open your email client manually.',
              style: GoogleFonts.plusJakartaSans(fontSize: 13),
            ),
            backgroundColor: const Color(0xFF163B32),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please check your email client or webmail for the verification link.',
            style: GoogleFonts.plusJakartaSans(fontSize: 13),
          ),
          backgroundColor: const Color(0xFF163B32),
        ),
      );
    }
  }

  void _showChangeEmailDialog() {
    final controller = TextEditingController(text: _currentEmail);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFFFBF9F4),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A0B2B26),
                blurRadius: 24,
                offset: Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC1C8C4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Change Email Address',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0B2B26),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the correct email address and we will dispatch a new verification link immediately.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: const Color(0xFF4F6359),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.emailAddress,
                autofocus: true,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  color: const Color(0xFF0B2B26),
                ),
                decoration: InputDecoration(
                  hintText: 'Enter your email address',
                  filled: true,
                  fillColor: const Color(0xFFF3F5F1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E7DF)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E7DF)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF163B32), width: 1.5),
                  ),
                  prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF163B32), size: 20),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF4F6359),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        final newEmail = controller.text.trim();
                        if (newEmail.isNotEmpty && newEmail.contains('@')) {
                          Navigator.of(ctx).pop();
                          setState(() {
                            _currentEmail = newEmail;
                            _cooldownSeconds = 0;
                          });
                          _handleResend();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF163B32),
                        foregroundColor: Colors.white,
                        splashFactory: InkRipple.splashFactory,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Send Verification',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    _authServiceSubscription?.cancel();
    _supabaseSubscription?.cancel();
    _haloController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cleanEmail = _currentEmail.isNotEmpty ? _currentEmail : 'your email address';

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F4),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // App Brand Monogram Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF0B2B26)),
                        onPressed: () => context.go('/auth?mode=signin'),
                        tooltip: 'Return to sign in',
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFF0EEE9),
                              border: Border.all(
                                color: const Color(0xFFC1C8C4).withValues(alpha: 0.40),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(9999),
                              child: Image.asset(
                                'assets/images/app_logo.png',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.eco_rounded,
                                  size: 18,
                                  color: Color(0xFF0B2B26),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'NUTRIENT EARTH',
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.0,
                              color: const Color(0xFF0B2B26),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 40), // Balance back button
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Animated Botanical Halo & Mail Hero Badge
                  AnimatedBuilder(
                    animation: _haloController,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Breathing Botanical Halo Glow
                          Transform.scale(
                            scale: _haloScaleAnimation.value,
                            child: Container(
                              width: 104,
                              height: 104,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(0xFF9FD1C1).withValues(alpha: _haloOpacityAnimation.value * 0.4),
                                    const Color(0xFFBBEDDC).withValues(alpha: _haloOpacityAnimation.value * 0.2),
                                    const Color(0xFFFBF9F4).withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Hero Badge Container
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _sessionDetected ? const Color(0xFFE6F4EA) : const Color(0xFFE8EFEA),
                              border: Border.all(
                                color: _sessionDetected
                                    ? const Color(0xFFA8D0B4)
                                    : const Color(0xFFC1C8C4).withValues(alpha: 0.60),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0B2B26).withValues(alpha: 0.08),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _sessionDetected
                                  ? const Icon(
                                      Icons.check_circle_rounded,
                                      size: 42,
                                      color: Color(0xFF1E5638),
                                    )
                                  : const Icon(
                                      Icons.mark_email_unread_rounded,
                                      size: 40,
                                      color: Color(0xFF163B32),
                                    ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Heading: "Check your inbox"
                  Text(
                    'Check your inbox',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF051F20),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Confirmation text: "We've sent you a secure verification link."
                  Text(
                    "We've sent you a secure verification link.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF4F6359),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Submitted Email Address Pill with Edit Action
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F5F1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E7DF)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.email_outlined, size: 16, color: Color(0xFF163B32)),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            cleanEmail,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0B2B26),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: _showChangeEmailDialog,
                          child: Text(
                            'Edit',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF163B32),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Session Detection Banner
                  if (_sessionDetected)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F4EA),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFA8D0B4)),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF1B4332),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _statusBanner ?? 'Authentication confirmed. Opening...',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1B4332),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Status Banner (Resend / Manual Check Feedback)
                  if (_statusBanner != null && !_sessionDetected)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF5EE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFB8DEC5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, size: 18, color: Color(0xFF1E5638)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _statusBanner!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1E5638),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Error Message Banner
                  if (_errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF1C8C8)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFFBA1A1A)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF7E1010),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Three Clear Verification Steps Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F5F1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE5EAE2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VERIFICATION STEPS',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: const Color(0xFF4F6359),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildStepRow(
                          stepNumber: '1',
                          title: 'Open your email inbox.',
                          description: 'Check the inbox of $cleanEmail on this device or another.',
                        ),
                        const SizedBox(height: 14),
                        _buildStepRow(
                          stepNumber: '2',
                          title: 'Open the email from Nutrient Earth.',
                          description: "Look for your single-use sign-in message from Nutrient Earth.",
                        ),
                        const SizedBox(height: 14),
                        _buildStepRow(
                          stepNumber: '3',
                          title: 'Tap Verify Email to continue.',
                          description: 'The secure link will confirm your identity and log you in automatically.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Authentic Neutral Expiration Notice Card (No invented 5m/10m/15m countdowns)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8F5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E7DF)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.lock_clock_outlined,
                            size: 16,
                            color: Color(0xFF4F6359),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Security Notice: For your safety, this single-use authentication link expires in accordance with Nutrient Earth security policies. If your link expires before use, you can request a fresh one below.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: const Color(0xFF4F6359),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Primary Resend Email Button with Server-Compatible 60s Cooldown & Duplicate Protection
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (_cooldownSeconds == 0 && !_isResending && !_sessionDetected)
                          ? _handleResend
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF163B32),
                        disabledBackgroundColor: const Color(0xFFE2E7DF),
                        foregroundColor: Colors.white,
                        disabledForegroundColor: const Color(0xFF7A8C83),
                        splashFactory: InkRipple.splashFactory,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isResending
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _cooldownSeconds > 0
                                      ? Icons.timer_outlined
                                      : Icons.refresh_rounded,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _cooldownSeconds > 0
                                      ? 'Resend link in ${_cooldownSeconds}s'
                                      : 'Resend verification link',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Open Email App & Check Verification Status Actions Row
                  Row(
                    children: [
                      // Open Email App
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: OutlinedButton.icon(
                            onPressed: _openEmailApp,
                            icon: const Icon(Icons.mail_outline_rounded, size: 17),
                            label: Text(
                              'Open email app',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF163B32),
                              side: const BorderSide(color: Color(0xFFC1C8C4)),
                              splashFactory: InkRipple.splashFactory,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Check Verification Status
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: OutlinedButton.icon(
                            onPressed: _isCheckingStatus || _sessionDetected ? null : _checkVerificationStatus,
                            icon: _isCheckingStatus
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.8,
                                      color: Color(0xFF163B32),
                                    ),
                                  )
                                : const Icon(Icons.sync_rounded, size: 17),
                            label: Text(
                              'Check status',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF163B32),
                              side: const BorderSide(color: Color(0xFFC1C8C4)),
                              splashFactory: InkRipple.splashFactory,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Change Email Action
                  TextButton(
                    onPressed: _showChangeEmailDialog,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF4F6359),
                      splashFactory: InkRipple.splashFactory,
                    ),
                    child: Text(
                      'Use a different email address',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4F6359),
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

  Widget _buildStepRow({
    required String stepNumber,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E7DF)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0B2B26).withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              stepNumber,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF163B32),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0B2B26),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: const Color(0xFF4F6359),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
