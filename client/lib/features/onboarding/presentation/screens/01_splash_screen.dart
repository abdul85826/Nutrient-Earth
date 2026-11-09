// ==============================================================================
// Nutrient Earth — Screen 01: Brand Splash Screen (Exact Stitch Screen)
// Uses exact Stitch HTML/CSS/JS with living telemetry & brand pulse.
// ==============================================================================

import 'package:flutter/material.dart';
import '../../../../core/design_system/components/stitch_screen_host.dart';

class SplashScreen extends StatelessWidget {
  final bool autoAdvance;
  const SplashScreen({super.key, this.autoAdvance = true});

  @override
  Widget build(BuildContext context) {
    return const StitchScreenHostWidget(screenIndex: 1);
  }
}
