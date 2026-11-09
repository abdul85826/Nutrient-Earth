// ==============================================================================
// Nutrient Earth — Screen 17: Calibration Complete / Summary (Exact Stitch Screen)
// Uses exact Stitch HTML/CSS/JS with Soil Profile summary & Get Started CTA.
// ==============================================================================

import 'package:flutter/material.dart';
import '../../../../core/design_system/components/stitch_screen_host.dart';

class CompletionScreen extends StatelessWidget {
  final String? returnTo;
  const CompletionScreen({super.key, this.returnTo});

  @override
  Widget build(BuildContext context) {
    return const StitchScreenHostWidget(screenIndex: 17);
  }
}
