// ==============================================================================
// Nutrient Earth — Central Task-Based AI Model Registry & Router
// Defines provider capabilities, task-to-model mapping, circuit-aware cascading,
// and zero-export privacy enforcement.
// ==============================================================================

import {
  AIProviderId,
  ModelCapabilityDescriptor,
  SynthesizerRequest,
  TaskType,
} from './types.ts';
import { GroqProviderAdapter } from './groq_adapter.ts';
import { GeminiProviderAdapter } from './gemini_adapter.ts';
import { OpenRouterProviderAdapter } from './openrouter_adapter.ts';
import { ServerHealthPrivacyGuard } from './health_privacy_guard.ts';

export class CentralModelRegistry {
  private static readonly REGISTRY: ModelCapabilityDescriptor[] = [
    {
      id: 'qwen/qwen3.8-27b',
      providerId: 'groq',
      displayName: 'Qwen 3.8 27B (Groq LPU)',
      version: '3.8.2026',
      clinicalReliabilityTier: 'standard_synthesis',
      supportsMultimodal: false,
      supportsStructuredOutput: true,
      maxContextTokens: 32768,
      taskSuitability: ['intent_classification', 'general_scientific_inquiry'],
      isAvailable: true,
    },
    {
      id: 'openai/gpt-oss-120b',
      providerId: 'groq',
      displayName: 'GPT-OSS 120B (Groq LPU)',
      version: '120b.2026',
      clinicalReliabilityTier: 'high_clinical_rigor',
      supportsMultimodal: false,
      supportsStructuredOutput: true,
      maxContextTokens: 128000,
      taskSuitability: ['intent_classification', 'general_scientific_inquiry'],
      isAvailable: true,
    },
    {
      id: 'gemini-3.5-flash-lite',
      providerId: 'gemini',
      displayName: 'Google Gemini 3.5 Flash-Lite (Multimodal)',
      version: '3.5.flash-lite',
      clinicalReliabilityTier: 'high_clinical_rigor',
      supportsMultimodal: true,
      supportsStructuredOutput: true,
      maxContextTokens: 1048576,
      taskSuitability: [
        'food_image_analysis',
        'document_processing',
        'general_scientific_inquiry',
        'biometric_trend_analysis',
      ],
      isAvailable: true,
    },
    {
      id: 'gemini-2.5-flash-lite',
      providerId: 'gemini',
      displayName: 'Google Gemini 2.5 Flash-Lite (Multimodal)',
      version: '2.5.flash-lite',
      clinicalReliabilityTier: 'high_clinical_rigor',
      supportsMultimodal: true,
      supportsStructuredOutput: true,
      maxContextTokens: 1048576,
      taskSuitability: [
        'food_image_analysis',
        'document_processing',
        'general_scientific_inquiry',
      ],
      isAvailable: true,
    },
    {
      id: 'meta-llama/llama-3.3-70b-instruct',
      providerId: 'openrouter',
      displayName: 'Llama 3.3 70B Instruct (OpenRouter)',
      version: '3.3.instruct',
      clinicalReliabilityTier: 'high_clinical_rigor',
      supportsMultimodal: false,
      supportsStructuredOutput: true,
      maxContextTokens: 131072,
      taskSuitability: ['general_scientific_inquiry'],
      isAvailable: true,
    },
    {
      id: 'NutrientEarth-Deterministic-v2026.1',
      providerId: 'deterministic',
      displayName: 'Nutrient Earth Deterministic Clinical Engine',
      version: '2026.1.0',
      clinicalReliabilityTier: 'deterministic_gold',
      supportsMultimodal: false,
      supportsStructuredOutput: true,
      maxContextTokens: 65536,
      taskSuitability: [
        'personalized_clinical_guidance',
        'biometric_trend_analysis',
        'general_scientific_inquiry',
      ],
      isAvailable: true,
    },
  ];

  public static getAvailableModels(): ModelCapabilityDescriptor[] {
    return CentralModelRegistry.REGISTRY.filter((m) => m.isAvailable);
  }

