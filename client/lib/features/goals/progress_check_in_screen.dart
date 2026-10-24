import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/tokens/ne_tokens.dart';

/// Screen 24: Progress Check-in (Learn & Adapt)
/// Route: /goals/checkin
/// Authoritative Stitch Reference: progress_check_in_learn_and_adapt
class ProgressCheckInScreen extends StatefulWidget {
  const ProgressCheckInScreen({super.key});

  @override
  State<ProgressCheckInScreen> createState() => _ProgressCheckInScreenState();
}

class _ProgressCheckInScreenState extends State<ProgressCheckInScreen> {
  String? _selectedOutcome;
  String? _selectedManageability;
  final Set<String> _selectedObstacles = {};
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _outcomes = [
    {
      'id': 'completed',
      'label': 'Completed',
      'icon': Icons.task_alt,
    },
    {
      'id': 'partly',
      'label': 'Partly completed',
      'icon': Icons.timelapse,
    },
    {
      'id': 'tried',
      'label': "Tried, but couldn't finish",
      'icon': Icons.replay,
    },
    {
      'id': 'not_attempted',
      'label': 'Not attempted',
      'icon': Icons.do_not_disturb_on_outlined,
    },
  ];

  final List<Map<String, dynamic>> _manageability = [
    {
      'id': 'easier',
      'label': 'Easier than expected',
      'icon': Icons.hourglass_top,
    },
    {
      'id': 'expected',
      'label': 'About as expected',
      'icon': Icons.balance,
    },
    {
      'id': 'harder',
      'label': 'Harder than expected',
      'icon': Icons.fitness_center,
    },
    {
      'id': 'not_sure',
      'label': 'Not sure',
      'icon': Icons.help_outline,
    },
  ];

  final List<Map<String, dynamic>> _obstacles = [
    {'id': 'time', 'label': 'Time', 'icon': Icons.schedule},
    {'id': 'resources', 'label': 'Resources or cost', 'icon': Icons.payments_outlined},
    {'id': 'access', 'label': 'Access or availability', 'icon': Icons.inventory_2_outlined},
    {'id': 'physical', 'label': 'Physical difficulty', 'icon': Icons.hotel_outlined},
    {'id': 'unclear', 'label': 'Instructions were unclear', 'icon': Icons.info_outline},
    {'id': 'other', 'label': 'Other', 'icon': Icons.more_horiz},
    {'id': 'prefer_not', 'label': 'Prefer not to say', 'icon': Icons.visibility_off_outlined},
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_selectedOutcome == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select how this action went',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
          ),
          backgroundColor: NETokens.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: NETokens.secondary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Check-in saved. Recommendations adapted.',
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
              'Progress Check In',
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
              // Micro Sub-navigation & Target Micro-Habit
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => context.pop(),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_back, size: 15, color: NETokens.secondary),
                          const SizedBox(width: 4),
                          Text(
                            'BACK',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: NETokens.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: NETokens.secondaryContainer.withValues(alpha: 0.4),
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
                          'CYCLE 04 — WEEKLY CHECK',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.6,
                            color: NETokens.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Context Target Badge
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: NETokens.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.repeat,
                        size: 18,
                        color: NETokens.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TARGET MICRO-HABIT',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              color: NETokens.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '30-Minute Wind-Down & Magnesium Timing',
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
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
              const SizedBox(height: 18),

              // Header Section
              Text(
                'CALIBRATED REFLECTION',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: NETokens.secondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'How did it go?',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: NETokens.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your feedback helps you review what worked and decide what to adjust next. No judgment, streaks, or pressure.',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  color: NETokens.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // 1. Action Outcome (Single-Select)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainer,
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
                            Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: NETokens.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '1',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: NETokens.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'What happened with this action?',
                              style: GoogleFonts.manrope(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: NETokens.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'SINGLE CHOICE',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: NETokens.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._outcomes.map((opt) {
                      final isSelected = _selectedOutcome == opt['id'];
                      return InkWell(
                        onTap: () => setState(() => _selectedOutcome = opt['id']),
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
                                : NETokens.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? NETokens.secondary
                                  : NETokens.outlineVariant.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    opt['icon'] as IconData,
                                    size: 18,
                                    color: NETokens.secondary,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    opt['label'] as String,
                                    style: GoogleFonts.manrope(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: NETokens.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 16,
                                height: 16,
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
                                        size: 11,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Manageability Rating (Single-Select)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainer,
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
                            Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: NETokens.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '2',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: NETokens.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'How manageable was it?',
                              style: GoogleFonts.manrope(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: NETokens.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'EFFORT PERCEPTION',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: NETokens.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 2.2,
                      children: _manageability.map((m) {
                        final isSelected = _selectedManageability == m['id'];
                        return InkWell(
                          onTap: () =>
                              setState(() => _selectedManageability = m['id']),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? NETokens.surfaceContainerLowest
                                  : NETokens.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? NETokens.secondary
                                    : NETokens.outlineVariant
                                        .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  m['icon'] as IconData,
                                  size: 18,
                                  color: NETokens.secondary,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  m['label'] as String,
                                  style: GoogleFonts.manrope(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: NETokens.onSurface,
                                    height: 1.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Obstacles (Multi-Select)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainer,
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
                            Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: NETokens.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '3',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: NETokens.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'What got in the way? (optional)',
                              style: GoogleFonts.manrope(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: NETokens.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'MULTIPLE ALLOWED',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: NETokens.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _obstacles.map((obs) {
                        final isSelected =
                            _selectedObstacles.contains(obs['id']);
                        return InkWell(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedObstacles.remove(obs['id']);
                              } else {
                                _selectedObstacles.add(obs['id'] as String);
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? NETokens.primaryContainer
                                  : NETokens.surface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  obs['icon'] as IconData,
                                  size: 14,
                                  color: isSelected
                                      ? NETokens.primaryFixed
                                      : NETokens.secondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  obs['label'] as String,
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? NETokens.primaryFixed
                                        : NETokens.onSurface,
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
              ),
              const SizedBox(height: 16),

              // 4. Notes and Observations
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What did you notice? (optional)',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: NETokens.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: NETokens.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _notesController,
                        maxLines: 2,
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          color: NETokens.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Share any notes or subtle patterns you noticed...',
                          hintStyle: GoogleFonts.manrope(
                            fontSize: 12,
                            color: NETokens.outlineVariant,
                          ),
                          contentPadding: const EdgeInsets.all(12),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Adaptive Calibration Preview Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 18,
                      color: NETokens.secondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ADAPTIVE CALIBRATION PREVIEW',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              color: NETokens.secondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Adjusting upcoming recommendations to fit your real routine. When you mark something as harder or skipped, we adapt without shame, guilt, or streaks.',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
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
              const SizedBox(height: 24),

              // Primary Action
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
                              'Save check-in and adapt',
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
