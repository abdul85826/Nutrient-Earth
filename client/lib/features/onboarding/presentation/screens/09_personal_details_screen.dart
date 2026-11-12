// ==============================================================================
// Nutrient Earth — Screen 09: Personal Details (Exact Stitch Screen)
// Uses exact Stitch HTML/CSS/JS with 9-segment progress, name pill & stepper.
// ==============================================================================

import 'package:flutter/material.dart';
import '../../../../core/design_system/components/stitch_screen_host.dart';

class PersonalDetailsScreen extends StatelessWidget {
  final String? returnTo;
  const PersonalDetailsScreen({super.key, this.returnTo});

  @override
  Widget build(BuildContext context) {
    return StitchScreenHostWidget(
      screenIndex: 9,
      returnTo: returnTo,
    );
  }
}
