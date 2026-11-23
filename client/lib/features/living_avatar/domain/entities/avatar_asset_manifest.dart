// ==============================================================================
// Nutrient Earth — Versioned Avatar Asset Manifest & Pipeline Contract
// Enforces strict asset registration, slot compatibility, master identity
// verification, and procedural fallback configuration.
// ==============================================================================

import 'package:flutter/foundation.dart';
import 'avatar_identity.dart';
import 'avatar_appearance.dart';

enum AssetSlotType {
  baseBody,
  faceGeometry,
  hairStyle,
  clothingBase,
  outerwearLayer,
  headwearSlot,
  leftHandProp,
  rightHandProp,
  skyEnvironment,
  lightingMask,
  particleEngine;
}

enum AssetFormatType {
  proceduralFlutterPainter,
  riveBinary,
  rasterPngWebp,
  vectorSvg;
}

@immutable
class AvatarAssetRecord {
  final String assetId;
  final String version;
  final AssetSlotType slot;
  final String supportedRigId;
  final AssetFormatType format;
  final int resolutionPx;
  final String? bundlePath;
  final bool isProcedural;
  final String? fallbackAssetId;
  final Map<String, dynamic> compatibilityMetadata;

  const AvatarAssetRecord({
    required this.assetId,
    required this.version,
    required this.slot,
    required this.supportedRigId,
    required this.format,
    this.resolutionPx = 256,
    this.bundlePath,
    this.isProcedural = false,
    this.fallbackAssetId,
    this.compatibilityMetadata = const {},
  });

  Map<String, dynamic> toJson() => {
        'asset_id': assetId,
        'version': version,
        'slot': slot.name,
        'supported_rig_id': supportedRigId,
        'format': format.name,
        'resolution_px': resolutionPx,
        'bundle_path': bundlePath,
        'is_procedural': isProcedural,
        'fallback_asset_id': fallbackAssetId,
        'compatibility_metadata': compatibilityMetadata,
      };
}

@immutable
class ManifestValidationResult {
  final bool isValid;
  final List<String> issues;
  final List<AvatarAssetRecord> resolvedAssets;

  const ManifestValidationResult({
    required this.isValid,
    this.issues = const [],
    this.resolvedAssets = const [],
  });
}

@immutable
class AvatarAssetManifest {
  final String manifestVersion;
  final String masterRigId;
  final Map<String, AvatarAssetRecord> registry;

  const AvatarAssetManifest({
    required this.manifestVersion,
    required this.masterRigId,
    required this.registry,
  });

