// ==============================================================================
// Nutrient Earth — Dynamic Response Block Renderers (Schema v2026.3)
// Polymorphic presentation widgets for universal generative response engine:
// - TextBlockRenderer (Prose, lead summaries, scientific callouts)
// - ComparisonTableRenderer (Feature tables with column headers and zebra striping)
// - CodeResponseRenderer (Syntax-styled dark container with copy-to-clipboard)
// - MetricCalculationRenderer (Prominent numeric calculation with formula container)
// - ActionPlanRenderer (Actionable step checklist)
// - ProductAuditRenderer (Product/cookware toxicology safety profile)
// - SafetyNoticeRenderer (Emergency medical triage & clinical guidance notices)
// - InteractiveSuggestionsRenderer (Clickable follow-up prompt chips)
// - EvidenceCardRenderer (Peer-reviewed citations and study provenance)
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../../../core/domain/answer_contract/response_content_block.dart';

/// Top-level dispatcher rendering any polymorphic [ResponseContentBlock]
class DynamicBlockRenderer extends StatelessWidget {
  final ResponseContentBlock block;
  final ValueChanged<String>? onSuggestionTap;

  const DynamicBlockRenderer({
    super.key,
    required this.block,
    this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (block is TextBlock) {
      return TextBlockRenderer(block: block as TextBlock);
    } else if (block is ComparisonTableBlock) {
      return ComparisonTableRenderer(block: block as ComparisonTableBlock);
    } else if (block is CodeBlock) {
      return CodeResponseRenderer(block: block as CodeBlock);
    } else if (block is MetricCalculationBlock) {
      return MetricCalculationRenderer(block: block as MetricCalculationBlock);
    } else if (block is ActionPlanBlock) {
      return ActionPlanRenderer(block: block as ActionPlanBlock);
    } else if (block is ProductAuditBlock) {
      return ProductAuditRenderer(block: block as ProductAuditBlock);
    } else if (block is SafetyNoticeBlock) {
      return SafetyNoticeRenderer(block: block as SafetyNoticeBlock);
    } else if (block is InteractiveSuggestionsBlock) {
      return InteractiveSuggestionsRenderer(
        block: block as InteractiveSuggestionsBlock,
        onSuggestionTap: onSuggestionTap,
      );
    } else if (block is EvidenceCardBlock) {
      return EvidenceCardRenderer(block: block as EvidenceCardBlock);
    }

    // Graceful fallback for forward-compatible or unrecognized blocks
    return _FallbackBlockRenderer(block: block);
  }
}

class _FallbackBlockRenderer extends StatelessWidget {
  final ResponseContentBlock block;

  const _FallbackBlockRenderer({required this.block});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 16, color: Color(0xFF6B7280)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Additional structured information (${block.blockType})',
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: const Color(0xFF4B5563),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 1. Text Block Renderer
// -----------------------------------------------------------------------------
class TextBlockRenderer extends StatelessWidget {
  final TextBlock block;

  const TextBlockRenderer({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    if (block.content.trim().isEmpty) return const SizedBox.shrink();

    switch (block.calloutType) {
      case TextCalloutType.leadSummary:
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F7F4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDDE8DF)),
          ),
          child: Text(
            block.content,
            style: GoogleFonts.manrope(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: NETokens.primary,
              height: 1.5,
            ),
          ),
        );

      case TextCalloutType.insight:
      case TextCalloutType.takeaway:
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF7F0),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEADBCE)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.biotech_rounded, size: 20, color: NETokens.emerald),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  block.content,
                  style: GoogleFonts.manrope(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: NETokens.primary,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        );

      case TextCalloutType.warning:
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF9EC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 20, color: Color(0xFFD97706)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  block.content,
                  style: GoogleFonts.manrope(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF92400E),
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        );

      case TextCalloutType.none:
      default:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            block.content,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: NETokens.textSecondary,
              height: 1.55,
            ),
          ),
        );
    }
  }
}

