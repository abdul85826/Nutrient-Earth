// ==============================================================================
// Nutrient Earth — Screen 07: Food Choices Dietary Profile (Exact Stitch Screen)
// Uses exact Stitch HTML/CSS/JS with allergy catalog & foods-to-avoid chips.
// ==============================================================================

import 'package:flutter/material.dart';
import '../../../../core/design_system/components/stitch_screen_host.dart';

class FoodChoicesScreen extends StatelessWidget {
  final String? returnTo;
  const FoodChoicesScreen({super.key, this.returnTo});

  @override
  Widget build(BuildContext context) {
    return StitchScreenHostWidget(
      screenIndex: 7,
      returnTo: returnTo,
    );
  }
}
