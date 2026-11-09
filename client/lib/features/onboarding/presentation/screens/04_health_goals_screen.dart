// ==============================================================================
// Nutrient Earth — Screen 04: Health Goals & Conditions (Exact Stitch Screen)
// Uses exact Stitch HTML/CSS/JS with 6 category accordions & search.
// ==============================================================================

import 'package:flutter/material.dart';
import '../../../../core/design_system/components/stitch_screen_host.dart';

class HealthGoalsScreen extends StatelessWidget {
  final String? returnTo;
  const HealthGoalsScreen({super.key, this.returnTo});

  @override
  Widget build(BuildContext context) {
    return const StitchScreenHostWidget(screenIndex: 4);
  }
}
