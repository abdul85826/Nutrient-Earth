import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/tokens/ne_tokens.dart';

/// Screen 34: Feedback & Support (Scientific Oversight Reporting)
/// Route: /support/feedback
/// Authoritative Stitch Reference: feedback_support
class FeedbackSupportScreen extends StatefulWidget {
  const FeedbackSupportScreen({super.key});

  @override
  State<FeedbackSupportScreen> createState() => _FeedbackSupportScreenState();
}

class _FeedbackSupportScreenState extends State<FeedbackSupportScreen> {
  bool _includeContext = true;
  String? _selectedCategory;
  final _feedbackController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Inaccurate or misleading information',
    'Broken citation or missing link',
    'Technical bug or crash',
    'Feature suggestion',
    'Other inquiry',
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select an issue category',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
          ),
          backgroundColor: NETokens.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please describe the issue or suggestion',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
          ),
          backgroundColor: NETokens.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: NETokens.secondary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Feedback received and queued for review.',
              style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: NETokens.surfaceContainerHighest,
        behavior: SnackBarBehavior.floating,
      ),
    );

    context.pop();
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
              'Feedback & Support',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: NETokens.onSurface,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ribbon
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: NETokens.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'SCIENTIFIC RIGOR • REPORTING PIPELINE',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: NETokens.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'Feedback & support',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: NETokens.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tell us what went wrong or what we can improve. Your report is evaluated directly by scientific and engineering oversight teams.',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  color: NETokens.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // Attached Context Reference Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: NETokens.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.biotech,
                            size: 20,
                            color: NETokens.secondary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'ATTACHED CONTEXT',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: NETokens.secondary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: NETokens.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Active Query',
                                      style: GoogleFonts.manrope(
                                        fontSize: 9,
                                        color: NETokens.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '#REF-2024-884C',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: NETokens.onSurface,
                                ),
                              ),
                              Text(
                                'Magnesium Glycinate Bioavailability Analysis',
                                style: GoogleFonts.manrope(
                                  fontSize: 11,
                                  color: NETokens.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _includeContext,
                          onChanged: (val) =>
                              setState(() => _includeContext = val),
                          activeColor: NETokens.secondary,
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Include inquiry reference in report',
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            color: NETokens.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          _includeContext ? 'Included' : 'Excluded',
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _includeContext
                                ? NETokens.secondary
                                : NETokens.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Issue Categorization
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: NETokens.onSurface,
                      ),
                      children: const [
                        TextSpan(text: 'WHAT TYPE OF ISSUE ARE YOU REPORTING? '),
                        TextSpan(
                          text: '*',
                          style: TextStyle(color: NETokens.error),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'SINGLE-CHOICE',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      color: NETokens.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Categories List
              ..._categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return InkWell(
                  onTap: () => setState(() => _selectedCategory = cat),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? NETokens.surfaceContainerLowest
                          : NETokens.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? NETokens.secondary
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          cat,
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: NETokens.onSurface,
                          ),
                        ),
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? NETokens.secondary
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? NETokens.secondary
                                  : NETokens.outlineVariant,
                              width: 1.5,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  size: 12,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 14),

              // Textarea Field
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'DESCRIBE THE ISSUE IN DETAIL',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: NETokens.onSurface,
                    ),
                  ),
                  Wrap(
                    spacing: 6,
                    children: ['+ DOI', '+ Dosage', '+ Citation'].map((tag) {
                      return InkWell(
                        onTap: () {
                          if (_feedbackController.text.isEmpty) {
                            _feedbackController.text = '$tag: ';
                          } else {
                            _feedbackController.text += ' $tag: ';
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: NETokens.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: NETokens.secondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              Container(
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: NETokens.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: TextField(
                  controller: _feedbackController,
                  maxLines: 4,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: NETokens.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'Please provide relevant specifics, PubMed ID, or reproduction steps...',
                    hintStyle: GoogleFonts.manrope(
                      fontSize: 12,
                      color: NETokens.outlineVariant,
                    ),
                    contentPadding: const EdgeInsets.all(12),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Clinical Safety Priority Notice
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
                      Icons.warning_amber_rounded,
                      size: 18,
                      color: NETokens.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'If you are experiencing a medical emergency, adverse drug interaction, or severe clinical symptom, contact local emergency services immediately. Nutrient Earth is not an emergency triage tool.',
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
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NETokens.primaryContainer,
                    foregroundColor: NETokens.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              NETokens.onPrimary,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Submit feedback',
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
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
