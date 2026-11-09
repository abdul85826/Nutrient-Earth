// ==============================================================================
// Nutrient Earth — Screen 13: Eating Routine Rhythms (Exact Stitch Screen)
// Uses exact Stitch HTML/CSS/JS with 6 routine radio options & guidance.
// ==============================================================================

import 'package:flutter/material.dart';
import '../../../../core/design_system/components/stitch_screen_host.dart';

class EatingRoutineScreen extends StatelessWidget {
  final String? returnTo;
  const EatingRoutineScreen({super.key, this.returnTo});

  @override
  Widget build(BuildContext context) {
    return const StitchScreenHostWidget(screenIndex: 13);
  }
}
