import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/tokens/ne_tokens.dart';
import '../../core/design_system/components/ne_text_field.dart';

/// Screen 9: Recover Account Access
/// Authoritative Stitch Design: recover_account_access
class RecoverAccountAccessScreen extends StatefulWidget {
  const RecoverAccountAccessScreen({super.key});

  @override
  State<RecoverAccountAccessScreen> createState() =>
      _RecoverAccountAccessScreenState();
}

class _RecoverAccountAccessScreenState
    extends State<RecoverAccountAccessScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _submitted = false;

  void _handleSendRecovery() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 650));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _submitted = true;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

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
          'Reset Password',
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: NETokens.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: NETokens.space20, vertical: NETokens.space16),
          child: _submitted
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: NETokens.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mark_email_read_rounded,
                        size: 32,
                        color: NETokens.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(height: NETokens.space20),
                    Text(
                      'Instructions sent',
                      style: GoogleFonts.manrope(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: NETokens.onSurface,
                      ),
                    ),
                    const SizedBox(height: NETokens.space8),
                    Text(
                      'If an account exists for ${_emailController.text}, you will receive a secure recovery email within a few moments.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: NETokens.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: NETokens.space32),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: NETokens.secondary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(NETokens.radiusMd),
                          ),
                        ),
                        onPressed: () => context.go('/auth/signin'),
                        child: Text(
                          'Back to sign in',
                          style: GoogleFonts.manrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recover your account',
                        style: GoogleFonts.manrope(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: NETokens.onSurface,
                        ),
                      ),
                      const SizedBox(height: NETokens.space8),
                      Text(
                        'Enter your verified email address to receive password recovery instructions.',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          color: NETokens.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: NETokens.space28),

                      NETextField(
                        controller: _emailController,
                        label: 'EMAIL ADDRESS',
                        hintText: 'name@domain.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20, color: NETokens.outline),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Email is required';
                          if (!val.contains('@')) return 'Enter a valid email address';
                          return null;
                        },
                      ),

                      const SizedBox(height: NETokens.space24),

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
                          onPressed: _isLoading ? null : _handleSendRecovery,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Send recovery instructions',
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

                      const Spacer(),

                      Center(
                        child: TextButton.icon(
                          onPressed: () => context.go('/auth/signin'),
                          icon: const Icon(Icons.arrow_back_rounded, size: 16, color: NETokens.onSurfaceVariant),
                          label: Text(
                            'Back to sign in',
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: NETokens.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
