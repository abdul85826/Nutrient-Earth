import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/tokens/ne_tokens.dart';

/// Screen 27: Food Analysis Entry (Multimodal Input)
/// Route: /research/food/entry
/// Authoritative Stitch Reference: food_analysis_entry_multimodal_input
class FoodAnalysisEntryScreen extends StatefulWidget {
  const FoodAnalysisEntryScreen({super.key});

  @override
  State<FoodAnalysisEntryScreen> createState() =>
      _FoodAnalysisEntryScreenState();
}

class _FoodAnalysisEntryScreenState extends State<FoodAnalysisEntryScreen> {
  int _activeMethodIndex = 0; // 0: Text, 1: Photo, 2: Label, 3: Voice
  final _foodInputController = TextEditingController();
  final _portionController = TextEditingController();
  final _cookingController = TextEditingController();
  final _ingredientsController = TextEditingController();

  bool _isContextExpanded = false;
  bool _isDictating = false;
  bool _isAnalyzing = false;
  String? _selectedPhotoName;
  String? _scannedBarcode;

  @override
  void dispose() {
    _foodInputController.dispose();
    _portionController.dispose();
    _cookingController.dispose();
    _ingredientsController.dispose();
    super.dispose();
  }

  void _handleAnalyze() async {
    final text = _foodInputController.text.trim();
    if (text.isEmpty && _selectedPhotoName == null && _scannedBarcode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please provide a food name, photo, or scan',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
          ),
          backgroundColor: NETokens.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isAnalyzing = true);
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() => _isAnalyzing = false);

    // If barcode was scanned, go to packaged food label analysis
    if (_activeMethodIndex == 2 && _scannedBarcode != null) {
      context.push('/research/food/label');
      return;
    }

    // Otherwise navigate to Food Identification & Portion Confirmation (Screen 26)
    context.push(
      '/research/food/confirm',
      extra: {
        'query': text.isNotEmpty
            ? text
            : (_selectedPhotoName ?? 'Salmon with Quinoa & Broccoli'),
        'portion': _portionController.text.trim(),
        'cooking': _cookingController.text.trim(),
        'ingredients': _ingredientsController.text.trim(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
              'Food Analysis',
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
              // Protocol Telemetry Subtitle Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: NETokens.secondaryContainer.withValues(alpha: 0.5),
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
                          'RESEARCH PROTOCOL • MULTIMODAL INTAKE',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: NETokens.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.verified_user_outlined,
                        size: 13,
                        color: NETokens.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'v4.2-DIAG',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          color: NETokens.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Narrative Framing
              Text(
                "Understand what you're eating",
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: NETokens.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Share a food, meal, or nutrition label to explore its nutritional content and relevant limitations.',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  color: NETokens.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),

              // Multimodal Method Selector Tabs
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    _buildMethodTab(0, Icons.edit_note, 'Text'),
                    _buildMethodTab(1, Icons.photo_camera, 'Photo'),
                    _buildMethodTab(2, Icons.qr_code_scanner, 'Label'),
                    _buildMethodTab(3, Icons.mic, 'Dictate'),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Multimodal Input Canvas
              Container(
                padding: const EdgeInsets.all(14),
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
                        Row(
                          children: [
                            const Icon(
                              Icons.psychology_outlined,
                              size: 16,
                              color: NETokens.secondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'ADD A FOOD OR MEAL TO ANALYZE',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: NETokens.secondary,
                              ),
                            ),
                          ],
                        ),
                        if (_activeMethodIndex == 0)
                          Text(
                            '${_foodInputController.text.length}/200',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              color: NETokens.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Method 0: Text Input
                    if (_activeMethodIndex == 0) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: NETokens.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _foodInputController,
                              maxLength: 200,
                              maxLines: 3,
                              onChanged: (_) => setState(() {}),
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                color: NETokens.onSurface,
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    'Enter a food, meal, or ingredient (e.g. Sourdough toast with poached egg & avocado)...',
                                hintStyle: GoogleFonts.manrope(
                                  fontSize: 13,
                                  color: NETokens.outlineVariant,
                                ),
                                counterText: '',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            if (_foodInputController.text.isNotEmpty)
                              Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  onTap: () => setState(
                                      () => _foodInputController.clear()),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.cancel,
                                        size: 13,
                                        color: NETokens.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Clear',
                                        style: GoogleFonts.manrope(
                                          fontSize: 11,
                                          color: NETokens.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],

                    // Method 1: Photo Upload
                    if (_activeMethodIndex == 1) ...[
                      InkWell(
                        onTap: () {
                          setState(() {
                            _selectedPhotoName = 'salmon_quinoa_bowl.jpg';
                            _foodInputController.text =
                                'Pacific Wild Coho Salmon with Quinoa & Steamed Broccoli';
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            color: NETokens.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  color: NETokens.secondaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add_a_photo,
                                  size: 22,
                                  color: NETokens.onSecondaryContainer,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Take or upload photo',
                                style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: NETokens.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Tap to select meal picture from camera or gallery',
                                style: GoogleFonts.manrope(
                                  fontSize: 11,
                                  color: NETokens.onSurfaceVariant,
                                ),
                              ),
                              if (_selectedPhotoName != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: NETokens.secondaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Selected: $_selectedPhotoName',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: NETokens.secondary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],

                    // Method 2: Label / Barcode Scanner
                    if (_activeMethodIndex == 2) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: NETokens.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: NETokens.primaryFixed,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.document_scanner,
                                size: 22,
                                color: NETokens.onPrimaryFixed,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Packaged label / barcode',
                              style: GoogleFonts.manrope(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: NETokens.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Scan Nutrition Facts table or UPC-A barcode',
                              style: GoogleFonts.manrope(
                                fontSize: 11,
                                color: NETokens.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _scannedBarcode = '#UPC-88402914';
                                  _foodInputController.text =
                                      'Nutrient Earth Botanical Sleep Complex';
                                });
                              },
                              icon: const Icon(Icons.qr_code_scanner, size: 16),
                              label: Text(
                                _scannedBarcode != null
                                    ? 'Scanned: $_scannedBarcode'
                                    : 'Open Diagnostic Scanner',
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: NETokens.surfaceContainerHigh,
                                foregroundColor: NETokens.primary,
                                elevation: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Method 3: Voice / Audio Dictation
                    if (_activeMethodIndex == 3) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: NETokens.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _isDictating = !_isDictating;
                                  if (_isDictating) {
                                    _foodInputController.text =
                                        'Grilled wild salmon with cooked quinoa and a cup of steamed broccoli';
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(28),
                              child: Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: _isDictating
                                      ? NETokens.error
                                      : NETokens.secondary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isDictating ? Icons.stop : Icons.mic,
                                  size: 26,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _isDictating
                                  ? 'Listening...'
                                  : 'Dictate meal intake',
                              style: GoogleFonts.manrope(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: NETokens.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isDictating
                                  ? 'Speech recognized: "Grilled wild salmon..."'
                                  : 'Tap microphone and speak naturally',
                              style: GoogleFonts.manrope(
                                fontSize: 11,
                                color: NETokens.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Expandable Context Dossier: Preparation & Portion Details
              Container(
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => setState(
                          () => _isContextExpanded = !_isContextExpanded),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.tune,
                                  size: 16,
                                  color: NETokens.secondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Add details for a better estimate',
                                  style: GoogleFonts.manrope(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: NETokens.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: NETokens.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Optional',
                                    style: GoogleFonts.manrope(
                                      fontSize: 10,
                                      color: NETokens.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  _isContextExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  size: 18,
                                  color: NETokens.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_isContextExpanded) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'APPROXIMATE PORTION SIZE (OPTIONAL)',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: NETokens.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextField(
                              controller: _portionController,
                              style: GoogleFonts.manrope(fontSize: 13),
                              decoration: InputDecoration(
                                hintText:
                                    'e.g. 1 medium bowl, 200 grams, 1 fillet',
                                hintStyle: GoogleFonts.manrope(
                                  fontSize: 12,
                                  color: NETokens.outlineVariant,
                                ),
                                filled: true,
                                fillColor: NETokens.surfaceContainerLowest,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'COOKING METHOD (E.G. STEAMED, GRILLED, RAW)',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: NETokens.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextField(
                              controller: _cookingController,
                              style: GoogleFonts.manrope(fontSize: 13),
                              decoration: InputDecoration(
                                hintText:
                                    'e.g. pan-seared with olive oil, steamed, raw',
                                hintStyle: GoogleFonts.manrope(
                                  fontSize: 12,
                                  color: NETokens.outlineVariant,
                                ),
                                filled: true,
                                fillColor: NETokens.surfaceContainerLowest,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 6,
                              children: [
                                '+ Raw',
                                '+ Steamed',
                                '+ Olive Oil',
                                '+ No Salt'
                              ].map((chip) {
                                return ActionChip(
                                  label: Text(
                                    chip,
                                    style: GoogleFonts.manrope(fontSize: 11),
                                  ),
                                  backgroundColor:
                                      NETokens.surfaceContainerHigh,
                                  onPressed: () {
                                    if (_cookingController.text.isEmpty) {
                                      _cookingController.text =
                                          chip.replaceAll('+ ', '');
                                    } else {
                                      _cookingController.text +=
                                          ', ${chip.replaceAll('+ ', '')}';
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Scientific Transparency & Diagnostic Bounds Notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: NETokens.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Visual estimates and natural language intake provide bounded ranges, not clinical calorimeter precision. Cooking oils and unlisted ingredients introduce variance.',
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

              // Actions Array
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isAnalyzing ? null : _handleAnalyze,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NETokens.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isAnalyzing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Analyze food',
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
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: Text(
                    'Back to Research',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: NETokens.onSurfaceVariant,
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

  Widget _buildMethodTab(int index, IconData icon, String label) {
    final isSelected = _activeMethodIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeMethodIndex = index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? NETokens.surfaceContainerLowest
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? NETokens.secondary : NETokens.onSurfaceVariant,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? NETokens.primary : NETokens.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
