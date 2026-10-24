import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/tokens/ne_tokens.dart';
import '../../core/design_system/components/ne_text_field.dart';

/// Screen 6: Create Account
/// Authoritative Stitch Design: create_account
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  bool get _hasMinLength => _passwordController.text.length >= 8;
  bool get _hasNumOrSymbol =>
      RegExp(r'[0-9!@#\$%^&*(),.?":{}|<>]').hasMatch(_passwordController.text);
  bool get _passwordsMatch =>
      _passwordController.text.isNotEmpty &&
      _passwordController.text == _confirmPasswordController.text;

  void _handleCreateAccount() async {
    if (!_formKey.currentState!.validate() || !_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please verify password requirements and accept Terms.'),
          backgroundColor: NETokens.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    // Simulate real auth validation flow
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _isLoading = false);
      context.go('/auth/verify?email=${Uri.encodeComponent(_emailController.text)}');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
          'Create Account',
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: NETokens.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: NETokens.space20, vertical: NETokens.space12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create your account',
                  style: GoogleFonts.manrope(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: NETokens.onSurface,
                  ),
                ),
                const SizedBox(height: NETokens.space6),
                Text(
                  'Enter your email and create a password to begin.',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: NETokens.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: NETokens.space24),

                // Email Field
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

                const SizedBox(height: NETokens.space16),

                // Password Field
                NETextField(
                  controller: _passwordController,
                  label: 'CREATE PASSWORD',
                  hintText: 'Minimum 8 characters',
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: NETokens.outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20,
                      color: NETokens.secondary,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (val) {
                    if (val == null || val.length < 8) return 'Password must be at least 8 characters';
                    return null;
                  },
                ),

                const SizedBox(height: NETokens.space8),

                // Password requirement indicators
                Row(
                  children: [
                    _RequirementChip(
                      label: '8+ characters',
                      isValid: _hasMinLength,
                    ),
                    const SizedBox(width: 8),
                    _RequirementChip(
                      label: '1+ number/symbol',
                      isValid: _hasNumOrSymbol,
                    ),
                  ],
                ),

                const SizedBox(height: NETokens.space16),

                // Confirm Password Field
                NETextField(
                  controller: _confirmPasswordController,
                  label: 'CONFIRM PASSWORD',
                  hintText: 'Re-enter your password',
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: const Icon(Icons.lock_reset_rounded, size: 20, color: NETokens.outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20,
                      color: NETokens.secondary,
                    ),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (val) {
                    if (val != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),

                if (_confirmPasswordController.text.isNotEmpty && !_passwordsMatch) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.error_outline, size: 14, color: NETokens.error),
                      const SizedBox(width: 4),
                      Text(
                        'Passwords do not match',
                        style: GoogleFonts.manrope(fontSize: 12, color: NETokens.error),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: NETokens.space20),

                // Terms & Privacy Checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _agreedToTerms,
                        activeColor: NETokens.secondary,
                        onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'I agree to the Terms of Service and Privacy Policy',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          color: NETokens.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: NETokens.space24),

                // Submit Button
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
                    onPressed: _isLoading ? null : _handleCreateAccount,
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

                const SizedBox(height: NETokens.space20),

                // Zero-knowledge security note
                Container(
                  padding: const EdgeInsets.all(NETokens.space12),
                  decoration: BoxDecoration(
                    color: NETokens.surfaceContainer,
                    borderRadius: BorderRadius.circular(NETokens.radiusMd),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: NETokens.secondaryContainer,
                          borderRadius: BorderRadius.circular(NETokens.radiusFull),
                        ),
                        child: const Icon(Icons.shield_outlined, size: 16, color: NETokens.onSecondaryContainer),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Zero-knowledge biological & agronomic ledger encryption active.',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            color: NETokens.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: NETokens.space24),

                Center(
                  child: TextButton(
                    onPressed: () => context.go('/auth/signin'),
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: GoogleFonts.manrope(fontSize: 13, color: NETokens.onSurfaceVariant),
                        children: [
                          TextSpan(
                            text: 'Sign in',
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: NETokens.secondary,
                            ),
                          ),
                        ],
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

class _RequirementChip extends StatelessWidget {
  final String label;
  final bool isValid;

  const _RequirementChip({required this.label, required this.isValid});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isValid ? NETokens.secondaryContainer : NETokens.surfaceContainer,
        borderRadius: BorderRadius.circular(NETokens.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isValid ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 13,
            color: isValid ? NETokens.secondary : NETokens.outline,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: isValid ? FontWeight.w600 : FontWeight.w400,
              color: isValid ? NETokens.onSecondaryContainer : NETokens.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
