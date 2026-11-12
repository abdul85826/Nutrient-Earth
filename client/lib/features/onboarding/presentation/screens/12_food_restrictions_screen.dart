// ==============================================================================
// Nutrient Earth — Screen 12: Food Restrictions & Allergies (Exact Stitch Screen)
// Uses exact Stitch HTML/CSS/JS with 6 restriction types & custom input.
// ==============================================================================

import 'package:flutter/material.dart';
import '../../../../core/design_system/components/stitch_screen_host.dart';

class FoodRestrictionsScreen extends StatelessWidget {
  final String? returnTo;
  const FoodRestrictionsScreen({super.key, this.returnTo});

  @override
  Widget build(BuildContext context) {
    return StitchScreenHostWidget(
      screenIndex: 12,
      returnTo: returnTo,
    );
  }
}
