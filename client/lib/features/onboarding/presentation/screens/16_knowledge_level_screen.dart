// ==============================================================================
// Nutrient Earth — Screen 16: Nutrition Knowledge Calibration (Exact Stitch Screen)
// Uses exact Stitch HTML/CSS/JS with 4 familiarity levels & adaptive depth.
// ==============================================================================

import 'package:flutter/material.dart';
import '../../../../core/design_system/components/stitch_screen_host.dart';

class KnowledgeLevelScreen extends StatelessWidget {
  final String? returnTo;
  const KnowledgeLevelScreen({super.key, this.returnTo});

  @override
  Widget build(BuildContext context) {
    return StitchScreenHostWidget(
      screenIndex: 16,
      returnTo: returnTo,
    );
  }
}
