abstract class LLMProvider {
  String get providerName;

  /// Generates a completion from the LLM based on a structured prompt
  Future<String> generateCompletion({
    required String systemPrompt,
    required String userPrompt,
    double temperature = 0.3,
  });
}

class OpenAIProvider implements LLMProvider {
  final String apiKey;
  final String modelName;

  OpenAIProvider({required this.apiKey, this.modelName = 'gpt-4o'});

  @override
  String get providerName => 'openai';

  @override
  Future<String> generateCompletion({
    required String systemPrompt,
    required String userPrompt,
    double temperature = 0.3,
  }) async {
    // API integration logic goes here
    return 'Simulated OpenAI Response';
  }
}

class OpenRouterProvider implements LLMProvider {
  final String apiKey;
  final String modelName;

  OpenRouterProvider({required this.apiKey, this.modelName = 'meta-llama/llama-3-70b-instruct'});

  @override
  String get providerName => 'openrouter';

  @override
  Future<String> generateCompletion({
    required String systemPrompt,
    required String userPrompt,
    double temperature = 0.3,
  }) async {
    // API integration logic goes here
    return 'Simulated OpenRouter Response';
  }
}