  /// Validates whether an AvatarAppearance and AvatarIdentity have matching, compatible assets.
  ManifestValidationResult validateSceneAssets({
    required AvatarIdentity identity,
    required AvatarAppearance appearance,
  }) {
    final issues = <String>[];
    final resolved = <AvatarAssetRecord>[];

    // 1. Verify Base Rig
    if (identity.baseRigId != masterRigId) {
      issues.add('Identity base rig "${identity.baseRigId}" does not match manifest master rig "$masterRigId"');
    }

    // 2. Validate Clothing Slot
    final clothingKey = 'clothing_${appearance.clothing.name}';
    final clothingAsset = registry[clothingKey];
    if (clothingAsset == null) {
      issues.add('Missing registered asset for clothing "${appearance.clothing.name}"');
    } else {
      resolved.add(clothingAsset);
    }

    // 3. Validate Outerwear Slot
    if (appearance.outerwear != OuterwearType.none) {
      final outerwearKey = 'outerwear_${appearance.outerwear.name}';
      final outerwearAsset = registry[outerwearKey];
      if (outerwearAsset == null) {
        issues.add('Missing registered asset for outerwear "${appearance.outerwear.name}"');
      } else {
        resolved.add(outerwearAsset);
      }
    }

    // 4. Validate Hand Attachments (Slot Exclusivity)
    if (appearance.leftHandAttachment != HandAttachmentType.none &&
        appearance.leftHandAttachment == appearance.rightHandAttachment) {
      issues.add('Dual-hand collision: prop "${appearance.leftHandAttachment.name}" cannot be held in both hands simultaneously');
    }

    if (appearance.rightHandAttachment != HandAttachmentType.none) {
      final propKey = 'prop_${appearance.rightHandAttachment.name}';
      final propAsset = registry[propKey];
      if (propAsset == null) {
        issues.add('Missing registered asset for right hand prop "${appearance.rightHandAttachment.name}"');
      } else {
        resolved.add(propAsset);
      }
    }

    return ManifestValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
      resolvedAssets: resolved,
    );
  }

  /// Master production baseline manifest
  factory AvatarAssetManifest.productionBaseline() {
    final records = <String, AvatarAssetRecord>{
      // Base Rig & Geometry
      'base_body_female_01': const AvatarAssetRecord(
        assetId: 'base_body_female_01',
        version: '2026.3.0',
        slot: AssetSlotType.baseBody,
        supportedRigId: 'rig_ne_living_v1',
        format: AssetFormatType.proceduralFlutterPainter,
        isProcedural: true,
      ),

      // Clothing Variants
      'clothing_linenShirt': const AvatarAssetRecord(
        assetId: 'clothing_linenShirt',
        version: '2026.3.0',
        slot: AssetSlotType.clothingBase,
        supportedRigId: 'rig_ne_living_v1',
        format: AssetFormatType.proceduralFlutterPainter,
        isProcedural: true,
      ),
      'clothing_organicKurta': const AvatarAssetRecord(
        assetId: 'clothing_organicKurta',
        version: '2026.3.0',
        slot: AssetSlotType.clothingBase,
        supportedRigId: 'rig_ne_living_v1',
        format: AssetFormatType.proceduralFlutterPainter,
        isProcedural: true,
      ),
      'clothing_knitSweater': const AvatarAssetRecord(
        assetId: 'clothing_knitSweater',
        version: '2026.3.0',
        slot: AssetSlotType.clothingBase,
        supportedRigId: 'rig_ne_living_v1',
        format: AssetFormatType.proceduralFlutterPainter,
        isProcedural: true,
      ),
      'clothing_activeTee': const AvatarAssetRecord(
        assetId: 'clothing_activeTee',
        version: '2026.3.0',
        slot: AssetSlotType.clothingBase,
        supportedRigId: 'rig_ne_living_v1',
        format: AssetFormatType.proceduralFlutterPainter,
        isProcedural: true,
      ),
      'clothing_loungewear': const AvatarAssetRecord(
        assetId: 'clothing_loungewear',
        version: '2026.3.0',
        slot: AssetSlotType.clothingBase,
        supportedRigId: 'rig_ne_living_v1',
        format: AssetFormatType.proceduralFlutterPainter,
        isProcedural: true,
      ),
      'clothing_meditationRobes': const AvatarAssetRecord(
        assetId: 'clothing_meditationRobes',
        version: '2026.3.0',
        slot: AssetSlotType.clothingBase,
        supportedRigId: 'rig_ne_living_v1',
        format: AssetFormatType.proceduralFlutterPainter,
        isProcedural: true,
      ),

      // Outerwear
      'outerwear_lightCardigan': const AvatarAssetRecord(
        assetId: 'outerwear_lightCardigan',
        version: '2026.3.0',
        slot: AssetSlotType.outerwearLayer,
        supportedRigId: 'rig_ne_living_v1',
        format: AssetFormatType.proceduralFlutterPainter,
        isProcedural: true,
      ),
      'outerwear_thermalJacket': const AvatarAssetRecord(
        assetId: 'outerwear_thermalJacket',
        version: '2026.3.0',
        slot: AssetSlotType.outerwearLayer,
        supportedRigId: 'rig_ne_living_v1',
        format: AssetFormatType.proceduralFlutterPainter,
        isProcedural: true,
      ),
      'outerwear_traditionalShawl': const AvatarAssetRecord(
        assetId: 'outerwear_traditionalShawl',
        version: '2026.3.0',
        slot: AssetSlotType.outerwearLayer,
        supportedRigId: 'rig_ne_living_v1',
        format: AssetFormatType.proceduralFlutterPainter,
        isProcedural: true,
      ),
      'outerwear_rainWindbreaker': const AvatarAssetRecord(
        assetId: 'outerwear_rainWindbreaker',
        version: '2026.3.0',
        slot: AssetSlotType.outerwearLayer,
        supportedRigId: 'rig_ne_living_v1',
        format: AssetFormatType.proceduralFlutterPainter,
        isProcedural: true,
      ),

      // Handheld Props
      'prop_waterGlass': const AvatarAssetRecord(
        assetId: 'prop_waterGlass',
        version: '2026.3.0',
        slot: AssetSlotType.rightHandProp,
        supportedRigId: 'rig_ne_living_v1',
        format: AssetFormatType.proceduralFlutterPainter,
        isProcedural: true,
      ),
      'prop_herbalTeaCup': const AvatarAssetRecord(
        assetId: 'prop_herbalTeaCup',
        version: '2026.3.0',
        slot: AssetSlotType.rightHandProp,
        supportedRigId: 'rig_ne_living_v1',
        format: AssetFormatType.proceduralFlutterPainter,
        isProcedural: true,
      ),
      'prop_leatherJournal': const AvatarAssetRecord(
        assetId: 'prop_leatherJournal',
        version: '2026.3.0',
        slot: AssetSlotType.rightHandProp,
        supportedRigId: 'rig_ne_living_v1',
        format: AssetFormatType.proceduralFlutterPainter,
        isProcedural: true,
      ),
      'prop_freshFruit': const AvatarAssetRecord(
        assetId: 'prop_freshFruit',
        version: '2026.3.0',
        slot: AssetSlotType.rightHandProp,
        supportedRigId: 'rig_ne_living_v1',
        format: AssetFormatType.proceduralFlutterPainter,
        isProcedural: true,
      ),
      'prop_scientificBook': const AvatarAssetRecord(
        assetId: 'prop_scientificBook',
        version: '2026.3.0',
        slot: AssetSlotType.rightHandProp,
        supportedRigId: 'rig_ne_living_v1',
        format: AssetFormatType.proceduralFlutterPainter,
        isProcedural: true,
      ),

      // Celestial Environment & Particles
      'env_sky_diurnal': const AvatarAssetRecord(
        assetId: 'env_sky_diurnal',
        version: '2026.3.0',
        slot: AssetSlotType.skyEnvironment,
        supportedRigId: 'rig_ne_living_v1',
        format: AssetFormatType.proceduralFlutterPainter,
        isProcedural: true,
      ),
      'env_particles_weather': const AvatarAssetRecord(
        assetId: 'env_particles_weather',
        version: '2026.3.0',
        slot: AssetSlotType.particleEngine,
        supportedRigId: 'rig_ne_living_v1',
        format: AssetFormatType.proceduralFlutterPainter,
        isProcedural: true,
      ),
    };

    return AvatarAssetManifest(
      manifestVersion: '2026.3.2',
      masterRigId: 'rig_ne_living_v1',
      registry: records,
    );
  }
}
