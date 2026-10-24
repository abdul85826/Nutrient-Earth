import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/tokens/ne_tokens.dart';

/// Screen 39: Permissions & Interrupted File Handling
/// Route: /status/permissions
/// Authoritative Stitch Reference: permissions_interrupted_input
class PermissionsInterruptedInputScreen extends StatefulWidget {
  const PermissionsInterruptedInputScreen({super.key});

  @override
  State<PermissionsInterruptedInputScreen> createState() =>
      _PermissionsInterruptedInputScreenState();
}

class _PermissionsInterruptedInputScreenState
    extends State<PermissionsInterruptedInputScreen> {
  bool _isResumingUpload = false;

  void _handleResumeUpload() async {
    setState(() => _isResumingUpload = true);
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() => _isResumingUpload = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Upload completed. Specimen queued for analysis.',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
        ),
        backgroundColor: NETokens.surfaceContainerHighest,
        behavior: SnackBarBehavior.floating,
      ),
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
              'Permissions & Recovery',
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
                        color: NETokens.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'INPUT RESILIENCE • PERMISSION & INTAKE GOVERNANCE',
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
                'Permissions & File Handling',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: NETokens.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Calm, non-punitive recovery workflows when hardware permissions are declined, files exceed parameters, or uploads disconnect.',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  color: NETokens.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),

              // Workflow 1: Camera Access Not Granted
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
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: NETokens.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.no_photography_outlined,
                                size: 18,
                                color: NETokens.secondary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Camera access not granted',
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: NETokens.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: NETokens.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'FALLBACK READY',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: NETokens.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Camera permission was declined or is disabled in your operating system. Nutrient Earth never requires a camera to analyze nutrition.',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: NETokens.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => context.push('/research/food/entry'),
                          icon: const Icon(Icons.edit_note, size: 16),
                          label: Text(
                            'Use text description instead',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: NETokens.primaryContainer,
                            foregroundColor: NETokens.onPrimary,
                            elevation: 0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Redirecting to device application settings...',
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Text(
                            'Device settings',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: NETokens.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Workflow 2: Unsupported File Format
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
                      children: [
                        const Icon(
                          Icons.file_present_outlined,
                          size: 18,
                          color: NETokens.error,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Unsupported file format',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: NETokens.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Selected file format (.webp / .heic without raw exif) cannot be parsed with spectral integrity. Please select standard JPEG, PNG, or PDF formats.',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: NETokens.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Opening document picker for supported formats...',
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.upload_file, size: 16),
                      label: Text(
                        'Select a different file',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: NETokens.secondary,
                        side: BorderSide(
                          color: NETokens.secondary.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Workflow 3: Upload Interrupted
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
                        Row(
                          children: [
                            const Icon(
                              Icons.wifi_tethering_error_rounded,
                              size: 18,
                              color: NETokens.secondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Upload interrupted',
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: NETokens.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '4.2 MB / 8.0 MB',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: NETokens.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(
                        value: 0.525,
                        minHeight: 6,
                        backgroundColor: NETokens.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          NETokens.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed:
                              _isResumingUpload ? null : _handleResumeUpload,
                          icon: _isResumingUpload
                              ? const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.play_arrow, size: 16),
                          label: Text(
                            _isResumingUpload ? 'Resuming...' : 'Resume upload',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: NETokens.secondary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Upload canceled. Temporary fragments cleared.',
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Text(
                            'Clear',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: NETokens.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Workflow 4: Preserve Unsaved Draft
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
                      children: [
                        const Icon(
                          Icons.save_as_outlined,
                          size: 18,
                          color: NETokens.secondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Preserve unsaved inquiry?',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: NETokens.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'You have an unsubmitted query with 2 custom constraints. Would you like to keep this draft for later?',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: NETokens.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Draft safely preserved in local session.',
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            context.pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: NETokens.primaryContainer,
                            foregroundColor: NETokens.onPrimary,
                            elevation: 0,
                          ),
                          child: Text(
                            'Keep draft',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: Text(
                            'Discard',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: NETokens.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
