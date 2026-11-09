// ==============================================================================
// Nutrient Earth — Doctor-Ready Clinical Consultation Modal
// Displays, previews, and exports user-reviewed medical briefings.
// Zero auto-transmission: Patient controls all clinical disclosures.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../../../core/services/summary/doctor_summary_service.dart';

class DoctorSummaryModal extends StatefulWidget {
  final DoctorConsultationSummary summary;

  const DoctorSummaryModal({
    super.key,
    required this.summary,
  });

  static Future<void> show(BuildContext context, DoctorConsultationSummary summary) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DoctorSummaryModal(summary: summary),
    );
  }

  @override
  State<DoctorSummaryModal> createState() => _DoctorSummaryModalState();
}

class _DoctorSummaryModalState extends State<DoctorSummaryModal> {
  bool _copied = false;

  void _handleCopy() {
    Clipboard.setData(ClipboardData(text: widget.summary.toFormattedClinicalText()));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.summary;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: NETokens.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: NETokens.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: NETokens.botanicalTeal.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.medical_services_rounded, color: NETokens.darkEvergreen, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Doctor Consultation Briefing',
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: NETokens.primary,
                        ),
                      ),
                      Text(
                        'Patient-Reviewed • 9 Clinical Domains',
                        style: GoogleFonts.manrope(
                          fontSize: 11.5,
                          color: NETokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 20),

          // Scrollable Dossier Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Patient Meta Header Box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: NETokens.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: NETokens.outlineVariant),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.patientDisplayName,
                                style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: NETokens.primary)),
                            Text('Age: ${s.age ?? "N/A"} • Sex: ${s.biologicalSex?.toUpperCase() ?? "N/A"}',
                                style: GoogleFonts.manrope(fontSize: 12, color: NETokens.textSecondary)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: NETokens.emerald.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'CONFIDENTIAL',
                            style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.w700, color: NETokens.emerald),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildSectionTitle('1. Chief Concerns & Goals'),
                  ...s.chiefConcernsAndGoals.map((g) => _buildBullet(g)),
                  const SizedBox(height: 14),

                  _buildSectionTitle('2. Symptom Timeline & Observations'),
                  if (s.symptomTimeline.isEmpty)
                    _buildEmptyNotice('No acute symptoms recorded.')
                  else
                    ...s.symptomTimeline.map((sym) => _buildBullet('${sym.entityName}${sym.recordValue != null ? ": ${sym.recordValue!}" : ""}')),
                  const SizedBox(height: 14),

                  _buildSectionTitle('3. Confirmed Medical History'),
                  if (s.confirmedConditions.isEmpty)
                    _buildEmptyNotice('No confirmed chronic conditions on file.')
                  else
                    ...s.confirmedConditions.map((c) => _buildBullet(c.entityName)),
                  const SizedBox(height: 14),

                  _buildSectionTitle('4. Active Medications & Supplements'),
                  if (s.activeMedicationsAndSupplements.isEmpty)
                    _buildEmptyNotice('No active medications or supplements listed.')
                  else
                    ...s.activeMedicationsAndSupplements.map((m) {
                      final val = m.recordValue != null ? ' (${m.recordValue} ${m.recordUnit ?? ""})' : '';
                      return _buildBullet('${m.entityName}$val');
                    }),
                  const SizedBox(height: 14),

                  _buildSectionTitle('5. Allergies & Sensitivities'),
                  if (s.knownAllergies.isEmpty)
                    _buildEmptyNotice('No known drug or food allergies declared.')
                  else
                    ...s.knownAllergies.map((a) => _buildBullet(a.entityName, isWarning: true)),
                  const SizedBox(height: 14),

                  _buildSectionTitle('6. Laboratory Panels & Biomarkers'),
                  if (s.recentBiomarkersAndLabs.isEmpty)
                    _buildEmptyNotice('No recent lab bloodwork results on file.')
                  else
                    ...s.recentBiomarkersAndLabs.map((l) {
                      final abnormal = l.isAbnormal == true ? ' ⚠️ Out of range' : '';
                      return _buildBullet('${l.entityName}: ${l.recordValue ?? "--"} ${l.recordUnit ?? ""}$abnormal');
                    }),
                  const SizedBox(height: 14),

                  _buildSectionTitle('7. Lifestyle Cadence'),
                  ...s.lifestyleAndBiometrics.entries.map((e) => _buildBullet('${e.key}: ${e.value}')),
                  const SizedBox(height: 14),

                  _buildSectionTitle('8. Questions Prepared for Clinician'),
                  ...s.questionsForClinician.map((q) => _buildBullet(q)),
                  const SizedBox(height: 14),

                  _buildSectionTitle('9. Data Limitations Disclosure'),
                  ...s.missingAndUncertainData.map((m) => _buildBullet(m)),
                  const SizedBox(height: 20),

                  // Legal Medical Disclaimer
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: NETokens.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: NETokens.outlineVariant),
                    ),
                    child: Text(
                      s.clinicalDisclaimer,
                      style: GoogleFonts.manrope(fontSize: 10.5, color: NETokens.textSecondary, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: NETokens.surface,
              border: Border(top: BorderSide(color: NETokens.outlineVariant)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _handleCopy,
                    icon: Icon(_copied ? Icons.check_circle_rounded : Icons.copy_rounded, size: 18),
                    label: Text(_copied ? 'Copied Clinical Text!' : 'Copy Dossier for Doctor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _copied ? NETokens.emerald : NETokens.darkEvergreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: GoogleFonts.manrope(fontSize: 12.5, fontWeight: FontWeight.w700, color: NETokens.botanicalTeal),
      ),
    );
  }

  Widget _buildBullet(String text, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: isWarning ? NETokens.error : NETokens.darkEvergreen, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: isWarning ? NETokens.error : NETokens.textPrimary,
                fontWeight: isWarning ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyNotice(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Text(text, style: GoogleFonts.manrope(fontSize: 11.5, fontStyle: FontStyle.italic, color: NETokens.textSecondary)),
    );
  }
}
