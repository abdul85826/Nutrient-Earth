import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/tokens/ne_tokens.dart';

/// Screen 22: Create Goal
/// Route: /goals/create
/// Authoritative Stitch Reference: create_a_goal
class CreateAGoalScreen extends StatefulWidget {
  const CreateAGoalScreen({super.key});

  @override
  State<CreateAGoalScreen> createState() => _CreateAGoalScreenState();
}

class _CreateAGoalScreenState extends State<CreateAGoalScreen> {
  final _goalNameController = TextEditingController();
  final _outcomeController = TextEditingController();
  final _constraintsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedCategory;
  bool _isStructuring = false;
  bool _showError = false;

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Nutrition',
      'icon': Icons.psychology_alt_outlined,
    },
    {
      'name': 'Everyday habits',
      'icon': Icons.repeat,
    },
    {
      'name': 'Fitness and recovery',
      'icon': Icons.monitor_heart_outlined,
    },
    {
      'name': 'Understanding a health concern',
      'icon': Icons.medical_information_outlined,
    },
    {
      'name': 'Food or supplement knowledge',
      'icon': Icons.science_outlined,
    },
    {
      'name': 'Other',
      'icon': Icons.more_horiz,
    },
  ];

  @override
  void dispose() {
    _goalNameController.dispose();
    _outcomeController.dispose();
    _constraintsController.dispose();
    super.dispose();
  }

  void _handleContinue() async {
    final name = _goalNameController.text.trim();
    if (name.isEmpty) {
      setState(() => _showError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a name for your goal',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
          ),
          backgroundColor: NETokens.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _showError = false;
      _isStructuring = true;
    });

    // Simulate structured plan generation (respecting real loading states)
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() => _isStructuring = false);

    // Navigate to Goal Detail Plan
    context.push(
      '/goals/detail',
      extra: {
        'title': name,
        'category': _selectedCategory ?? 'Nutrition',
        'outcome': _outcomeController.text.trim(),
        'constraints': _constraintsController.text.trim(),
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
              'Create Goal',
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Interactive Progress Guidance Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: NETokens.surfaceContainer,
                    borderRadius: BorderRadius.circular(24),
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
                            'PHASE 1: FOUNDATION',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                              color: NETokens.secondary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Step 1 of 3',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: NETokens.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Editorial Heading Block
                Text(
                  'What would you like to work toward?',
                  style: GoogleFonts.manrope(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: NETokens.onSurface,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Describe the outcome that matters to you. We'll use what you share to help shape a practical next step.",
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: NETokens.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),

                // 1. Goal Name Field
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: NETokens.onSurface,
                        ),
                        children: const [
                          TextSpan(text: 'GOAL NAME '),
                          TextSpan(
                            text: '*',
                            style: TextStyle(color: NETokens.error),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${_goalNameController.text.length}/60',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: _goalNameController.text.isNotEmpty
                            ? NETokens.secondary
                            : NETokens.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: _showError
                        ? NETokens.error.withValues(alpha: 0.08)
                        : NETokens.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _showError
                          ? NETokens.error
                          : NETokens.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: TextField(
                    controller: _goalNameController,
                    maxLength: 60,
                    onChanged: (_) => setState(() {}),
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: NETokens.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Give your goal a name (e.g. Consistent Sleep Routine)',
                      hintStyle: GoogleFonts.manrope(
                        fontSize: 13,
                        color: NETokens.outlineVariant,
                      ),
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Desired Outcome Field
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'WHAT WOULD SUCCESS LOOK LIKE TO YOU?',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: NETokens.onSurface,
                      ),
                    ),
                    Text(
                      'Qualitative Target',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        color: NETokens.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: NETokens.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: NETokens.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: TextField(
                    controller: _outcomeController,
                    maxLines: 3,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: NETokens.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'Describe what you would like to improve in your own words...',
                      hintStyle: GoogleFonts.manrope(
                        fontSize: 13,
                        color: NETokens.outlineVariant,
                      ),
                      contentPadding: const EdgeInsets.all(14),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Category Single-Select Group
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CATEGORY (OPTIONAL)',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: NETokens.onSurface,
                      ),
                    ),
                    if (_selectedCategory != null)
                      Text(
                        _selectedCategory!,
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: NETokens.secondary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat['name'];
                    return InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        setState(() {
                          _selectedCategory = isSelected ? null : cat['name'];
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? NETokens.primaryContainer
                              : NETokens.surfaceContainer,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: NETokens.primaryContainer
                                        .withValues(alpha: 0.25),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              cat['icon'] as IconData,
                              size: 15,
                              color: isSelected
                                  ? NETokens.primaryFixed
                                  : NETokens.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              cat['name'] as String,
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
                const SizedBox(height: 20),

                // 4. Optional Context / Constraints Field
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ANYTHING ELSE WE SHOULD CONSIDER?',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: NETokens.onSurface,
                      ),
                    ),
                    Text(
                      'Optional',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        color: NETokens.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: NETokens.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: NETokens.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: TextField(
                    controller: _constraintsController,
                    maxLines: 2,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: NETokens.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'Add relevant constraints, daily routine limitations, or context...',
                      hintStyle: GoogleFonts.manrope(
                        fontSize: 13,
                        color: NETokens.outlineVariant,
                      ),
                      contentPadding: const EdgeInsets.all(14),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Safety & Privacy Reassurance Box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: NETokens.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: NETokens.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.health_and_safety_outlined,
                          size: 16,
                          color: NETokens.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Nutrient Earth helps frame practical habit steps. We do not prescribe clinical treatments, restrictive diets, or guaranteed medical targets.',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: NETokens.onSurfaceVariant,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Actions Group
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isStructuring ? null : _handleContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NETokens.primaryContainer,
                      foregroundColor: NETokens.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isStructuring
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    NETokens.onPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Structuring plan...',
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Continue to plan',
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
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
                  child: TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
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
      ),
    );
  }
}
