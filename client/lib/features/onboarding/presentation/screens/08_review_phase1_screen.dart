// ==============================================================================
// Nutrient Earth — Screen 08: Review Phase 1 Health Profile (Exact Stitch Screen)
// Uses exact Stitch HTML/CSS/JS with structured review cards & edit links.
// ==============================================================================

import 'package:flutter/material.dart';
import '../../../../core/design_system/components/stitch_screen_host.dart';

class ReviewPhase1Screen extends StatelessWidget {
  final String? returnTo;
  const ReviewPhase1Screen({super.key, this.returnTo});

  @override
  Widget build(BuildContext context) {
    return const StitchScreenHostWidget(screenIndex: 8);
  }
}
