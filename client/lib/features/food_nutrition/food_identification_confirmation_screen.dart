import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/tokens/ne_tokens.dart';

/// Screen 26: Food Identification & Portion Confirmation
/// Route: /research/food/confirm
/// Authoritative Stitch Reference: food_identification_and_portion_confirmation
class FoodIdentificationConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const FoodIdentificationConfirmationScreen({
    super.key,
    this.initialData,
  });

  @override
  State<FoodIdentificationConfirmationScreen> createState() =>
      _FoodIdentificationConfirmationScreenState();
}

class _FoodIdentificationConfirmationScreenState
    extends State<FoodIdentificationConfirmationScreen> {
  bool _isStandardPortion = true;
  bool _hasOliveOil = true;
  String _selectedUnit = 'Grams';
  final _customWeightController = TextEditingController(text: '380');
  bool _isSwitchingCandidate = false;

  String _candidateTitle =
      'Pacific Wild Coho Salmon with Quinoa & Steamed Brassica';
  int _alignmentPercentage = 92;

  @override
  void dispose() {
    _customWeightController.dispose();
    super.dispose();
  }

  void _handleSwitchCandidate() {
    setState(() {
      _isSwitchingCandidate = !_isSwitchingCandidate;
      if (_isSwitchingCandidate) {
        _candidateTitle =
            'Atlantic Farmed Salmon with Quinoa & Steamed Broccoli';
        _alignmentPercentage = 81;
      } else {
        _candidateTitle =
            'Pacific Wild Coho Salmon with Quinoa & Steamed Brassica';
        _alignmentPercentage = 92;
      }
    });
  }

  void _handleConfirm() {
    context.push(
      '/research/food/nutrition',
      extra: {
        'title': _candidateTitle,
        'portionWeight': _isStandardPortion ? '380g' : '${_customWeightController.text}g',
        'hasOliveOil': _hasOliveOil,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = widget.initialData?['query'] as String? ??
        'Steamed wild salmon with quinoa & charred broccoli';

    return Scaffold(
      backgroundColor: NETokens.surface,
      appBar: AppBar(
        backgroundColor: NETokens.surface.withValues(alpha: 0.85),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: NETokens.onSurface),
          onPressed: () => context.pop(),
          tooltip: 'Navigate back',
        ),
        title: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                width: 24,
                height: 24,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.eco, size: 20, color: NETokens.secondary),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Intake Verification',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: NETokens.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: NETokens.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: NETokens.onPrimary, size: 18),
            ),
            onPressed: () => context.push('/profile/context'),
            tooltip: 'Account profile',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status & Breadcrumb Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: NETokens.secondaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: NETokens.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'STAGE 2 OF 4 • INTAKE VERIFICATION',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: NETokens.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'REF: #NE-8092B',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: NETokens.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Text(
                'Check the food details',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: NETokens.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Confirm the identification and portion before reviewing the nutrition estimate.',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  color: NETokens.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),

              // Food Identity Candidate Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Query Echo
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: NETokens.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.manage_search,
                            size: 18,
                            color: NETokens.secondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ANALYZED QUERY',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                    color: NETokens.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  query,
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: NETokens.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Candidate Title & Badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            _candidateTitle,
                            style: GoogleFonts.manrope(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: NETokens.primaryContainer,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: NETokens.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'VERIFIED SPEC',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: NETokens.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Telemetry & Alignment Bar
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: NETokens.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.model_training,
                                    size: 15,
                                    color: NETokens.secondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Biochemical Model Match',
                                    style: GoogleFonts.manrope(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: NETokens.primary,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '$_alignmentPercentage% Alignment',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: NETokens.secondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _alignmentPercentage / 100,
                              minHeight: 6,
                              backgroundColor: NETokens.surfaceContainerHigh,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                NETokens.secondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Identified from user text specification. Visual preparation depth unverified.',
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              color: NETokens.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Alternative Hypotheses
                    Text(
                      'ALTERNATIVE HYPOTHESES',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: NETokens.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _handleSwitchCandidate,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: NETokens.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.swap_horiz,
                                  size: 18,
                                  color: NETokens.secondary,
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _isSwitchingCandidate
                                          ? 'Pacific Wild Coho Salmon'
                                          : 'Atlantic Farmed Salmon',
                                      style: GoogleFonts.manrope(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: NETokens.onSurface,
                                      ),
                                    ),
                                    Text(
                                      _isSwitchingCandidate
                                          ? 'Leaner profile • 92% Alignment'
                                          : 'Higher Lipid Profile • 81% Alignment',
                                      style: GoogleFonts.manrope(
                                        fontSize: 10,
                                        color: NETokens.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Text(
                              'Switch ↗',
                              style: GoogleFonts.manrope(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: NETokens.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Portion Confirmation Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'How much did you have?',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: NETokens.onSurface,
                          ),
                        ),
                        Text(
                          'CALIBRATED UNIT',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: NETokens.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select portion unit and quantity calibrated to standard reference servings.',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        color: NETokens.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Option 1: Standard Bowl
                    InkWell(
                      onTap: () => setState(() => _isStandardPortion = true),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _isStandardPortion
                              ? NETokens.surfaceContainerLowest
                              : NETokens.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isStandardPortion
                                ? NETokens.secondary
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Radio<bool>(
                                      value: true,
                                      groupValue: _isStandardPortion,
                                      onChanged: (val) => setState(
                                          () => _isStandardPortion = val!),
                                      activeColor: NETokens.secondary,
                                    ),
                                    Text(
                                      '1 Standard Prepared Bowl',
                                      style: GoogleFonts.manrope(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: NETokens.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: NETokens.secondaryContainer,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '~380g total',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: NETokens.primaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              children: [
                                'Salmon fillet (~150g)',
                                'Cooked quinoa (~150g)',
                                'Broccoli florets (~80g)'
                              ].map((item) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: NETokens.surfaceContainer,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item,
                                    style: GoogleFonts.manrope(
                                      fontSize: 10,
                                      color: NETokens.onSurfaceVariant,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Option 2: Custom Weight / Units
                    InkWell(
                      onTap: () => setState(() => _isStandardPortion = false),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: !_isStandardPortion
                              ? NETokens.surfaceContainerLowest
                              : NETokens.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: !_isStandardPortion
                                ? NETokens.secondary
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Radio<bool>(
                                      value: false,
                                      groupValue: _isStandardPortion,
                                      onChanged: (val) => setState(
                                          () => _isStandardPortion = val!),
                                      activeColor: NETokens.secondary,
                                    ),
                                    Text(
                                      'Custom Weight / Units',
                                      style: GoogleFonts.manrope(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: NETokens.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'GRAMS / OZ / CUPS',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: NETokens.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            if (!_isStandardPortion) ...[
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 80,
                                    height: 36,
                                    child: TextField(
                                      controller: _customWeightController,
                                      keyboardType: TextInputType.number,
                                      style: GoogleFonts.manrope(fontSize: 13),
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),
                                        filled: true,
                                        fillColor:
                                            NETokens.surfaceContainerLowest,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                            color: NETokens.secondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: NETokens.surfaceContainerLowest,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children:
                                          ['Grams', 'Oz', 'Cups'].map((unit) {
                                        final isU = _selectedUnit == unit;
                                        return InkWell(
                                          onTap: () => setState(
                                              () => _selectedUnit = unit),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isU
                                                  ? NETokens.secondary
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              unit,
                                              style: GoogleFonts.manrope(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: isU
                                                    ? Colors.white
                                                    : NETokens
                                                        .onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Preparation Matrix (Olive oil switch & Seasoning)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: NETokens.surfaceContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Added Olive Oil',
                                    style: GoogleFonts.manrope(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: NETokens.onSurface,
                                    ),
                                  ),
                                  Text(
                                    'Estimated ~1 tsp (4.5g fat)',
                                    style: GoogleFonts.manrope(
                                      fontSize: 10,
                                      color: NETokens.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: _hasOliveOil,
                                onChanged: (val) =>
                                    setState(() => _hasOliveOil = val),
                                activeColor: NETokens.secondary,
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Seasoning',
                                    style: GoogleFonts.manrope(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: NETokens.onSurface,
                                    ),
                                  ),
                                  Text(
                                    'Sea salt & lemon juice',
                                    style: GoogleFonts.manrope(
                                      fontSize: 10,
                                      color: NETokens.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: NETokens.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Standard',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: NETokens.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Transparency Callout
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.verified_outlined,
                      size: 16,
                      color: NETokens.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Nutritional calculation depends on portion accuracy. Standard USDA FoodData Central reference values will be utilized for baseline nutrient stoichiometry.',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          color: NETokens.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Actions
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _handleConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NETokens.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Confirm food details',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: TextButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.replay, size: 16),
                  label: Text(
                    'Edit or re-enter food',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: NETokens.secondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
