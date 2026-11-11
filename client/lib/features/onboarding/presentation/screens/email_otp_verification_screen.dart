// ==============================================================================
// Nutrient Earth — Email OTP Verification Screen
// Premium, clinical & botanical passwordless authentication verification.
//
// Features:
// 1. Header with back navigation, Nutrient Earth logo & monogram.
// 2. Editorial Newsreader headline & clear verification subtext.
// 3. Authentically masked email pill with quick "Change" action.
// 4. 6-digit accessible OTP input with auto-advance, backspace navigation,
//    paste distribution, autofill hints, and invalid error states.
// 5. Explicit wall-clock resend cooldown (60s) with duplicate request locking.
// 6. Real Supabase Gotrue verifyOTP & signInWithOtp integration.
// 7. Canonical AuthDestinationResolver routing preserving onboarding progress.
// 8. Zero-knowledge encryption & medical data sovereignty reassurance footer.
// ==============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../../../core/services/auth_destination_resolver.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/profile_repository.dart';
import '../../../../core/services/profile_sync_service.dart';
import '../../state/onboarding_journey_state.dart';

class EmailOtpVerificationScreen extends ConsumerStatefulWidget {
  final String email;
  final String? returnTo;
  final int otpLength;

  const EmailOtpVerificationScreen({
    super.key,
    required this.email,
    this.returnTo,
    this.otpLength = 6,
  });

  static String maskEmail(String email) {
    final clean = email.trim();
    final atIndex = clean.indexOf('@');
    if (atIndex <= 1) return clean;

    final local = clean.substring(0, atIndex);
    final domain = clean.substring(atIndex + 1);

    if (local.length <= 3) {
      return '${local[0]}***@$domain';
    }
    final prefix = local.substring(0, 2);
    final suffix = local.substring(local.length - 1);
    return '$prefix***$suffix@$domain';
  }

  @override
  ConsumerState<EmailOtpVerificationScreen> createState() => _EmailOtpVerificationScreenState();
}

class _EmailOtpVerificationScreenState extends ConsumerState<EmailOtpVerificationScreen> {
  static const int _defaultCooldownSeconds = 60;

  late final List<TextEditingController> _digitControllers;
  late final List<FocusNode> _focusNodes;

  late String _currentEmail;
  bool _isVerifying = false;
  bool _isResending = false;
  String? _errorMessage;
  String? _successMessage;

  int _cooldownRemaining = _defaultCooldownSeconds;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _currentEmail = widget.email.trim().toLowerCase();

    _digitControllers = List.generate(
      widget.otpLength,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.otpLength,
      (index) => FocusNode(debugLabel: 'OTP_Digit_$index'),
    );

    _startCooldown();

