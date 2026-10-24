import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/tokens/ne_tokens.dart';

/// Screen 19: Research Investigation In Progress
/// Authoritative Stitch Design: research_investigation_in_progress
class ResearchInvestigationInProgressScreen extends StatefulWidget {
  final String query;

  const ResearchInvestigationInProgressScreen({
    super.key,
    this.query =
        'How does dietary magnesium glycinate bioavailability compare to magnesium oxide for sleep quality?',
  });

  @override
  State<ResearchInvestigationInProgressScreen> createState() =>
      _ResearchInvestigationInProgressScreenState();
}

class _ResearchInvestigationInProgressScreenState
    extends State<ResearchInvestigationInProgressScreen> {
  int _currentStage = 1; // 0: Retrieval, 1: Analysis, 2: Synthesis, 3: Done
  Timer? _stageTimer;

  @override
  void initState() {
    super.initState();
    // Simulate real pipeline stage progression
    _stageTimer = Timer.periodic(const Duration(milliseconds: 1400), (timer) {
      if (!mounted) return;
      if (_currentStage < 2) {
        setState(() => _currentStage++);
      } else {
        timer.cancel();
        _completeTimer = Timer(const Duration(milliseconds: 600), () {
          if (mounted) {
            context.go('/research/answer?q=${Uri.encodeComponent(widget.query)}');
          }
        });
      }
    });
  }

  Timer? _completeTimer;

  @override
  void dispose() {
    _stageTimer?.cancel();
    _completeTimer?.cancel();
    super.dispose();
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NETokens.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NETokens.radiusLg)),
        icon: const Icon(Icons.cancel_outlined, size: 36, color: NETokens.error),
        title: Text(
          'Halt current research?',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: NETokens.onSurface,
          ),
        ),
        content: Text(
          'The ongoing synthesis for this query will be discontinued. Partial citations and working models will not be archived.',
          style: GoogleFonts.manrope(fontSize: 13, color: NETokens.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Continue Research',
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: NETokens.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: NETokens.primaryContainer,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/research');
            },
            child: Text(
              'Confirm Cancel',
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NETokens.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _showCancelDialog,
        ),
        title: Text(
          'Specimen Dossier',
          style: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: NETokens.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _showCancelDialog,
            child: Text(
              'Cancel',
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: NETokens.error,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: NETokens.space20, vertical: NETokens.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular Pulse Indicator
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: NETokens.secondaryContainer.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: const AlwaysStoppedAnimation<Color>(NETokens.secondary),
                      backgroundColor: NETokens.surfaceContainerHighest,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: NETokens.space20),

              Text(
                'Research in progress',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: NETokens.onSurface,
                ),
              ),
              const SizedBox(height: NETokens.space6),
              Text(
                'Gathering and evaluating the available evidence for your question.',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: NETokens.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: NETokens.space16),

              // Feedback Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(NETokens.radiusMd),
                  border: Border.all(color: NETokens.outlineVariant.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: NETokens.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _currentStage == 0
                          ? 'Retrieving controlled human trials & monographs...'
                          : _currentStage == 1
                              ? 'Cross-referencing bioavailability & pharmacokinetics...'
                              : 'Synthesizing evidence & uncertainty boundaries...',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: NETokens.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: NETokens.space24),

              // Query Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(NETokens.space16),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(NETokens.radiusMd),
                  border: Border.all(color: NETokens.outlineVariant, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.psychology_alt_outlined, size: 16, color: NETokens.secondary),
                        const SizedBox(width: 6),
                        Text(
                          'CURRENT QUERY PARAMETER',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: NETokens.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '“${widget.query}”',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: NETokens.onSurface,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: NETokens.space20),

              // Pipeline Verification Trail
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(NETokens.space16),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(NETokens.radiusMd),
                  border: Border.all(color: NETokens.outlineVariant.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PIPELINE VERIFICATION TRAIL',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: NETokens.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          'Stage ${_currentStage + 1} / 3',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: NETokens.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _StageRow(
                      title: 'Clinical Retrieval',
                      subtitle: 'Retrieving peer-reviewed clinical literature & monographs',
                      isCompleted: _currentStage > 0,
                      isActive: _currentStage == 0,
                    ),
                    const SizedBox(height: 12),
                    _StageRow(
                      title: 'Pharmacokinetic Analysis',
                      subtitle: 'Cross-referencing bioavailability & pharmacokinetic data',
                      isCompleted: _currentStage > 1,
                      isActive: _currentStage == 1,
                    ),
                    const SizedBox(height: 12),
                    _StageRow(
                      title: 'Synthesis & Bounds',
                      subtitle: 'Synthesizing evidence, conflict analysis & uncertainty bounds',
                      isCompleted: _currentStage >= 2,
                      isActive: _currentStage == 2,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: NETokens.space20),

              // Mobility Reassurance Notice
              Container(
                padding: const EdgeInsets.all(NETokens.space14),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(NETokens.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.offline_pin_outlined, size: 20, color: NETokens.secondary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'You can navigate away safely. When completed, this investigation will be available in your Research hub with full citation trails.',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: NETokens.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: NETokens.space24),

              // Cancel button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: NETokens.secondary,
                    side: BorderSide(color: NETokens.outlineVariant),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(NETokens.radiusMd),
                    ),
                  ),
                  onPressed: _showCancelDialog,
                  icon: const Icon(Icons.stop_circle_outlined, size: 18),
                  label: Text(
                    'CANCEL INVESTIGATION',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
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

class _StageRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isActive;

  const _StageRow({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: isCompleted
                ? NETokens.secondaryContainer
                : isActive
                    ? NETokens.primaryContainer
                    : NETokens.surfaceContainerHigh,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 14, color: NETokens.onSecondaryContainer)
                : isActive
                    ? Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFBBEDDC),
                          shape: BoxShape.circle,
                        ),
                      )
                    : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: NETokens.onSurface,
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: NETokens.secondaryContainer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(NETokens.radiusXs),
                      ),
                      child: Text(
                        'Completed',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: NETokens.onSecondaryContainer,
                        ),
                      ),
                    )
                  else if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: NETokens.primaryContainer,
                        borderRadius: BorderRadius.circular(NETokens.radiusXs),
                      ),
                      child: Text(
                        'Active',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFBBEDDC),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  color: NETokens.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
