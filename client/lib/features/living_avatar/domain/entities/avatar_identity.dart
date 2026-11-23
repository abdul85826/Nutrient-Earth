// ==============================================================================
// Nutrient Earth — Permanent Avatar Identity Contract
// Immutable core geometry, proportions, and biological presentation features.
// Strict rule: Identity is NEVER modified by world-state or environmental shifts.
// ==============================================================================

import 'package:flutter/foundation.dart';

enum FaceGeometryType {
  oval,
  round,
  angular,
  oblong,
  square;

  String get displayName {
    switch (this) {
      case FaceGeometryType.oval:
        return 'Harmonious Oval';
      case FaceGeometryType.round:
        return 'Soft Round';
      case FaceGeometryType.angular:
        return 'Chiseled Angular';
      case FaceGeometryType.oblong:
        return 'Elongated Oblong';
      case FaceGeometryType.square:
        return 'Structured Square';
    }
  }
}

enum EyeShapeType {
  almond,
  deepSet,
  hooded,
  round,
  wideAwake;
}

enum NoseShapeType {
  straight,
  button,
  aquiline,
  broad,
  refined;
}

enum MouthShapeType {
  neutral,
  full,
  defined,
  gentleSmile;
}

enum HairstyleIdentity {
  wavyMedium,
  straightShort,
  curlyCoils,
  braidedCrown,
  croppedFade,
  naturalCurls,
  topKnot;

  String get displayName {
    switch (this) {
      case HairstyleIdentity.wavyMedium:
        return 'Wavy Natural Medium';
      case HairstyleIdentity.straightShort:
        return 'Straight Classic Short';
      case HairstyleIdentity.curlyCoils:
        return 'Rich Textured Coils';
      case HairstyleIdentity.braidedCrown:
        return 'Traditional Braided Crown';
      case HairstyleIdentity.croppedFade:
        return 'Clean Cropped Taper';
      case HairstyleIdentity.naturalCurls:
        return 'Lively Natural Curls';
      case HairstyleIdentity.topKnot:
        return 'Restorative Top Knot';
    }
  }
}

/// Permanent, Immutable Character Identity.
/// Remains perfectly identical across day/night, seasons, weather, and wardrobe shifts.
@immutable
class AvatarIdentity {
  final String identityId;
  final String name;
  final String identityVersion;
  final String baseRigId;
  final FaceGeometryType faceGeometry;
  final EyeShapeType eyeShape;
  final NoseShapeType noseShape;
  final MouthShapeType mouthShape;
  final HairstyleIdentity hairIdentity;
  final String skinToneHex;
  final String eyeColorHex;
  final String hairColorHex;
  final double eyeSpacingRatio; // 0.8 to 1.2
  final double jawWidthRatio; // 0.8 to 1.2
  final double shoulderWidthRatio; // 0.85 to 1.15
  final double characterScale; // 0.9 to 1.1
  final String assetManifestVersion;

  const AvatarIdentity({
    required this.identityId,
    this.name = 'Companion',
    this.identityVersion = '2026.3.0',
    this.baseRigId = 'rig_ne_living_v1',
    this.faceGeometry = FaceGeometryType.oval,
    this.eyeShape = EyeShapeType.almond,
    this.noseShape = NoseShapeType.straight,
    this.mouthShape = MouthShapeType.neutral,
    this.hairIdentity = HairstyleIdentity.wavyMedium,
    this.skinToneHex = '#E0AC69',
    this.eyeColorHex = '#2C1E14',
    this.hairColorHex = '#1B1C19',
    this.eyeSpacingRatio = 1.0,
    this.jawWidthRatio = 1.0,
    this.shoulderWidthRatio = 1.0,
    this.characterScale = 1.0,
    this.assetManifestVersion = '2026.3',
  });

  /// Verified default baseline identity (Sarah Jenkins prototype archetype)
  factory AvatarIdentity.defaultBaseline({String? skinToneHex, String? name}) {
    return AvatarIdentity(
      identityId: 'id_default_explorer_01',
      name: name ?? 'Companion',
      skinToneHex: skinToneHex ?? '#E0AC69',
    );
  }

