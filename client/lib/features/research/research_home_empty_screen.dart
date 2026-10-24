import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/tokens/ne_tokens.dart';

/// Screen 16: Research Home First Use / Empty State
/// Primary Tab 0: /research
/// Authoritative Stitch Design: research_home_first_use_empty_state
class ResearchHomeEmptyScreen extends StatefulWidget {
  const ResearchHomeEmptyScreen({super.key});

  @override
  State<ResearchHomeEmptyScreen> createState() =>
      _ResearchHomeEmptyScreenState();
}

class _ResearchHomeEmptyScreenState extends State<ResearchHomeEmptyScreen> {
  final _queryController = TextEditingController();
  String _activeMode = 'text'; // 'text', 'image', 'doc', 'voice'

  String get _placeholderText {
    switch (_activeMode) {
      case 'image':
        return 'Attach specimen image or describe the botanical subject...';
      case 'doc':
        return 'Reference soil analysis, lab report, or diagnostic export...';
      case 'voice':
        return 'Listening for research inquiry... (tap to speak)';
      case 'text':
      default:
        return 'What would you like to understand or improve?';
    }
  }

  void _submitInquiry() {
    final query = _queryController.text.trim();
    if (query.isEmpty) {
      context.go('/research/composer');
    } else {
      context.go('/research/review?q=${Uri.encodeComponent(query)}');
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NETokens.surface,
      appBar: AppBar(
        title: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                width: 28,
                height: 28,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.eco, size: 22, color: NETokens.secondary),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Research',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: NETokens.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: NETokens.secondary),
            tooltip: 'Research History',
            onPressed: () => context.go('/history'),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: NETokens.secondary),
            tooltip: 'Personal Context',
            onPressed: () => context.go('/profile/context'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: NETokens.outline),
            tooltip: 'Privacy & Data Controls',
            onPressed: () => context.go('/profile/privacy'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: NETokens.space16, vertical: NETokens.space12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // New Inquiry Box Card
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
                            const Icon(Icons.query_stats, size: 16, color: NETokens.secondary),
                            const SizedBox(width: 6),
                            Text(
                              'NEW INQUIRY',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                                color: NETokens.secondary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: NETokens.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(NETokens.radiusXs),
                          ),
                          child: Text(
                            'ID // NE-01',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              color: NETokens.outline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: NETokens.space12),

                    // Textarea
                    Container(
                      decoration: BoxDecoration(
                        color: NETokens.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(NETokens.radiusMd),
                        border: Border.all(color: NETokens.outlineVariant.withOpacity(0.5)),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        controller: _queryController,
                        maxLines: 3,
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          color: NETokens.onSurface,
                          height: 1.4,
                        ),
                        decoration: InputDecoration.collapsed(
                          hintText: _placeholderText,
                          hintStyle: GoogleFonts.manrope(
                            fontSize: 14,
                            color: NETokens.outline,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: NETokens.space12),

                    // Multimodal selector + arrow button
                    Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _ModeButton(
                                  icon: Icons.edit_note,
                                  label: 'Text',
                                  isActive: _activeMode == 'text',
                                  onTap: () => setState(() => _activeMode = 'text'),
                                ),
                                const SizedBox(width: 6),
                                _ModeButton(
                                  icon: Icons.add_a_photo,
                                  label: 'Image',
                                  isActive: _activeMode == 'image',
                                  onTap: () {
                                    setState(() => _activeMode = 'image');
                                    // Also provides access to contextual food entry
                                    context.go('/research/food/entry');
                                  },
                                ),
                                const SizedBox(width: 6),
                                _ModeButton(
                                  icon: Icons.description,
                                  label: 'Document',
                                  isActive: _activeMode == 'doc',
                                  onTap: () => setState(() => _activeMode = 'doc'),
                                ),
                                const SizedBox(width: 6),
                                _ModeButton(
                                  icon: Icons.mic,
                                  label: 'Voice',
                                  isActive: _activeMode == 'voice',
                                  onTap: () => setState(() => _activeMode = 'voice'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: _submitInquiry,
                          borderRadius: BorderRadius.circular(NETokens.radiusMd),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: NETokens.primary,
                              borderRadius: BorderRadius.circular(NETokens.radiusMd),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.arrow_upward_rounded,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: NETokens.space20),

              // First Use Empty State Card
              Container(
                padding: const EdgeInsets.all(NETokens.space20),
                decoration: BoxDecoration(
                  color: NETokens.primaryContainer,
                  borderRadius: BorderRadius.circular(NETokens.radiusLg),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: NETokens.secondary.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(NETokens.radiusLg),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.science_rounded,
                          size: 28,
                          color: Color(0xFFC5EBDD),
                        ),
                      ),
                    ),
                    const SizedBox(height: NETokens.space16),
                    Text(
                      'Your research starts here.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFC5EBDD),
                      ),
                    ),
                    const SizedBox(height: NETokens.space6),
                    Text(
                      'Ask a question to explore evidence, understand your options, and identify useful next steps.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        color: const Color(0xFFA9CEC2),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: NETokens.space20),

                    // 3 Verification Architecture Chips
                    Row(
                      children: [
                        Expanded(
                          child: _ArchChip(
                            icon: Icons.verified_rounded,
                            label: 'VERIFIED',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ArchChip(
                            icon: Icons.biotech_rounded,
                            label: 'MULTIMODAL',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ArchChip(
                            icon: Icons.lock_rounded,
                            label: 'ENCRYPTED',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: NETokens.space16),

              // Sample Scientific Question Prompts
              Text(
                'EXPLORE RECENT INQUIRIES',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: NETokens.secondary,
                ),
              ),
              const SizedBox(height: NETokens.space8),

              _SampleQueryCard(
                query:
                    'How does dietary magnesium glycinate bioavailability compare to magnesium oxide for sleep quality?',
                tags: const ['Magnesium', 'Bioavailability', 'Sleep'],
                onTap: () {
                  context.go(
                    '/research/answer?q=${Uri.encodeComponent('How does dietary magnesium glycinate bioavailability compare to magnesium oxide for sleep quality?')}',
                  );
                },
              ),
              const SizedBox(height: 8),
              _SampleQueryCard(
                query: 'Cold water immersion vs active recovery on muscle protein synthesis',
                tags: const ['Recovery', 'Hypertrophy', 'RCT Evidence'],
                onTap: () {
                  context.go(
                    '/research/answer?q=${Uri.encodeComponent('Cold water immersion vs active recovery on muscle protein synthesis')}',
                  );
                },
              ),

              const SizedBox(height: NETokens.space16),

              // Status indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(NETokens.radiusMd),
                  border: Border.all(color: NETokens.outlineVariant.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: NETokens.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Evidence repository ready for queries',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: NETokens.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'v2.4.0',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: NETokens.outline,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: NETokens.space12),

              Center(
                child: TextButton.icon(
                  onPressed: () => context.go('/support/feedback'),
                  icon: const Icon(Icons.flag_outlined, size: 15, color: NETokens.secondary),
                  label: Text(
                    'Feedback & report a problem',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: NETokens.secondary,
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

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(NETokens.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? NETokens.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(NETokens.radiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isActive ? const Color(0xFFC5EBDD) : NETokens.secondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive ? const Color(0xFFC5EBDD) : NETokens.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArchChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ArchChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: NETokens.secondary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(NETokens.radiusSm),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: const Color(0xFFC5EBDD)),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: const Color(0xFFC5EBDD),
            ),
          ),
        ],
      ),
    );
  }
}

class _SampleQueryCard extends StatelessWidget {
  final String query;
  final List<String> tags;
  final VoidCallback onTap;

  const _SampleQueryCard({
    required this.query,
    required this.tags,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(NETokens.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(NETokens.space12),
        decoration: BoxDecoration(
          color: NETokens.surfaceContainerLow,
          borderRadius: BorderRadius.circular(NETokens.radiusMd),
          border: Border.all(color: NETokens.outlineVariant.withOpacity(0.6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              query,
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: NETokens.onSurface,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: tags.map((t) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: NETokens.surfaceContainer,
                    borderRadius: BorderRadius.circular(NETokens.radiusXs),
                  ),
                  child: Text(
                    t,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: NETokens.secondary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
