class MeasurementSystem {
  /// Abstraction for PostHog or similar analytics

  Future<void> init() async {
    // PostHog initialization
  }

  void trackOnboardingCompletion(String userId, Duration timeTaken) {
    _track('onboarding_completed', {
      'user_id': userId,
      'time_taken_seconds': timeTaken.inSeconds,
    });
  }

  void trackRecommendationView(String recommendationId, String category) {
    _track('recommendation_viewed', {
      'recommendation_id': recommendationId,
      'category': category,
    });
  }

  void trackRecommendationAction(String recommendationId, String action) {
    // action: 'accepted', 'dismissed'
    _track('recommendation_action', {
      'recommendation_id': recommendationId,
      'action': action,
    });
  }

  void trackExplanationOpen(String recommendationId) {
    _track('explanation_opened', {
      'recommendation_id': recommendationId,
    });
  }

  void _track(String eventName, Map<String, dynamic> properties) {
    // In production: Posthog().capture(eventName: eventName, properties: properties);
    print('[Analytics] $eventName: $properties');
  }
}
