// ==============================================================================
// Nutrient Earth — Screen 10: Body Measurements (Exact Stitch Screen)
// Uses exact Stitch HTML/CSS/JS with dual height/weight unit switchers.
// ==============================================================================

import 'package:flutter/material.dart';
import '../../../../core/design_system/components/stitch_screen_host.dart';

class BodyMeasurementsScreen extends StatelessWidget {
  final String? returnTo;
  const BodyMeasurementsScreen({super.key, this.returnTo});

  @override
  Widget build(BuildContext context) {
    return const StitchScreenHostWidget(screenIndex: 10);
  }
}
