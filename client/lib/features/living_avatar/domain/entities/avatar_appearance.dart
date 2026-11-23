// ==============================================================================
// Nutrient Earth — Avatar Appearance & Attachment Contract
// Models transient, context-driven wardrobe, accessories, and hand-held props.
// Enforces strict slot isolation (no duplicate hand attachments, no clothing clipping).
// ==============================================================================

import 'package:flutter/foundation.dart';

enum ClothingType {
  linenShirt,
  organicKurta,
  knitSweater,
  activeTee,
  loungewear,
  meditationRobes;

  String get displayName {
    switch (this) {
      case ClothingType.linenShirt:
        return 'Breathable Organic Linen Shirt';
      case ClothingType.organicKurta:
        return 'Traditional Handloom Cotton Kurta';
      case ClothingType.knitSweater:
        return 'Merino Wool Thermal Knit';
      case ClothingType.activeTee:
        return 'Ergonomic Athletic Top';
      case ClothingType.loungewear:
        return 'Soft Restorative Loungewear';
      case ClothingType.meditationRobes:
        return 'Natural Earth Meditation Attire';
    }
  }

  static const ClothingType botanicalLinenShirt = ClothingType.linenShirt;
}

enum OuterwearType {
  none,
  lightCardigan,
  thermalJacket,
  traditionalShawl,
  rainWindbreaker;

  static const OuterwearType tailoredTrench = OuterwearType.rainWindbreaker;
  static const OuterwearType knittedCardigan = OuterwearType.lightCardigan;
  static const OuterwearType insulatedCoat = OuterwearType.thermalJacket;
}

enum HandAttachmentType {
  none,
  waterGlass,
  herbalTeaCup,
  leatherJournal,
  freshFruit,
  scientificBook;

  static const HandAttachmentType herbalMug = HandAttachmentType.herbalTeaCup;

  String get displayName {
    switch (this) {
      case HandAttachmentType.none:
        return 'Free Hand';
      case HandAttachmentType.waterGlass:
        return 'Mineral Electrolyte Water Glass';
      case HandAttachmentType.herbalTeaCup:
        return 'Steaming Chamomile Herbal Mug';
      case HandAttachmentType.leatherJournal:
        return 'Reflective Wellness Journal';
      case HandAttachmentType.freshFruit:
        return 'Fresh Polyphenol-Rich Apple';
      case HandAttachmentType.scientificBook:
        return 'Scientific Research Volume';
    }
  }
}

enum AccessoryType {
  none,
  minimalistGlasses,
  circadianSmartRing,
  botanicalEarrings;
}

enum HeadwearType {
  none,
  sunShadeHat,
  merinoBeanie;
}

@immutable
class AvatarAppearance {
  final ClothingType clothing;
  final String clothingColorHex;
  final OuterwearType outerwear;
  final String? outerwearColorHex;
  final AccessoryType accessory;
  final HeadwearType headwear;
  final HandAttachmentType leftHandAttachment;
  final HandAttachmentType rightHandAttachment;

  const AvatarAppearance({
    this.clothing = ClothingType.linenShirt,
    this.clothingColorHex = '#0B2B26', // Nutrient Earth Deep Green
    this.outerwear = OuterwearType.none,
    this.outerwearColorHex,
    this.accessory = AccessoryType.none,
    this.headwear = HeadwearType.none,
    this.leftHandAttachment = HandAttachmentType.none,
    HandAttachmentType? rightHandAttachment,
    HandAttachmentType? handAttachment,
  }) : rightHandAttachment = handAttachment ?? rightHandAttachment ?? HandAttachmentType.none;

  HandAttachmentType get handAttachment =>
      rightHandAttachment != HandAttachmentType.none
          ? rightHandAttachment
          : leftHandAttachment;

  AvatarAppearance copyWithSafeSlots({
    ClothingType? clothing,
    String? clothingColorHex,
    OuterwearType? outerwear,
    String? outerwearColorHex,
    AccessoryType? accessory,
    HeadwearType? headwear,
    HandAttachmentType? handAttachment,
    HandAttachmentType? leftHandAttachment,
    HandAttachmentType? rightHandAttachment,
  }) {
    final effectiveRight = handAttachment ?? rightHandAttachment ?? this.rightHandAttachment;
    final effectiveLeft = leftHandAttachment ?? this.leftHandAttachment;
    return AvatarAppearance.validated(
      clothing: clothing ?? this.clothing,
      clothingColorHex: clothingColorHex ?? this.clothingColorHex,
      outerwear: outerwear ?? this.outerwear,
      outerwearColorHex: outerwearColorHex ?? this.outerwearColorHex,
      accessory: accessory ?? this.accessory,
      headwear: headwear ?? this.headwear,
      leftHand: effectiveLeft,
      rightHand: effectiveRight,
    );
  }

