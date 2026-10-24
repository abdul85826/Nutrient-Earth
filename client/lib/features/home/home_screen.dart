import 'package:flutter/material.dart';
import '../../core/design_system/tokens/ne_tokens.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NETokens.background,
      appBar: AppBar(
        title: const Text(
          'Nutrient Earth',
          style: TextStyle(
            color: NETokens.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: NETokens.surface,
        elevation: 0,
        centerTitle: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: NETokens.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: NETokens.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Fresh Workspace Ready',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: NETokens.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'All previous screens and integrations have been safely cleared.\nReady to build your new screens and features.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: NETokens.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: NETokens.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: NETokens.borderSubtle),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, color: NETokens.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Clean Slate Initialized • 0 Errors',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: NETokens.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