// -----------------------------------------------------------------------------
// 2. Comparison Table Renderer
// -----------------------------------------------------------------------------
class ComparisonTableRenderer extends StatelessWidget {
  final ComparisonTableBlock block;

  const ComparisonTableRenderer({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD5E2D8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060B2B26),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table Title Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: const Color(0xFFEEF5F0),
            child: Row(
              children: [
                const Icon(Icons.table_chart_outlined, size: 16, color: NETokens.emerald),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    block.title ?? 'Comparison Table',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: NETokens.primary,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Data Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 38,
              dataRowMinHeight: 36,
              dataRowMaxHeight: 52,
              columnSpacing: 20,
              horizontalMargin: 14,
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF7FAF8)),
              columns: block.headers.map((h) {
                return DataColumn(
                  label: Text(
                    h,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: NETokens.emerald,
                    ),
                  ),
                );
              }).toList(),
              rows: block.rows.asMap().entries.map((entry) {
                final index = entry.key;
                final row = entry.value;
                final isZebra = index % 2 == 1;

                return DataRow(
                  color: WidgetStateProperty.all(isZebra ? const Color(0xFFFBF9F4) : Colors.white),
                  cells: row.cells.map((cell) {
                    return DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 180),
                        child: Text(
                          cell,
                          style: GoogleFonts.manrope(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: NETokens.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 3. Code Response Renderer
// -----------------------------------------------------------------------------
class CodeResponseRenderer extends StatefulWidget {
  final CodeBlock block;

  const CodeResponseRenderer({super.key, required this.block});

  @override
  State<CodeResponseRenderer> createState() => _CodeResponseRendererState();
}

class _CodeResponseRendererState extends State<CodeResponseRenderer> {
  bool _copied = false;

  void _handleCopy() async {
    await Clipboard.setData(ClipboardData(text: widget.block.code));
    if (mounted) {
      setState(() => _copied = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _copied = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2620),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E3D35)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar with Language Badge and Copy Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: const Color(0xFF0A1C17),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF34D399),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.block.language.toUpperCase(),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF86EFAC),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: _handleCopy,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _copied ? Icons.check_rounded : Icons.copy_rounded,
                          size: 13,
                          color: _copied ? const Color(0xFF34D399) : const Color(0xFFCBD5E1),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _copied ? 'Copied' : 'Copy code',
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _copied ? const Color(0xFF34D399) : const Color(0xFFCBD5E1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Code Body
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(14),
            child: SelectableText(
              widget.block.code,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFE2E8F0),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 4. Metric Calculation Renderer
// -----------------------------------------------------------------------------
class MetricCalculationRenderer extends StatelessWidget {
  final MetricCalculationBlock block;

  const MetricCalculationRenderer({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F8F4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD5E2D8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                block.metricName.toUpperCase(),
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: NETokens.emerald,
                  letterSpacing: 0.8,
                ),
              ),
              if (block.confidenceScore != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFD5E2D8)),
                  ),
                  child: Text(
                    '${(block.confidenceScore! * 100).toInt()}% Match',
                    style: GoogleFonts.manrope(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: NETokens.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                block.calculatedValue,
                style: GoogleFonts.newsreader(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: NETokens.primary,
                ),
              ),
              if (block.unit != null && block.unit!.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(
                  block.unit!,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: NETokens.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          if (block.formula != null && block.formula!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE4EDE6)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.functions_rounded, size: 14, color: NETokens.emerald),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Formula: ${block.formula}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: NETokens.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (block.baselineReference != null && block.baselineReference!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Reference: ${block.baselineReference}',
              style: GoogleFonts.manrope(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: NETokens.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 5. Action Plan Renderer
// -----------------------------------------------------------------------------
class ActionPlanRenderer extends StatelessWidget {
  final ActionPlanBlock block;

  const ActionPlanRenderer({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    if (block.steps.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4E9E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, size: 18, color: NETokens.emerald),
              const SizedBox(width: 8),
              Text(
                block.title,
                style: GoogleFonts.manrope(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: NETokens.primary,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: block.steps.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final step = block.steps[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF5F0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: NETokens.emerald,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: NETokens.primary,
                            height: 1.35,
                          ),
                        ),
                        if (step.detail != null && step.detail!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              step.detail!,
                              style: GoogleFonts.manrope(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w400,
                                color: NETokens.textSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 6. Product Audit Renderer
// -----------------------------------------------------------------------------
class ProductAuditRenderer extends StatelessWidget {
  final ProductAuditBlock block;

  const ProductAuditRenderer({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFDFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD5E2D8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  block.productName,
                  style: GoogleFonts.newsreader(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: NETokens.primary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F4EA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCEEAD6)),
                ),
                child: Text(
                  'TOXICOLOGY AUDIT',
                  style: GoogleFonts.manrope(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF137333),
                  ),
                ),
              ),
            ],
          ),
          if (block.brand.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Category: ${block.brand}',
              style: GoogleFonts.manrope(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: NETokens.textMuted,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F7F4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield_outlined, size: 16, color: NETokens.emerald),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    block.safetyProfile,
                    style: GoogleFonts.manrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: NETokens.primary,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 7. Safety Notice Renderer
// -----------------------------------------------------------------------------
class SafetyNoticeRenderer extends StatelessWidget {
  final SafetyNoticeBlock block;

  const SafetyNoticeRenderer({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    final isEmergency = block.severity == SafetySeverity.criticalEmergency;

    final bgColor = isEmergency ? const Color(0xFFFEF2F2) : const Color(0xFFFEF9EC);
    final borderColor = isEmergency ? const Color(0xFFFECACA) : const Color(0xFFFDE68A);
    final iconColor = isEmergency ? const Color(0xFFDC2626) : const Color(0xFFD97706);
    final textColor = isEmergency ? const Color(0xFF991B1B) : const Color(0xFF92400E);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isEmergency ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
                color: iconColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  block.title,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            block.message,
            style: GoogleFonts.manrope(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: textColor,
              height: 1.45,
            ),
          ),
          if (block.emergencyActions.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final action in block.emergencyActions)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        action,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 8. Interactive Suggestions Renderer
// -----------------------------------------------------------------------------
class InteractiveSuggestionsRenderer extends StatelessWidget {
  final InteractiveSuggestionsBlock block;
  final ValueChanged<String>? onSuggestionTap;

  const InteractiveSuggestionsRenderer({
    super.key,
    required this.block,
    this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (block.promptChips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EXPLORE FURTHER',
            style: GoogleFonts.manrope(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: NETokens.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: block.promptChips.map((chipText) {
              return InkWell(
                onTap: () {
                  if (onSuggestionTap != null) {
                    onSuggestionTap!(chipText);
                  }
                },
                borderRadius: BorderRadius.circular(NETokens.radiusFull),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(NETokens.radiusFull),
                    border: Border.all(color: const Color(0xFFD5E2D8)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x040B2B26),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.search_rounded, size: 13, color: NETokens.emerald),
                      const SizedBox(width: 6),
                      Text(
                        chipText,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: NETokens.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 9. Evidence Card Renderer
// -----------------------------------------------------------------------------
class EvidenceCardRenderer extends StatelessWidget {
  final EvidenceCardBlock block;

  const EvidenceCardRenderer({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    if (!block.hasVerifiedSources || block.citations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD5E2D8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_rounded, size: 16, color: NETokens.emerald),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  block.watermarkLabel,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: NETokens.emerald,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: block.citations.length,
            separatorBuilder: (_, __) => const Divider(color: Color(0xFFF1EBE0), height: 16),
            itemBuilder: (context, index) {
              final cit = block.citations[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cit.title,
                    style: GoogleFonts.manrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: NETokens.primary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${cit.authorsOrJournal} (${cit.year}) • ${cit.evidenceGrade}',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: NETokens.textSecondary,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
