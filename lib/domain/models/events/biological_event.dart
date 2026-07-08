import 'package:uuid/uuid.dart';

abstract class BiologicalEvent {
  final String eventId;
  final String userId; // Null/Empty if guest
  final String guestId;
  final DateTime timestamp;
  final String eventType;
  final String source; // e.g., 'manual', 'apple_health', 'ai_inference'
  final String sourceDevice; // e.g., 'iphone_15', 'oura_ring_gen3'
  final double confidence; // 0.0 - 1.0
  final double uncertainty; // 0.0 - 1.0
  final double severity; // 0.0 - 1.0 (magnitude of the event)
  final double biologicalImpact; // -1.0 (very negative) to 1.0 (very positive)
  final bool reversibility;
  final List<String> causalityChain; // List of previous Event IDs that caused this
  final List<String> linkedStateIds; // List of BiologicalState IDs this impacts
  final Map<String, dynamic> metadata;
  final int schemaVersion;

  BiologicalEvent({
    String? eventId,
    required this.userId,
    required this.guestId,
    required this.timestamp,
    required this.eventType,
    required this.source,
    required this.sourceDevice,
    required this.confidence,
    required this.uncertainty,
    required this.severity,
    required this.biologicalImpact,
    required this.reversibility,
    required this.causalityChain,
    required this.linkedStateIds,
    required this.metadata,
    this.schemaVersion = 1,
  }) : eventId = eventId ?? const Uuid().v4();

  Map<String, dynamic> toMap();

  Map<String, dynamic> baseMap() {
    return {
      'event_id': eventId,
      'user_id': userId,
      'guest_id': guestId,
      'timestamp': timestamp.toIso8601String(),
      'event_type': eventType,
      'source': source,
      'source_device': sourceDevice,
      'confidence': confidence,
      'uncertainty': uncertainty,
      'severity': severity,
      'biological_impact': biologicalImpact,
      'reversibility': reversibility,
      'causality_chain': causalityChain,
      'linked_state_ids': linkedStateIds,
      'metadata': metadata,
      'schema_version': schemaVersion,
    };
  }
}
