// ==============================================================================
// Nutrient Earth — Video Multimodal Intelligence Models
// Differentiates directly observed visual information, spoken audio statements,
// on-screen text (OCR), and identifies audio-visual discrepancies.
// ==============================================================================

enum VideoObservationType {
  visualDirect,
  spokenAudio,
  onScreenTextOcr,
  inferredContext;

  String get value => name;
}

class TimelineObservation {
  final int timestampSeconds;
  final VideoObservationType observationType;
  final String observedContent;
  final double confidence;
  final Map<String, dynamic>? boundingBox;

  const TimelineObservation({
    required this.timestampSeconds,
    required this.observationType,
    required this.observedContent,
    this.confidence = 1.0,
    this.boundingBox,
  });

  Map<String, dynamic> toJson() => {
        'timestamp_seconds': timestampSeconds,
        'observation_type': observationType.value,
        'observed_content': observedContent,
        'confidence': confidence,
        'bounding_box': boundingBox,
      };
}

class VideoMultimodalReport {
  final String ingestionId;
  final String videoUrlOrPath;
  final int durationSeconds;
  final int frameSamplesCount;
  final List<String> visualEntities;
  final List<String> onScreenTextList;
  final List<Map<String, dynamic>> audioTranscriptSegments;
  final List<TimelineObservation> observations;
  final List<String> discrepancyNotes;
  final String detectedLanguage;
  final DateTime analyzedAt;

  const VideoMultimodalReport({
    required this.ingestionId,
    required this.videoUrlOrPath,
    required this.durationSeconds,
    this.frameSamplesCount = 0,
    this.visualEntities = const [],
    this.onScreenTextList = const [],
    this.audioTranscriptSegments = const [],
    this.observations = const [],
    this.discrepancyNotes = const [],
    this.detectedLanguage = 'en',
    required this.analyzedAt,
  });

  Map<String, dynamic> toJson() => {
        'ingestion_id': ingestionId,
        'video_url_or_path': videoUrlOrPath,
        'duration_seconds': durationSeconds,
        'frame_samples_count': frameSamplesCount,
        'visual_entities': visualEntities,
        'on_screen_text_list': onScreenTextList,
        'audio_transcript_segments': audioTranscriptSegments,
        'observations': observations.map((o) => o.toJson()).toList(),
        'discrepancy_notes': discrepancyNotes,
        'detected_language': detectedLanguage,
        'analyzed_at': analyzedAt.toIso8601String(),
      };
}
