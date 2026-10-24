import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/tokens/ne_tokens.dart';

/// Screen 17: Research Question Composer
/// Authoritative Stitch Design: research_question_composer
class ResearchQuestionComposerScreen extends StatefulWidget {
  final String? initialQuery;

  const ResearchQuestionComposerScreen({super.key, this.initialQuery});

  @override
  State<ResearchQuestionComposerScreen> createState() =>
      _ResearchQuestionComposerScreenState();
}

class _ResearchQuestionComposerScreenState
    extends State<ResearchQuestionComposerScreen> {
  late final TextEditingController _queryController;
  String _selectedMode = 'text';

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(
      text: widget.initialQuery ??
          'How does dietary magnesium glycinate bioavailability compare to magnesium oxide for sleep quality?',
    );
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _onReview() {
    final q = _queryController.text.trim();
    if (q.isEmpty) return;
    context.go('/research/review?q=${Uri.encodeComponent(q)}');
  }

  @override
  Widget build(BuildContext context) {
    final queryText = _queryController.text;

    return Scaffold(
      backgroundColor: NETokens.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Specimen Dossier',
          style: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: NETokens.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: NETokens.space20, vertical: NETokens.space12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Context
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: NETokens.secondaryContainer,
                      borderRadius: BorderRadius.circular(NETokens.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: NETokens.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'DIAGNOSTIC PROTOCOL 01',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: NETokens.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Scientific Inquiry',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: NETokens.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: NETokens.space8),

              Text(
                'What do you want to understand?',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: NETokens.onSurface,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: NETokens.space4),
              Text(
                'Ask about a health concern, nutrition question, food, ingredient, supplement, or practical goal.',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  color: NETokens.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: NETokens.space20),

              // Active Research Question Workspace
              Container(
                padding: const EdgeInsets.all(NETokens.space16),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(NETokens.radiusLg),
                  border: Border.all(color: NETokens.outlineVariant, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.biotech, size: 16, color: NETokens.secondary),
                            const SizedBox(width: 6),
                            Text(
                              'ACTIVE HYPOTHESIS MODE',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: NETokens.onSecondaryContainer,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${queryText.length} / 500',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            color: NETokens.outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: NETokens.space12),

                    // Input Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: NETokens.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(NETokens.radiusMd),
                        border: Border.all(color: NETokens.outlineVariant.withOpacity(0.5)),
                      ),
                      child: TextField(
                        controller: _queryController,
                        maxLines: 4,
                        maxLength: 500,
                        onChanged: (_) => setState(() {}),
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          color: NETokens.onSurface,
                          height: 1.4,
                        ),
                        decoration: InputDecoration.collapsed(
                          hintText: 'e.g. How does dietary magnesium glycinate bioavailability compare to magnesium oxide for sleep quality?',
                          hintStyle: GoogleFonts.manrope(color: NETokens.outline, fontSize: 14),
                        ),
                      ),
                    ),

                    const SizedBox(height: NETokens.space12),

                    // Live Scientific Intent Pill Preview
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Text(
                          'Detected Nodes: ',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            color: NETokens.outline,
                            letterSpacing: 0.5,
                          ),
                        ),
                        _IntentPill(icon: Icons.medication_outlined, label: 'Magnesium Glycinate'),
                        _IntentPill(icon: Icons.compare_arrows_rounded, label: 'Bioavailability'),
                        _IntentPill(icon: Icons.bedtime_outlined, label: 'Sleep Architecture'),
                      ],
                    ),

                    const SizedBox(height: NETokens.space16),

                    // Multimodal Toggles
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _ComposerModeChip(
                            icon: Icons.edit_note,
                            label: 'Text Inquiry',
                            isSelected: _selectedMode == 'text',
                            onTap: () => setState(() => _selectedMode = 'text'),
                          ),
                          const SizedBox(width: 8),
                          _ComposerModeChip(
                            icon: Icons.photo_camera_outlined,
                            label: 'Specimen Photo',
                            isSelected: _selectedMode == 'photo',
                            onTap: () => context.go('/research/food/entry'),
                          ),
                          const SizedBox(width: 8),
                          _ComposerModeChip(
                            icon: Icons.upload_file_outlined,
                            label: 'Lab PDF',
                            isSelected: _selectedMode == 'pdf',
                            onTap: () => setState(() => _selectedMode = 'pdf'),
                          ),
                          const SizedBox(width: 8),
                          _ComposerModeChip(
                            icon: Icons.mic_none_outlined,
                            label: 'Voice',
                            isSelected: _selectedMode == 'voice',
                            onTap: () => setState(() => _selectedMode = 'voice'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: NETokens.space16),

              // Scope Helper Card
              Container(
                padding: const EdgeInsets.all(NETokens.space12),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainer,
                  borderRadius: BorderRadius.circular(NETokens.radiusMd),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.verified_outlined, size: 18, color: NETokens.secondary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Peer-Reviewed Verification Scope',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: NETokens.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Nutrient Earth investigates published scientific literature, peer-reviewed clinical studies, and botanical monographs. Untrusted external inputs are sanitized.',
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              color: NETokens.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: NETokens.space24),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NETokens.secondary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(NETokens.radiusMd),
                    ),
                  ),
                  onPressed: _onReview,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Review question',
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: NETokens.space8),
              Center(
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: NETokens.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntentPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _IntentPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: NETokens.secondaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(NETokens.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: NETokens.secondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: NETokens.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComposerModeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ComposerModeChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(NETokens.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? NETokens.secondaryContainer : NETokens.surfaceContainer,
          borderRadius: BorderRadius.circular(NETokens.radiusFull),
          border: Border.all(
            color: isSelected ? NETokens.secondary : NETokens.outlineVariant.withOpacity(0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? NETokens.onSecondaryContainer : NETokens.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? NETokens.onSecondaryContainer : NETokens.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
