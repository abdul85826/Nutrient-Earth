// ==============================================================================
// Nutrient Earth — Screen 06: Daily Impact Rating (Exact Stitch Screen)
// Uses exact Stitch HTML/CSS/JS with discrete ticks & severity slider.
// ==============================================================================

import 'package:flutter/material.dart';
import '../../../../core/design_system/components/stitch_screen_host.dart';

class DailyImpactScreen extends StatelessWidget {
  final String? returnTo;
  const DailyImpactScreen({super.key, this.returnTo});

  @override
  Widget build(BuildContext context) {
    return StitchScreenHostWidget(screenIndex: 6, returnTo: returnTo);
  }
}
