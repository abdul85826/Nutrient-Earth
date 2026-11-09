// ==============================================================================
// Nutrient Earth — Personal Health Memory Modal
// Confirmation Gate interface for reviewing, confirming, or rejecting
// AI-inferred drafts, and managing confirmed clinical health records.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../../../core/domain/memory/personal_health_memory_models.dart';
import '../../../../core/services/memory/personal_health_memory_service.dart';

class PersonalHealthMemoryModal extends ConsumerStatefulWidget {
  const PersonalHealthMemoryModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const PersonalHealthMemoryModal(),
    );
  }

  @override
  ConsumerState<PersonalHealthMemoryModal> createState() => _PersonalHealthMemoryModalState();
}

class _PersonalHealthMemoryModalState extends ConsumerState<PersonalHealthMemoryModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<HealthMemoryRecord> _records = [];
  bool _isLoading = true;
  HealthRecordType? _selectedFilterType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRecords();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    final service = ref.read(personalHealthMemoryServiceProvider);
    final records = await service.getHealthRecords();
    if (mounted) {
      setState(() {
        _records = records;
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmDraft(String recordId) async {
    final service = ref.read(personalHealthMemoryServiceProvider);
    final success = await service.confirmRecord(recordId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Record confirmed and added to verified health memory.'),
          backgroundColor: NETokens.emerald,
          duration: Duration(seconds: 2),
        ),
      );
      _loadRecords();
    }
  }

  Future<void> _rejectDraft(String recordId) async {
    final service = ref.read(personalHealthMemoryServiceProvider);
    final success = await service.rejectRecord(recordId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Draft record rejected and removed.'),
          duration: Duration(seconds: 2),
        ),
      );
      _loadRecords();
    }
  }

  Future<void> _deleteRecord(String recordId) async {
    final service = ref.read(personalHealthMemoryServiceProvider);
    final success = await service.deleteRecord(recordId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Record deleted.'),
          duration: Duration(seconds: 2),
        ),
      );
      _loadRecords();
    }
  }

  void _openAddRecordDialog() {
    final nameController = TextEditingController();
    final valueController = TextEditingController();
    HealthRecordType selectedType = HealthRecordType.medication;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          backgroundColor: NETokens.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Add Health Record',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 16, color: NETokens.primary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Category', style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<HealthRecordType>(
                  value: selectedType,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: HealthRecordType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.displayName, style: GoogleFonts.manrope(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedType = val);
                  },
                ),
                const SizedBox(height: 12),
                Text('Item Name', style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Vitamin D3, Amoxicillin, Gluten',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Dosage or Note (Optional)', style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: valueController,
                  decoration: InputDecoration(
                    hintText: 'e.g. 2000 IU daily, severe rash',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel', style: TextStyle(color: NETokens.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: NETokens.darkEvergreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                Navigator.pop(dialogCtx);
                final record = HealthMemoryRecord(
                  id: const Uuid().v4(),
                  userId: 'current_user',
                  recordType: selectedType,
                  provenanceSource: MemoryProvenanceSource.userReported,
                  entityName: name,
                  recordValue: valueController.text.trim().isNotEmpty ? valueController.text.trim() : null,
                  recordedDate: DateTime.now(),
                  verificationStatus: MemoryVerificationStatus.userConfirmed,
                );

                final service = ref.read(personalHealthMemoryServiceProvider);
                await service.saveRecord(record);
                _loadRecords();
              },
              child: const Text('Save Record'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final drafts = _records.where((r) => r.verificationStatus.isDraft).toList();
    final confirmed = _records.where((r) => r.verificationStatus.isConfirmed).toList();

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
              color: NETokens.borderDefault,
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
                    color: NETokens.botanicalTeal.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.psychology_outlined, color: NETokens.darkEvergreen, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personal Health Memory',
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: NETokens.primary,
                        ),
                      ),
                      Text(
                        'Patient-Governed • Confirmation Gate Active',
                        style: GoogleFonts.manrope(
                          fontSize: 11.5,
                          color: NETokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded, color: NETokens.emerald),
                  tooltip: 'Add Record Manually',
                  onPressed: _openAddRecordDialog,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Tab Bar
          TabBar(
            controller: _tabController,
            labelColor: NETokens.primary,
            unselectedLabelColor: NETokens.textMuted,
            indicatorColor: NETokens.emerald,
            indicatorWeight: 2.5,
            labelStyle: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 13),
            unselectedLabelStyle: GoogleFonts.manrope(fontWeight: FontWeight.w500, fontSize: 13),
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Drafts for Review'),
                    if (drafts.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: NETokens.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${drafts.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Tab(text: 'Confirmed (${confirmed.length})'),
            ],
          ),
          const Divider(height: 1, color: NETokens.borderSubtle),

          // Body
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: NETokens.emerald))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDraftsTab(drafts),
                      _buildConfirmedTab(confirmed),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraftsTab(List<HealthMemoryRecord> drafts) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Governance Notice
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: NETokens.paleMint.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: NETokens.paleMint),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.verified_user_outlined, size: 18, color: NETokens.emerald),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Confirmation Gate: AI inferences and document extractions start as drafts. '
                  'Only confirmed records are included in doctor summaries or treatment recommendations.',
                  style: GoogleFonts.manrope(fontSize: 11.5, color: NETokens.primary, height: 1.3),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (drafts.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.check_circle_outline_rounded, size: 40, color: NETokens.emerald),
                  const SizedBox(height: 12),
                  Text(
                    'All caught up!',
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 15, color: NETokens.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No pending health memory drafts require review.',
                    style: GoogleFonts.manrope(fontSize: 12, color: NETokens.textSecondary),
                  ),
                ],
              ),
            ),
          )
        else
          ...drafts.map((draft) => _buildDraftCard(draft)),
      ],
    );
  }

  Widget _buildDraftCard(HealthMemoryRecord draft) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NETokens.borderDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  draft.recordType.displayName,
                  style: GoogleFonts.manrope(fontSize: 10.5, fontWeight: FontWeight.w700, color: NETokens.primary),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  draft.provenanceSource.label,
                  style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFFE65100)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            draft.entityName,
            style: GoogleFonts.manrope(fontSize: 14.5, fontWeight: FontWeight.w700, color: NETokens.primary),
          ),
          if (draft.recordValue != null) ...[
            const SizedBox(height: 2),
            Text(
              '${draft.recordValue} ${draft.recordUnit ?? ""}',
              style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600, color: NETokens.textSecondary),
            ),
          ],
          if (draft.notes != null && draft.notes!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              draft.notes!,
              style: GoogleFonts.manrope(fontSize: 11, fontStyle: FontStyle.italic, color: NETokens.textMuted),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: NETokens.error,
                    side: const BorderSide(color: NETokens.outlineVariant),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _rejectDraft(draft.id),
                  child: const Text('Reject', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NETokens.darkEvergreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _confirmDraft(draft.id),
                  child: const Text('Confirm', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmedTab(List<HealthMemoryRecord> confirmed) {
    final filtered = _selectedFilterType == null
        ? confirmed
        : confirmed.where((r) => r.recordType == _selectedFilterType).toList();

    return Column(
      children: [
        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Row(
            children: [
              FilterChip(
                selected: _selectedFilterType == null,
                label: const Text('All'),
                onSelected: (_) => setState(() => _selectedFilterType = null),
              ),
              const SizedBox(width: 6),
              ...HealthRecordType.values.map((type) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: FilterChip(
                    selected: _selectedFilterType == type,
                    label: Text(type.displayName),
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilterType = selected ? type : null;
                      });
                    },
                  ),
                );
              }),
            ],
          ),
        ),
        const Divider(height: 1, color: NETokens.borderSubtle),

        Expanded(
          child: filtered.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 36, color: NETokens.textMuted),
                        const SizedBox(height: 10),
                        Text(
                          'No records in this category.',
                          style: GoogleFonts.manrope(fontSize: 13, color: NETokens.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: NETokens.borderDefault),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: NETokens.surfaceContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(_getIconForType(item.recordType), size: 16, color: NETokens.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.entityName,
                                  style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 13.5, color: NETokens.primary),
                                ),
                                if (item.recordValue != null)
                                  Text(
                                    '${item.recordValue} ${item.recordUnit ?? ""}',
                                    style: GoogleFonts.manrope(fontSize: 11.5, color: NETokens.textSecondary),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: NETokens.textMuted),
                            tooltip: 'Delete Record',
                            onPressed: () => _deleteRecord(item.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  IconData _getIconForType(HealthRecordType type) {
    switch (type) {
      case HealthRecordType.symptom:
        return Icons.healing_rounded;
      case HealthRecordType.condition:
        return Icons.local_hospital_rounded;
      case HealthRecordType.allergy:
        return Icons.warning_amber_rounded;
      case HealthRecordType.medication:
        return Icons.medication_rounded;
      case HealthRecordType.supplement:
        return Icons.eco_rounded;
      case HealthRecordType.surgery:
        return Icons.medical_services_rounded;
      case HealthRecordType.vital:
        return Icons.favorite_rounded;
      case HealthRecordType.labResult:
        return Icons.biotech_rounded;
      case HealthRecordType.medicalDocument:
        return Icons.description_rounded;
      case HealthRecordType.lifestylePattern:
        return Icons.bedtime_rounded;
    }
  }
}