  public static findModel(modelId: string): ModelCapabilityDescriptor | undefined {
    return CentralModelRegistry.REGISTRY.find((m) => m.id === modelId);
  }

  /**
   * Qualifies a fallback model to ensure fallback degradation cannot compromise clinical safety.
   */
  public static qualifyFallbackModel(
    taskType: TaskType | undefined,
    fallbackModelId: string
  ): ModelCapabilityDescriptor {
    const candidate = CentralModelRegistry.findModel(fallbackModelId);
    const deterministic = CentralModelRegistry.findModel('NutrientEarth-Deterministic-v2026.1')!;

    if (!candidate || !candidate.isAvailable) {
      return deterministic;
    }

    if (taskType === 'personalized_clinical_guidance') {
      if (candidate.clinicalReliabilityTier !== 'deterministic_gold' && candidate.clinicalReliabilityTier !== 'high_clinical_rigor') {
        return deterministic;
      }
    }

    return candidate;
  }

  /**
   * Routes a request dynamically to the optimal provider and model based on:
   * 1. Personal health privacy guard (PHI never exits to external public endpoints)
   * 2. Multimodal requirement (Images route strictly to multimodal vision models)
   * 3. Task type suitability
   * 4. Circuit breaker health
   */
  public static selectOptimalRoute(
    request: SynthesizerRequest,
    adapters: { groq: GroqProviderAdapter; gemini: GeminiProviderAdapter; openrouter?: OpenRouterProviderAdapter }
  ): { providerId: AIProviderId; modelId: string } {
    // 1. Strict Data Privacy Enforcement: Personal health context or clinical consultation
    const isPersonalHealth =
      request.containsPersonalHealthData === true ||
      request.taskType === 'personalized_clinical_guidance' ||
      ServerHealthPrivacyGuard.containsPersonalHealthData(request.query);

    if (isPersonalHealth) {
      return {
        providerId: 'deterministic',
        modelId: 'NutrientEarth-Deterministic-v2026.1',
      };
    }

    // 2. Multimodal Image Analysis: Must route to Gemini
    if (request.image || request.taskType === 'food_image_analysis') {
      if (adapters.gemini.isProviderAvailable()) {
        return {
          providerId: 'gemini',
          modelId: adapters.gemini.getModelId(),
        };
      }
      return {
        providerId: 'deterministic',
        modelId: 'NutrientEarth-Deterministic-v2026.1',
      };
    }

    // 3. User or client preference override if healthy
    if (request.preferredProvider === 'groq' && adapters.groq.isProviderAvailable()) {
      return {
        providerId: 'groq',
        modelId: request.preferredModel ?? adapters.groq.getModelId(),
      };
    }
    if (request.preferredProvider === 'gemini' && adapters.gemini.isProviderAvailable()) {
      return {
        providerId: 'gemini',
        modelId: request.preferredModel ?? adapters.gemini.getModelId(),
      };
    }
    if (request.preferredProvider === 'openrouter' && adapters.openrouter && adapters.openrouter.isProviderAvailable()) {
      return {
        providerId: 'openrouter',
        modelId: request.preferredModel ?? adapters.openrouter.getModelId(),
      };
    }

    // 4. Task-based standard routing:
    // Groq primary (speed)
    if (adapters.groq.isProviderAvailable()) {
      return { providerId: 'groq', modelId: adapters.groq.getModelId() };
    }

    // Gemini secondary (depth)
    if (adapters.gemini.isProviderAvailable()) {
      return { providerId: 'gemini', modelId: adapters.gemini.getModelId() };
    }

    // OpenRouter tertiary fallback
    if (adapters.openrouter && adapters.openrouter.isProviderAvailable()) {
      return { providerId: 'openrouter', modelId: adapters.openrouter.getModelId() };
    }

    // 5. Ultimate Fallback: Internal Deterministic Knowledge Base
    return {
      providerId: 'deterministic',
      modelId: 'NutrientEarth-Deterministic-v2026.1',
    };
  }
}

