// ==============================================================================
// Nutrient Earth — Screen 11: Health Concerns Prioritization (Exact Stitch Screen)
// Uses exact Stitch HTML/CSS/JS with 9 prioritized clinical cards.
// ==============================================================================

import 'package:flutter/material.dart';
import '../../../../core/design_system/components/stitch_screen_host.dart';

class HealthConcernsScreen extends StatelessWidget {
  final String? returnTo;
  const HealthConcernsScreen({super.key, this.returnTo});

  @override
  Widget build(BuildContext context) {
    return const StitchScreenHostWidget(screenIndex: 11);
  }
}
