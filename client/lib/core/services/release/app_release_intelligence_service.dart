// ==============================================================================
// Nutrient Earth — App Release Intelligence Service
// Part of God Mode User Lifecycle, Retention & Communication Intelligence
// ==============================================================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/lifecycle/installation_models.dart';
import '../../domain/release/release_metadata_models.dart';

abstract class AppReleaseIntelligenceService {
  Future<UpdateEligibilityResult> checkForUpdates({
    required DevicePlatform platform,
    required String currentVersion,
    required int currentBuildNumber,
  });

  Future<AppReleaseMetadataEntity?> getLatestRelease(DevicePlatform platform);

  Future<void> publishReleaseMetadata(AppReleaseMetadataEntity release);
}

class DefaultAppReleaseIntelligenceService
    implements AppReleaseIntelligenceService {
  final SupabaseClient? _supabase;
  final Map<DevicePlatform, AppReleaseMetadataEntity> _releasesCache = {};

  DefaultAppReleaseIntelligenceService({SupabaseClient? supabase})
      : _supabase = supabase;

  @override
  Future<UpdateEligibilityResult> checkForUpdates({
    required DevicePlatform platform,
    required String currentVersion,
    required int currentBuildNumber,
  }) async {
    final release = await getLatestRelease(platform);
    if (release == null) {
      // If no release metadata exists for platform, assume up to date
      return UpdateEligibilityResult(
        action: UpdateAction.upToDate,
        currentVersion: currentVersion,
        currentBuildNumber: currentBuildNumber,
        targetVersion: currentVersion,
        targetBuildNumber: currentBuildNumber,
        isCriticalSecurityUpdate: false,
        releaseNotes: '',
        storeUrl: '',
        reason: 'No release metadata registered for platform.',
      );
    }

    return release.evaluateEligibility(
      clientVersion: currentVersion,
      clientBuildNumber: currentBuildNumber,
    );
  }

  @override
  Future<AppReleaseMetadataEntity?> getLatestRelease(
      DevicePlatform platform) async {
    if (_releasesCache.containsKey(platform)) {
      return _releasesCache[platform];
    }

    if (_supabase != null) {
      try {
        final res = await _supabase
            .from('app_release_metadata')
            .select()
            .eq('platform', platform.toDbValue())
            .order('latest_build_number', ascending: false)
            .limit(1)
            .maybeSingle();

        if (res != null) {
          final entity = AppReleaseMetadataEntity.fromMap(
              Map<String, dynamic>.from(res as Map));
          _releasesCache[platform] = entity;
          return entity;
        }
      } catch (_) {}
    }

    return null;
  }

  @override
  Future<void> publishReleaseMetadata(AppReleaseMetadataEntity release) async {
    _releasesCache[release.platform] = release;
    if (_supabase != null) {
      try {
        await _supabase
            .from('app_release_metadata')
            .upsert(release.toMap(), onConflict: 'release_id');
      } catch (_) {}
    }
  }
}
