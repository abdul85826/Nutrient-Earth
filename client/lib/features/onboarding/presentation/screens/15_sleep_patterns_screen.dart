// ==============================================================================
// Nutrient Earth — Screen 15: Sleep Quality Patterns (Exact Stitch Screen)
// Uses exact Stitch HTML/CSS/JS with 4 sleep tiers & circadian callout.
// ==============================================================================

import 'package:flutter/material.dart';
import '../../../../core/design_system/components/stitch_screen_host.dart';

class SleepPatternsScreen extends StatelessWidget {
  final String? returnTo;
  const SleepPatternsScreen({super.key, this.returnTo});

  @override
  Widget build(BuildContext context) {
    return StitchScreenHostWidget(
      screenIndex: 15,
      returnTo: returnTo,
    );
  }
}
