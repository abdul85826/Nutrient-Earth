import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/lifecycle/app_lifecycle_notifier.dart';

class AlphaWelcomeScreen extends ConsumerStatefulWidget {
  const AlphaWelcomeScreen({super.key});

  @override
  ConsumerState<AlphaWelcomeScreen> createState() => _AlphaWelcomeScreenState();
}

class _AlphaWelcomeScreenState extends ConsumerState<AlphaWelcomeScreen> {
  bool _accepted = false;

  void _onContinue() async {
    if (_accepted) {
      await ref.read(appLifecycleProvider.notifier).acceptAlphaConsent();
      if (mounted) context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              const Text('Welcome to Nutrient Earth', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Internal Alpha Phase', style: TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 32),
              
              const Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('About the Alpha', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text(
                        'This is an early build. You may encounter bugs, performance issues, or incomplete features. Your feedback during this phase will directly shape the product.',
                        style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                      ),
                      SizedBox(height: 24),
                      Text('Privacy & Data', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text(
                        'We collect usage data, biological inputs, and crash reports to improve the engine. Data is stored securely. By participating, you agree to our Privacy Policy and Terms of Service.',
                        style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => context.push('/legal/privacy'),
                    child: const Text('Privacy Policy', style: TextStyle(color: Colors.blueAccent)),
                  ),
                  TextButton(
                    onPressed: () => context.push('/legal/terms'),
                    child: const Text('Terms of Service', style: TextStyle(color: Colors.blueAccent)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Checkbox(
                    value: _accepted,
                    onChanged: (val) => setState(() => _accepted = val ?? false),
                    activeColor: Colors.blueAccent,
                  ),
                  const Expanded(
                    child: Text('I understand this is an Alpha build and accept the terms.', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _accepted ? _onContinue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  disabledBackgroundColor: Colors.grey[800],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('CONTINUE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