  /// Factory verifying slot isolation: left and right hands must never hold the same object simultaneously
  factory AvatarAppearance.validated({
    required ClothingType clothing,
    required String clothingColorHex,
    OuterwearType outerwear = OuterwearType.none,
    String? outerwearColorHex,
    AccessoryType accessory = AccessoryType.none,
    HeadwearType headwear = HeadwearType.none,
    HandAttachmentType leftHand = HandAttachmentType.none,
    HandAttachmentType rightHand = HandAttachmentType.none,
  }) {
    // If user attempted to assign same prop to both hands, right hand takes priority, left resets
    HandAttachmentType resolvedLeft = leftHand;
    HandAttachmentType resolvedRight = rightHand;
    if (resolvedLeft != HandAttachmentType.none && resolvedLeft == resolvedRight) {
      resolvedLeft = HandAttachmentType.none;
    }

    return AvatarAppearance(
      clothing: clothing,
      clothingColorHex: clothingColorHex,
      outerwear: outerwear,
      outerwearColorHex: outerwearColorHex,
      accessory: accessory,
      headwear: headwear,
      leftHandAttachment: resolvedLeft,
      rightHandAttachment: resolvedRight,
    );
  }

  /// Default baseline appearance (Nutrient Earth core styling)
  factory AvatarAppearance.defaultBaseline() {
    return const AvatarAppearance(
      clothing: ClothingType.linenShirt,
      clothingColorHex: '#0B2B26',
      outerwear: OuterwearType.none,
      accessory: AccessoryType.none,
      headwear: HeadwearType.none,
      leftHandAttachment: HandAttachmentType.none,
      rightHandAttachment: HandAttachmentType.none,
    );
  }

  AvatarAppearance copyWith({
    ClothingType? clothing,
    String? clothingColorHex,
    OuterwearType? outerwear,
    String? outerwearColorHex,
    AccessoryType? accessory,
    HeadwearType? headwear,
    HandAttachmentType? leftHandAttachment,
    HandAttachmentType? rightHandAttachment,
  }) {
    HandAttachmentType newLeft = leftHandAttachment ?? this.leftHandAttachment;
    HandAttachmentType newRight = rightHandAttachment ?? this.rightHandAttachment;
    if (newLeft != HandAttachmentType.none && newLeft == newRight) {
      newLeft = HandAttachmentType.none;
    }

    return AvatarAppearance(
      clothing: clothing ?? this.clothing,
      clothingColorHex: clothingColorHex ?? this.clothingColorHex,
      outerwear: outerwear ?? this.outerwear,
      outerwearColorHex: outerwearColorHex ?? this.outerwearColorHex,
      accessory: accessory ?? this.accessory,
      headwear: headwear ?? this.headwear,
      leftHandAttachment: newLeft,
      rightHandAttachment: newRight,
    );
  }

  Map<String, dynamic> toJson() => {
        'clothing': clothing.name,
        'clothing_color_hex': clothingColorHex,
        'outerwear': outerwear.name,
        'outerwear_color_hex': outerwearColorHex,
        'accessory': accessory.name,
        'headwear': headwear.name,
        'left_hand_attachment': leftHandAttachment.name,
        'right_hand_attachment': rightHandAttachment.name,
      };

  factory AvatarAppearance.fromJson(Map<String, dynamic> json) {
    return AvatarAppearance.validated(
      clothing: ClothingType.values.firstWhere(
        (e) => e.name == json['clothing'],
        orElse: () => ClothingType.linenShirt,
      ),
      clothingColorHex: json['clothing_color_hex'] as String? ?? '#0B2B26',
      outerwear: OuterwearType.values.firstWhere(
        (e) => e.name == json['outerwear'],
        orElse: () => OuterwearType.none,
      ),
      outerwearColorHex: json['outerwear_color_hex'] as String?,
      accessory: AccessoryType.values.firstWhere(
        (e) => e.name == json['accessory'],
        orElse: () => AccessoryType.none,
      ),
      headwear: HeadwearType.values.firstWhere(
        (e) => e.name == json['headwear'],
        orElse: () => HeadwearType.none,
      ),
      leftHand: HandAttachmentType.values.firstWhere(
        (e) => e.name == json['left_hand_attachment'],
        orElse: () => HandAttachmentType.none,
      ),
      rightHand: HandAttachmentType.values.firstWhere(
        (e) => e.name == json['right_hand_attachment'],
        orElse: () => HandAttachmentType.none,
      ),
    );
  }
}
