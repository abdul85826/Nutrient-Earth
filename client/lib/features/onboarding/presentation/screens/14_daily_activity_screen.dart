// ==============================================================================
// Nutrient Earth — Screen 14: Daily Activity Movement (Exact Stitch Screen)
// Uses exact Stitch HTML/CSS/JS with 4 activity tiers & energy callout.
// ==============================================================================

import 'package:flutter/material.dart';
import '../../../../core/design_system/components/stitch_screen_host.dart';

class DailyActivityScreen extends StatelessWidget {
  final String? returnTo;
  const DailyActivityScreen({super.key, this.returnTo});

  @override
  Widget build(BuildContext context) {
    return StitchScreenHostWidget(
      screenIndex: 14,
      returnTo: returnTo,
    );
  }
}
