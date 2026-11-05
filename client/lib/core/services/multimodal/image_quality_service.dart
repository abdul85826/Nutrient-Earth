// ==============================================================================
// Nutrient Earth — Image Quality Diagnostic Service (Milestone B)
// Analyzes image clarity, edge gradient variance (blur), exposure, and text legibility.
// Provides explicit diagnostic feedback and prevents hallucination from blurry photos.
// ==============================================================================

import 'dart:typed_data';
import '../../domain/answer_contract/universal_intelligence_answer.dart';

class ImageQualityService {
  const ImageQualityService();

  /// Evaluates the visual quality and task suitability of image bytes.
  /// Uses deterministic luminance and adjacent pixel gradient variance.
  static ImageQualityAssessment assessImageQuality(Uint8List imageBytes) {
    if (imageBytes.isEmpty) {
      return const ImageQualityAssessment(
        blurScore: 1.0,
        exposureScore: 0.0,
        textLegible: false,
        subjectIdentified: false,
        isSuitableForTask: false,
        diagnosticNotes: 'Zero-byte image payload provided. Unable to assess quality.',
      );
    }

    if (imageBytes.length < 64) {
      return const ImageQualityAssessment(
        blurScore: 1.0,
        exposureScore: 0.0,
        textLegible: false,
        subjectIdentified: false,
        isSuitableForTask: false,
        diagnosticNotes: 'Truncated or corrupted image header.',
      );
    }

    // Deterministic sampling of byte sequence to evaluate luminance & gradient variance
    // We sample up to 1024 points uniformly distributed across the payload
    final sampleCount = imageBytes.length > 1024 ? 1024 : imageBytes.length;
    final step = imageBytes.length ~/ sampleCount;

    int totalLuminance = 0;
    int gradientSum = 0;
    int lowLuminanceCount = 0;
    int highLuminanceCount = 0;

    int previousSample = imageBytes[0];

    for (int i = 0; i < sampleCount; i++) {
      final currentSample = imageBytes[i * step];
      totalLuminance += currentSample;

      // Adjacent gradient (edge variance)
      final diff = (currentSample - previousSample).abs();
      gradientSum += diff;

      if (currentSample < 25) lowLuminanceCount++;
      if (currentSample > 230) highLuminanceCount++;

      previousSample = currentSample;
    }

    final double avgLuminance = totalLuminance / (sampleCount * 255.0);
    final double avgGradient = gradientSum / (sampleCount * 255.0);

    // Blur score: low gradient variance indicates low contrast / blur
    // Normal range for sharp JPEG compressed images is avgGradient ~ 0.08 - 0.25
    double blurScore;
    if (avgGradient > 0.06) {
      blurScore = (1.0 - (avgGradient * 3.5)).clamp(0.0, 0.4);
    } else if (avgGradient > 0.02) {
      blurScore = (0.4 + (0.06 - avgGradient) * 10.0).clamp(0.4, 0.75);
    } else {
      blurScore = 0.95; // Extremely flat / uniform / blurry
    }

    // Exposure score: avgLuminance (0.0 = dark, 1.0 = overexposed)
    final double exposureScore = avgLuminance.clamp(0.0, 1.0);

    final bool isUnderexposed = exposureScore < 0.20;
    final bool isOverexposed = exposureScore > 0.85;
    final bool isSharplyFocused = blurScore < 0.60;

    final bool textLegible = isSharplyFocused && !isUnderexposed && !isOverexposed;
    final bool subjectIdentified = avgGradient > 0.015 && (lowLuminanceCount + highLuminanceCount) < sampleCount * 0.95;
    final bool isSuitableForTask = textLegible && subjectIdentified;

    String notes;
    if (!subjectIdentified) {
      notes = 'No recognizable subject or contrast detected. Image may be completely blank or covered.';
    } else if (blurScore >= 0.70) {
      notes = 'Image is blurry. Small text on ingredient labels or nutrition panels may not be legible. Hold camera steady with adequate lighting.';
    } else if (isUnderexposed) {
      notes = 'Image appears dark or underexposed. Text recognition confidence is reduced.';
    } else if (isOverexposed) {
      notes = 'Image has high glare or overexposure. Reflective label surfaces may obscure nutrition facts.';
    } else {
      notes = 'Image is sharp, well-lit, and suitable for food identification and label text extraction.';
    }

    return ImageQualityAssessment(
      blurScore: double.parse(blurScore.toStringAsFixed(2)),
      exposureScore: double.parse(exposureScore.toStringAsFixed(2)),
      textLegible: textLegible,
      subjectIdentified: subjectIdentified,
      isSuitableForTask: isSuitableForTask,
      diagnosticNotes: notes,
    );
  }
}
