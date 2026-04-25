import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  bool _otpSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildBackgroundGlow(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  _buildHeader(),
                  const Spacer(),
                  if (!_otpSent) ...[
                    _buildPhoneInput(),
                    const SizedBox(height: 24),
                    _buildPrimaryButton(
                      label: 'SEND OTP',
                      onPressed: () => _handlePhoneAuth(),
                    ),
                  ] else ...[
                    _buildOtpInput(),
                    const SizedBox(height: 24),
                    _buildPrimaryButton(
                      label: 'VERIFY & CONTINUE',
                      onPressed: () => _handleVerifyOtp(),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _otpSent = false),
                      child: const Text('EDIT NUMBER', style: TextStyle(color: AppColors.nutrientGreen, fontSize: 10)),
                    ),
                  ],
                  const SizedBox(height: 32),
                  _buildDivider(),
                  const SizedBox(height: 32),
                  _buildSocialButton(
                    label: 'SIGN IN WITH GOOGLE',
                    icon: Icons.g_mobiledata_rounded,
                    onPressed: () => _handleGoogleAuth(),
                  ),
                  const SizedBox(height: 48),
                  _buildFooter(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          if (_isLoading) _buildOverlay(),
        ],
      ),
    );
  }

  Widget _buildBackgroundGlow() {
    return Positioned(
      top: -100,
      right: -100,
      child: Container(
        width: 400,
        height: 400,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.nutrientGreen.withValues(alpha: 0.1),
              AppColors.nutrientGreen.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WELCOME TO\nNUTRIENT EARTH',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: 32,
                height: 1.1,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          'Precision biology for high-performance humans.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MOBILE NUMBER',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.glassBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            children: [
              const Text(
                '+91',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              Container(width: 1, height: 20, color: Colors.white12),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  cursorColor: AppColors.nutrientGreen,
                  decoration: InputDecoration(
                    hintText: '00000 00000',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.1)),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtpInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ENTER VERIFICATION CODE',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.glassBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
            cursorColor: AppColors.nutrientGreen,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              counterText: '',
              hintText: '000000',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.1)),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({required String label, required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.nutrientGreen.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.nutrientGreen,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildSocialButton({required String label, required IconData icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
          color: Colors.white.withValues(alpha: 0.02),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppTheme.glassBorder)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.1), fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Container(height: 1, color: AppTheme.glassBorder)),
      ],
    );
  }

  Widget _buildFooter() {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 11),
          children: const [
            TextSpan(text: 'By continuing, you agree to our '),
            TextSpan(
              text: 'Terms of Service',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.nutrientGreen),
      ),
    );
  }

  void _handlePhoneAuth() async {
    if (_phoneController.text.length < 10) return;
    
    setState(() => _isLoading = true);
    try {
      // Real Supabase Auth Logic
      await Supabase.instance.client.auth.signInWithOtp(
        phone: '+91${_phoneController.text}',
      );
      setState(() {
        _otpSent = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Auth Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _handleVerifyOtp() async {
    if (_otpController.text.length < 6) return;
    
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client.auth.verifyOTP(
        phone: '+91${_phoneController.text}',
        token: _otpController.text,
        type: OtpType.sms,
      );
      
      if (response.user != null) {
        if (!mounted) return;
        context.go('/onboarding');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification Failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _handleGoogleAuth() async {
    setState(() => _isLoading = true);
    try {
      // This will trigger external browser for Google login
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.nutrientearth.app://login-callback/',
      );
      // Success is handled by auth state listener in router
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In Failed: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
