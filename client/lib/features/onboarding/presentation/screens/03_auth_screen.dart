// ==============================================================================
// Nutrient Earth — Screen 03: Authentication Trust (Exact Stitch Screen)
// Uses exact Stitch HTML/CSS/JS with Google OAuth & credential authentication.
// ==============================================================================

import 'package:flutter/material.dart';
import '../../../../core/design_system/components/stitch_screen_host.dart';

class AuthScreen extends StatelessWidget {
  final String initialMode;
  final String? returnTo;

  const AuthScreen({
    super.key,
    this.initialMode = 'signup',
    this.returnTo,
  });

  @override
  Widget build(BuildContext context) {
    return StitchScreenHostWidget(
      screenIndex: 3,
      returnTo: returnTo,
    );
  }
}
