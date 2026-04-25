import 'package:supabase_flutter/supabase_flutter.dart';

class AIService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Calls the Supabase Edge Function 'aiInsight' to get high-speed Groq insights.
  /// This ensures API keys are NEVER exposed in the frontend.
  Future<Map<String, dynamic>> getDayInsight({
    required String condition,
    required String goal,
    required String language,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'aiInsight',
        body: {
          'condition': condition,
          'goal': goal,
          'language': language,
        },
      );

      if (response.status == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        return {
          'insight': 'Focus on hydration and deep breathing today.',
          'organ_day': 'Day 1 of 30',
          'action': 'Drink 500ml of mineral water now.',
        };
      }
    } catch (e) {
      return {
        'insight': 'The earth is nourishing you. Stay steady.',
        'organ_day': 'Day 1',
        'action': 'Gentle walking for 5 minutes.',
      };
    }
  }
}