  AvatarIdentity copyWith({
    String? identityId,
    String? name,
    String? identityVersion,
    String? baseRigId,
    FaceGeometryType? faceGeometry,
    EyeShapeType? eyeShape,
    NoseShapeType? noseShape,
    MouthShapeType? mouthShape,
    HairstyleIdentity? hairIdentity,
    String? skinToneHex,
    String? eyeColorHex,
    String? hairColorHex,
    double? eyeSpacingRatio,
    double? jawWidthRatio,
    double? shoulderWidthRatio,
    double? characterScale,
    String? assetManifestVersion,
  }) {
    return AvatarIdentity(
      identityId: identityId ?? this.identityId,
      name: name ?? this.name,
      identityVersion: identityVersion ?? this.identityVersion,
      baseRigId: baseRigId ?? this.baseRigId,
      faceGeometry: faceGeometry ?? this.faceGeometry,
      eyeShape: eyeShape ?? this.eyeShape,
      noseShape: noseShape ?? this.noseShape,
      mouthShape: mouthShape ?? this.mouthShape,
      hairIdentity: hairIdentity ?? this.hairIdentity,
      skinToneHex: skinToneHex ?? this.skinToneHex,
      eyeColorHex: eyeColorHex ?? this.eyeColorHex,
      hairColorHex: hairColorHex ?? this.hairColorHex,
      eyeSpacingRatio: eyeSpacingRatio ?? this.eyeSpacingRatio,
      jawWidthRatio: jawWidthRatio ?? this.jawWidthRatio,
      shoulderWidthRatio: shoulderWidthRatio ?? this.shoulderWidthRatio,
      characterScale: characterScale ?? this.characterScale,
      assetManifestVersion: assetManifestVersion ?? this.assetManifestVersion,
    );
  }

  Map<String, dynamic> toJson() => {
        'identity_id': identityId,
        'name': name,
        'identity_version': identityVersion,
        'base_rig_id': baseRigId,
        'face_geometry': faceGeometry.name,
        'eye_shape': eyeShape.name,
        'nose_shape': noseShape.name,
        'mouth_shape': mouthShape.name,
        'hair_identity': hairIdentity.name,
        'skin_tone_hex': skinToneHex,
        'eye_color_hex': eyeColorHex,
        'hair_color_hex': hairColorHex,
        'eye_spacing_ratio': eyeSpacingRatio,
        'jaw_width_ratio': jawWidthRatio,
        'shoulder_width_ratio': shoulderWidthRatio,
        'character_scale': characterScale,
        'asset_manifest_version': assetManifestVersion,
      };

  factory AvatarIdentity.fromJson(Map<String, dynamic> json) {
    return AvatarIdentity(
      identityId: json['identity_id'] as String? ?? 'id_default_explorer_01',
      name: json['name'] as String? ?? 'Companion',
      identityVersion: json['identity_version'] as String? ?? '2026.3.0',
      baseRigId: json['base_rig_id'] as String? ?? 'rig_ne_living_v1',
      faceGeometry: FaceGeometryType.values.firstWhere(
        (e) => e.name == json['face_geometry'],
        orElse: () => FaceGeometryType.oval,
      ),
      eyeShape: EyeShapeType.values.firstWhere(
        (e) => e.name == json['eye_shape'],
        orElse: () => EyeShapeType.almond,
      ),
      noseShape: NoseShapeType.values.firstWhere(
        (e) => e.name == json['nose_shape'],
        orElse: () => NoseShapeType.straight,
      ),
      mouthShape: MouthShapeType.values.firstWhere(
        (e) => e.name == json['mouth_shape'],
        orElse: () => MouthShapeType.neutral,
      ),
      hairIdentity: HairstyleIdentity.values.firstWhere(
        (e) => e.name == json['hair_identity'],
        orElse: () => HairstyleIdentity.wavyMedium,
      ),
      skinToneHex: json['skin_tone_hex'] as String? ?? '#E0AC69',
      eyeColorHex: json['eye_color_hex'] as String? ?? '#2C1E14',
      hairColorHex: json['hair_color_hex'] as String? ?? '#1B1C19',
      eyeSpacingRatio: (json['eye_spacing_ratio'] as num?)?.toDouble() ?? 1.0,
      jawWidthRatio: (json['jaw_width_ratio'] as num?)?.toDouble() ?? 1.0,
      shoulderWidthRatio: (json['shoulder_width_ratio'] as num?)?.toDouble() ?? 1.0,
      characterScale: (json['character_scale'] as num?)?.toDouble() ?? 1.0,
      assetManifestVersion: json['asset_manifest_version'] as String? ?? '2026.3',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvatarIdentity &&
          runtimeType == other.runtimeType &&
          identityId == other.identityId &&
          faceGeometry == other.faceGeometry &&
          eyeShape == other.eyeShape &&
          hairIdentity == other.hairIdentity &&
          skinToneHex == other.skinToneHex;

  @override
  int get hashCode =>
      identityId.hashCode ^
      faceGeometry.hashCode ^
      eyeShape.hashCode ^
      hairIdentity.hashCode ^
      skinToneHex.hashCode;
}
