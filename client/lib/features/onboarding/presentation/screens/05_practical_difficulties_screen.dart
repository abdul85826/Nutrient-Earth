// ==============================================================================
// Nutrient Earth — Screen 05: Practical Difficulties (Exact Stitch Screen)
// Uses exact Stitch HTML/CSS/JS with 6 clinical domains & 300-char notes.
// ==============================================================================

import 'package:flutter/material.dart';
import '../../../../core/design_system/components/stitch_screen_host.dart';

class PracticalDifficultiesScreen extends StatelessWidget {
  final String? returnTo;
  const PracticalDifficultiesScreen({super.key, this.returnTo});

  @override
  Widget build(BuildContext context) {
    return StitchScreenHostWidget(screenIndex: 5, returnTo: returnTo);
  }
}