    // Auto-focus first digit field after frame render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _focusNodes.isNotEmpty) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    for (final controller in _digitControllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startCooldown([int seconds = _defaultCooldownSeconds]) {
    _cooldownTimer?.cancel();
    _cooldownRemaining = seconds;

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_cooldownRemaining > 1) {
        setState(() {
          _cooldownRemaining--;
        });
      } else {
        setState(() {
          _cooldownRemaining = 0;
        });
        timer.cancel();
      }
    });
  }

  String get _enteredCode {
    return _digitControllers.map((c) => c.text.trim()).join();
  }

  bool get _isComplete => _enteredCode.length == widget.otpLength;

  void _onDigitChanged(int index, String value) {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    if (value.length > 1) {
      // User pasted into one of the digit fields
      _distributePastedString(value);
      return;
    }

    if (value.isNotEmpty) {
      if (index < widget.otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        if (_isComplete && !_isVerifying) {
          _verifyCode();
        }
      }
    }
  }

  void _distributePastedString(String pasted) {
    final digitsOnly = pasted.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.isEmpty) return;

    for (int i = 0; i < widget.otpLength; i++) {
      if (i < digitsOnly.length) {
        _digitControllers[i].text = digitsOnly[i];
      } else {
        _digitControllers[i].clear();
      }
    }

    final targetIndex = digitsOnly.length >= widget.otpLength
        ? widget.otpLength - 1
        : digitsOnly.length;
    _focusNodes[targetIndex].requestFocus();

    if (_isComplete && !_isVerifying) {
      _verifyCode();
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event, int index) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_digitControllers[index].text.isEmpty && index > 0) {
        _digitControllers[index - 1].clear();
        _focusNodes[index - 1].requestFocus();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  Future<void> _verifyCode() async {
    final code = _enteredCode;
    if (code.length != widget.otpLength) {
      setState(() {
        _errorMessage = 'Please enter all ${widget.otpLength} digits.';
      });
      return;
    }

    if (_isVerifying) return;

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final profileRepo = ref.read(profileRepositoryProvider);

      final response = await authService.verifyOtp(
        email: _currentEmail,
        token: code,
        type: OtpType.email,
      );

      final user = response.user ?? authService.currentUser;
      if (user == null) {
        throw const AuthException('Could not verify authenticated session.');
      }

      if (!mounted) return;

      setState(() {
        _successMessage = 'Email verified. Opening your health journey...';
      });

      // Synchronize staged onboarding answers if present
      await ref.read(profileSyncServiceProvider).synchronizeStagedOnboarding(
        user: user,
        notifier: ref.read(onboardingJourneyProvider.notifier),
      );

      // Canonical 3-tier destination resolution
      final destination = await AuthDestinationResolver.resolveDestination(
        profileRepository: profileRepo,
        userId: user.id,
        returnTo: widget.returnTo,
      );

      if (mounted) {
        context.go(destination);
      }
    } on AuthException catch (ae) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        final msg = ae.message.toLowerCase();
        if (msg.contains('expired')) {
          _errorMessage = 'Your verification code has expired. Please request a new code.';
        } else if (msg.contains('invalid') || msg.contains('token')) {
          _errorMessage = 'Incorrect verification code. Please check your email and try again.';
        } else if (msg.contains('rate') || msg.contains('limit') || msg.contains('seconds')) {
          _errorMessage = ae.message;
        } else {
          _errorMessage = ae.message;
        }
      });
      // Clear inputs on invalid code to allow clean retry
      for (final c in _digitControllers) {
        c.clear();
      }
      if (_focusNodes.isNotEmpty) {
        _focusNodes[0].requestFocus();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _errorMessage = 'Authentication error: $e';
      });
    } finally {
      if (mounted && _successMessage == null) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  Future<void> _resendCode() async {
    if (_cooldownRemaining > 0 || _isResending) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.resendOtp(
        email: _currentEmail,
        type: OtpType.email,
      );

      if (!mounted) return;

      setState(() {
        _isResending = false;
        _successMessage = 'A new 6-digit verification code has been dispatched.';
        _startCooldown(_defaultCooldownSeconds);
      });

      for (final c in _digitControllers) {
        c.clear();
      }
      if (_focusNodes.isNotEmpty) {
        _focusNodes[0].requestFocus();
      }
    } on AuthException catch (ae) {
      if (!mounted) return;
      setState(() {
        _isResending = false;
        final msg = ae.message.toLowerCase();
        if (msg.contains('captcha')) {
          _errorMessage = 'Security verification expired. Please tap "Change" above to request a fresh code.';
        } else {
          _errorMessage = ae.message;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isResending = false;
        _errorMessage = 'Could not resend code: $e';
      });
    }
  }

  void _handleChangeEmail() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/auth?mode=signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    final maskedEmail = EmailOtpVerificationScreen.maskEmail(_currentEmail);

    return Scaffold(
      backgroundColor: NETokens.background,
      appBar: AppBar(
        backgroundColor: NETokens.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: NETokens.deepestForest),
          tooltip: 'Back to sign-in',
          onPressed: _handleChangeEmail,
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: NETokens.surfaceContainer,
                border: Border.all(color: NETokens.outlineVariant.withOpacity(0.4)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/app_logo.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.eco, size: 18, color: NETokens.botanicalTeal),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'NUTRIENT EARTH',
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: NETokens.deepestForest,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Specimen Verification Badge
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: NETokens.paleMint,
                        borderRadius: BorderRadius.circular(NETokens.radiusFull),
                        border: Border.all(color: NETokens.botanicalTeal.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_user_rounded, size: 14, color: NETokens.forest),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'SECURE BOTANICAL VERIFICATION',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                                color: NETokens.forest,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Editorial Serif Title
                  Text(
                    'Verify your email',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.newsreader(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: NETokens.deepestForest,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Explanatory Text
                  Text(
                    'We sent a 6-digit one-time verification code to securely authenticate your health profile.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w400,
                      color: NETokens.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Masked Email Pill with Change Action
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: NETokens.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(NETokens.radiusFull),
                        border: Border.all(color: NETokens.outlineVariant.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.email_outlined, size: 16, color: NETokens.botanicalTeal),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              maskedEmail,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: NETokens.deepestForest,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: _handleChangeEmail,
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: Text(
                                'Change',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: NETokens.botanicalTeal,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 6 Digit OTP Input Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(widget.otpLength, (index) {
                      return _buildDigitBox(index);
                    }),
                  ),

                  const SizedBox(height: 20),

                  // Error Banner
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: NETokens.errorContainer,
                        borderRadius: BorderRadius.circular(NETokens.radiusMd),
                        border: Border.all(color: NETokens.error.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 18, color: NETokens.onErrorContainer),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: NETokens.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Success Banner
                  if (_successMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: NETokens.paleMint,
                        borderRadius: BorderRadius.circular(NETokens.radiusMd),
                        border: Border.all(color: NETokens.forest.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, size: 18, color: NETokens.forest),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _successMessage!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: NETokens.forest,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Primary Verify Button
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (_isComplete && !_isVerifying) ? _verifyCode : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NETokens.darkEvergreen,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: NETokens.surfaceDim.withOpacity(0.5),
                        disabledForegroundColor: NETokens.outline,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(NETokens.radiusLg),
                        ),
                      ),
                      child: _isVerifying
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    'Verify & continue',
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.manrope(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_rounded, size: 18),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Resend Cooldown Controls
                  Center(
                    child: _cooldownRemaining > 0
                        ? FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.schedule_rounded, size: 15, color: NETokens.outline),
                                const SizedBox(width: 6),
                                Text(
                                  'Resend code in 0:${_cooldownRemaining.toString().padLeft(2, '0')}',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: NETokens.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _isResending
                            ? FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(NETokens.botanicalTeal),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Requesting new code...',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: NETokens.botanicalTeal,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    "Didn't receive the code? ",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      color: NETokens.onSurfaceVariant,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _resendCode,
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Resend code',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: NETokens.botanicalTeal,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                  ),

                  const SizedBox(height: 36),

                  // Reassurance & Security Disclosures
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: NETokens.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(NETokens.radiusLg),
                      border: Border.all(color: NETokens.outlineVariant.withOpacity(0.4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.shield_outlined, size: 18, color: NETokens.botanicalTeal),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Nutrient Earth utilizes passwordless cryptographic authentication. Your biological telemetry, dietary profile, and research inquiries remain encrypted and strictly under your sovereignty.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              height: 1.45,
                              color: NETokens.textMuted,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildDigitBox(int index) {
    final hasError = _errorMessage != null;
    final isFocused = _focusNodes[index].hasFocus;

    return Expanded(
      child: Focus(
        onKeyEvent: (node, event) => _handleKeyEvent(node, event, index),
        child: Container(
          height: 56,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(NETokens.radiusMd),
            border: Border.all(
              color: hasError
                  ? NETokens.error
                  : isFocused
                      ? NETokens.botanicalTeal
                      : NETokens.outlineVariant.withOpacity(0.6),
              width: isFocused ? 2.0 : 1.2,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: NETokens.mutedSage.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: TextFormField(
              controller: _digitControllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6), // Allow paste up to 6
              ],
              style: GoogleFonts.jetBrainsMono(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: NETokens.deepestForest,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                counterText: '',
              ),
              onChanged: (val) => _onDigitChanged(index, val),
            ),
          ),
        ),
      ),
    );
  }
}
