// ==============================================================================
// Nutrient Earth — Input Processing View
// Faithful representation of the Multimodal Processing Lifecycle
// Matches the reference design (blurry input, viewfinder brackets, progress, checklist).
// ==============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';

class InputProcessingView extends StatefulWidget {
  final String query;
  final String? imageAssetPath;
  final VoidCallback? onCompleted;
  final VoidCallback? onBack;

  const InputProcessingView({
    super.key,
    this.query = 'Can I use this herbal shampoo? Is t good for hair fall?',
    this.imageAssetPath = 'assets/images/blurry_shampoo_input.png',
    this.onCompleted,
    this.onBack,
  });

  @override
  State<InputProcessingView> createState() => _InputProcessingViewState();
}

class _InputProcessingViewState extends State<InputProcessingView> {
  int _activeStage = 0; // 0..4 stages completed
  Timer? _timer;

  final List<String> _stages = const [
    'Enhancing image',
    'Identifying product',
    'Reading ingredients',
    'Checking evidence',
  ];

  @override
  void initState() {
    super.initState();
    _startProcessingSimulation();
  }

  void _startProcessingSimulation() {
    _timer = Timer.periodic(const Duration(milliseconds: 650), (timer) {
      if (!mounted) return;
      setState(() {
        if (_activeStage < _stages.length) {
          _activeStage++;
        } else {
          timer.cancel();
          // Hold completed state briefly so the user sees all 4 checkmarks
          Future.delayed(const Duration(milliseconds: 700), () {
            if (mounted && widget.onCompleted != null) {
              widget.onCompleted!();
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _skipToResult() {
    _timer?.cancel();
    if (mounted && widget.onCompleted != null) {
      widget.onCompleted!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: NETokens.primary),
          tooltip: 'Back',
          onPressed: widget.onBack ?? () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/today');
            }
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.eco_rounded, color: Color(0xFF2E7D32), size: 22),
            const SizedBox(width: 6),
            Text(
              'Nutrient Earth',
              style: GoogleFonts.newsreader(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: NETokens.primary,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border_rounded, color: NETokens.primary),
            tooltip: 'Bookmark',
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded, color: NETokens.primary),
            tooltip: 'Options',
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Query Chat Bubble
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F2),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFDCE5E0)),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      size: 20,
                      color: NETokens.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F4F6),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Text(
                        widget.query,
                        style: GoogleFonts.manrope(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Image Viewfinder with Corner Brackets
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Uploaded / Blurred Image
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxHeight: 280),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: widget.imageAssetPath != null
                            ? Image.asset(
                                widget.imageAssetPath!,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => _buildPlaceholderImage(),
                              )
                            : _buildPlaceholderImage(),
                      ),

                      // Viewfinder 4 Corner Brackets
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _ViewfinderCornersPainter(
                            color: Colors.white.withOpacity(0.92),
                            strokeWidth: 3.2,
                            cornerLength: 28,
                            padding: 18,
                          ),
                        ),
                      ),

                      // "Your Input (Blurry)" badge overlay — Centered at bottom
                      Positioned(
                        bottom: 14,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.68),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.image_outlined, color: Colors.white, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  'Your Input (Blurry)',
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // "Analyzing image..." Pill Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF8F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFCCEBD4)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.image_rounded,
                      color: Color(0xFF2E7D32),
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Analyzing image...',
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F3E22),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Animated Sequential Checklist
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                child: Column(
                  children: List.generate(_stages.length, (index) {
                    final isComplete = _activeStage > index;
                    final isInProgress = _activeStage == index;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isComplete
                                  ? const Color(0xFF2E7D32)
                                  : isInProgress
                                      ? const Color(0xFFE0F2E9)
                                      : const Color(0xFFE5E7EB),
                            ),
                            child: Center(
                              child: isComplete
                                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 15)
                                  : isInProgress
                                      ? const SizedBox(
                                          width: 12,
                                          height: 12,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                                          ),
                                        )
                                      : null,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            _stages[index],
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: isComplete || isInProgress ? FontWeight.w600 : FontWeight.w500,
                              color: isComplete || isInProgress
                                  ? const Color(0xFF1F2937)
                                  : const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),

              // Quick skip / tap to view result
              Center(
                child: TextButton(
                  onPressed: _skipToResult,
                  child: Text(
                    'Skip to Verified Answer →',
                    style: GoogleFonts.manrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2E7D32),
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

  Widget _buildPlaceholderImage() {
    return Container(
      height: 240,
      color: const Color(0xFF2A3B32),
      child: const Center(
        child: Icon(Icons.spa_rounded, color: Colors.white54, size: 48),
      ),
    );
  }
}

/// Custom painter for camera viewfinder corner brackets
class _ViewfinderCornersPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double cornerLength;
  final double padding;

  const _ViewfinderCornersPainter({
    required this.color,
    required this.strokeWidth,
    required this.cornerLength,
    required this.padding,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final left = padding;
    final top = padding;
    final right = size.width - padding;
    final bottom = size.height - padding;

    // Top-Left corner
    canvas.drawLine(Offset(left, top + cornerLength), Offset(left, top), paint);
    canvas.drawLine(Offset(left, top), Offset(left + cornerLength, top), paint);

    // Top-Right corner
    canvas.drawLine(Offset(right - cornerLength, top), Offset(right, top), paint);
    canvas.drawLine(Offset(right, top), Offset(right, top + cornerLength), paint);

    // Bottom-Left corner
    canvas.drawLine(Offset(left, bottom - cornerLength), Offset(left, bottom), paint);
    canvas.drawLine(Offset(left, bottom), Offset(left + cornerLength, bottom), paint);

    // Bottom-Right corner
    canvas.drawLine(Offset(right - cornerLength, bottom), Offset(right, bottom), paint);
    canvas.drawLine(Offset(right, bottom), Offset(right, bottom - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant _ViewfinderCornersPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.cornerLength != cornerLength ||
        oldDelegate.padding != padding;
  }
}
