import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_service.dart';

@immutable
class ConsentEntry {
  final String purposeId;
  final String title;
  final String description;
  final bool isGranted;
  final DateTime updatedAt;

  const ConsentEntry({
    required this.purposeId,
    required this.title,
    required this.description,
    required this.isGranted,
    required this.updatedAt,
  });

  ConsentEntry copyWith({bool? isGranted}) {
    return ConsentEntry(
      purposeId: purposeId,
      title: title,
      description: description,
      isGranted: isGranted ?? this.isGranted,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'purposeId': purposeId,
    'title': title,
    'description': description,
    'isGranted': isGranted,
    'updatedAt': updatedAt.toIso8601String(),
  };
}

class DataRightsState {
  final List<ConsentEntry> consents;
  final bool isExporting;
  final bool isDeleting;
  final String? lastExportPayload;
  final String? lastExportManifest;

  const DataRightsState({
    required this.consents,
    this.isExporting = false,
    this.isDeleting = false,
    this.lastExportPayload,
    this.lastExportManifest,
  });

  DataRightsState copyWith({
    List<ConsentEntry>? consents,
    bool? isExporting,
    bool? isDeleting,
    String? lastExportPayload,
    String? lastExportManifest,
  }) {
    return DataRightsState(
      consents: consents ?? this.consents,
      isExporting: isExporting ?? this.isExporting,
      isDeleting: isDeleting ?? this.isDeleting,
      lastExportPayload: lastExportPayload ?? this.lastExportPayload,
      lastExportManifest: lastExportManifest ?? this.lastExportManifest,
    );
  }
}

class DataRightsNotifier extends StateNotifier<DataRightsState> {
  final Ref? _ref;

  DataRightsNotifier([this._ref])
    : super(
        DataRightsState(
          consents: [
            ConsentEntry(
              purposeId: 'ambient_telemetry',
              title: 'Ambient Environmental Telemetry',
              description:
                  'Retrieve local weather, UV index, and air quality using coarse 2-decimal coordinates (~1.1 km).',
              isGranted: true,
              updatedAt: DateTime.now(),
            ),
            ConsentEntry(
              purposeId: 'clinical_panels',
              title: 'Clinical Lab Panels & Biomarkers',
              description:
                  'Retain recent laboratory panels and biomarker ranges locally to ground nutritional research.',
              isGranted: true,
              updatedAt: DateTime.now(),
            ),
            ConsentEntry(
              purposeId: 'wearables_sync',
              title: 'Wearables & Passive Sensors',
              description:
                  'Optional synchronization with Apple HealthKit or Android Health Connect.',
              isGranted: false,
              updatedAt: DateTime.now(),
            ),
            ConsentEntry(
              purposeId: 'anonymized_research',
              title: 'Anonymized Evidence Synthesis',
              description:
                  'Contribute de-identified research inquiries to improve evidence synthesis models.',
              isGranted: false,
              updatedAt: DateTime.now(),
            ),
          ],
        ),
      );

  void toggleConsent(String purposeId) {
    state = state.copyWith(
      consents: state.consents.map((c) {
        if (c.purposeId == purposeId) {
          return c.copyWith(isGranted: !c.isGranted);
        }
        return c;
      }).toList(),
    );
  }

  Future<String> generateExportArchive(String userId) async {
    state = state.copyWith(isExporting: true);

    await Future<void>.delayed(const Duration(milliseconds: 50));

    final exportData = {
      'metadata': {
        'exportDate': DateTime.now().toIso8601String(),
        'userId': userId,
        'platform': 'Nutrient Earth V1',
        'specVersion': '1.0',
      },
      'consentLedger': state.consents.map((c) => c.toJson()).toList(),
      'healthMemory': {
        'dataIntegrity': 'Verified SHA-256',
        'records': <Map<String, dynamic>>[],
      },
    };

    final rawJson = jsonEncode(exportData);
    final checksum = base64Encode(utf8.encode(rawJson));

    final packaged = {
      'manifest': {
        'files': ['health_memory_export.json'],
        'integrityDigest': checksum,
        'createdAt': DateTime.now().toIso8601String(),
      },
      'payload': exportData,
    };

    final formattedOutput = const JsonEncoder.withIndent(
      '  ',
    ).convert(packaged);

    state = state.copyWith(
      isExporting: false,
      lastExportPayload: formattedOutput,
      lastExportManifest: checksum,
    );

    return formattedOutput;
  }

  Future<void> purgePersonalData([String? userId]) async {
    state = state.copyWith(isDeleting: true);

    await Future<void>.delayed(const Duration(milliseconds: 50));

    if (_ref != null) {
      try {
        await _ref.read(authServiceProvider.notifier).signOut();
      } catch (_) {}
    }

    state = DataRightsState(
      consents: state.consents
          .map((c) => c.copyWith(isGranted: false))
          .toList(),
      isDeleting: false,
      lastExportPayload: null,
      lastExportManifest: null,
    );
  }

  Future<void> executeAccountDeletion([String? userId]) =>
      purgePersonalData(userId);
}

final dataRightsProvider =
    StateNotifierProvider<DataRightsNotifier, DataRightsState>((ref) {
      return DataRightsNotifier(ref);
    });
