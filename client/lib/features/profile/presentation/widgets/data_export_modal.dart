// ==============================================================================
// Nutrient Earth — Data Portability & Export Modal
// Account Control Centre feature:
// - Generates complete JSON archive with SHA-256 tamper-evident checksum
// - Provides Markdown summary view and CSV download options
// - Adheres to Nutrient Earth palette: #FAF8F5 canvas, #EAF0EC cards, #00251D text
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/export/personal_data_export_service.dart';

class DataExportModal extends ConsumerStatefulWidget {
  final String userId;

  const DataExportModal({
    super.key,
    required this.userId,
  });

  static Future<void> show(BuildContext context, {required String userId}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DataExportModal(userId: userId),
    );
  }

  @override
  ConsumerState<DataExportModal> createState() => _DataExportModalState();
}

class _DataExportModalState extends ConsumerState<DataExportModal> {
  bool _isGenerating = false;
  DataExportBundle? _bundle;
  String? _copiedNotification;

  Future<void> _generateExport() async {
    setState(() {
      _isGenerating = true;
      _copiedNotification = null;
    });

    try {
      final service = ref.read(personalDataExportServiceProvider);
      final bundle = await service.generateExportBundle(userId: widget.userId);
      if (mounted) {
        setState(() {
          _bundle = bundle;
          _isGenerating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate export: $e')),
        );
      }
    }
  }

  void _copyToClipboard(String content, String label) {
    Clipboard.setData(ClipboardData(text: content));
    setState(() => _copiedNotification = '$label copied to clipboard!');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFAF8F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFCCD7D0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              children: [
                const Icon(Icons.shield_outlined, color: Color(0xFF00251D), size: 24),
                const SizedBox(width: 10),
                const Text(
                  'My Data & Long-Term Archive',
                  style: TextStyle(
                    fontFamily: 'Serif',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00251D),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF00251D)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Your health records, 10-year bitemporal facts, daily research sessions, and movement interventions belong strictly to you. Export your complete data bundle anytime.',
              style: TextStyle(fontSize: 13, color: Color(0xFF4A6B5D), height: 1.4),
            ),
            const SizedBox(height: 20),

            // Generate Button
            if (_bundle == null) ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generateExport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00251D),
                    foregroundColor: const Color(0xFFFAF8F5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.download, size: 18),
                  label: Text(_isGenerating ? 'Compiling Archive...' : 'Generate Complete Data Archive'),
                ),
              ),
            ] else ...[
              // Generated Archive Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF0EC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFCCD7D0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified, size: 16, color: Color(0xFF2E7D32)),
                        const SizedBox(width: 6),
                        const Text(
                          'Archive Compiled Successfully',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF00251D)),
                        ),
                        const Spacer(),
                        Text(
                          'Schema ${_bundle!.schemaVersion}',
                          style: const TextStyle(fontSize: 10, color: Color(0xFF6B7E73)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'SHA-256 Checksum: ${_bundle!.checksumSha256.substring(0, 16)}...',
                      style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Color(0xFF2E4035)),
                    ),
                    const SizedBox(height: 14),

                    // Copy Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _copyToClipboard(_bundle!.markdownSummary, 'Markdown summary'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF00251D),
                              side: const BorderSide(color: Color(0xFF00251D)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.description_outlined, size: 14),
                            label: const Text('Copy Summary', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _copyToClipboard(_bundle!.observationsCsv, 'CSV observations'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00251D),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.table_chart_outlined, size: 14),
                            label: const Text('Copy CSV', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),

                    if (_copiedNotification != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _copiedNotification!,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
