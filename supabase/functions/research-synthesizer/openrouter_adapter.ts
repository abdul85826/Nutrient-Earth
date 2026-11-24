// ==============================================================================
// Nutrient Earth — Real OpenRouter Server-Side Provider Adapter
// High-resilience fallback research synthesis via OpenRouter.
// RESILIENCE: Circuit breaker, bounded retries, rate-limit 429 backoff.
// ==============================================================================

import {
  CircuitBreakerConfig,
  CircuitState,
  ResearchAnswerPayload,
  SynthesizerRequest,
  AdapterOperationalMetrics,
} from './types.ts';
import { ServerHealthPrivacyGuard } from './health_privacy_guard.ts';

export class OpenRouterCircuitBreakerOpenError extends Error {
  constructor(message = 'OpenRouter circuit breaker is OPEN due to repeated failures.') {
    super(message);
    this.name = 'OpenRouterCircuitBreakerOpenError';
  }
}

export class OpenRouterSensitiveDataError extends Error {
  constructor(message = 'Personal health data cannot be routed to public LLM endpoints.') {
    super(message);
    this.name = 'OpenRouterSensitiveDataError';
  }
}

export class OpenRouterProviderAdapter {
  private readonly apiKey: string;
  private readonly baseUrl: string;
  private readonly defaultModel: string;
  private readonly config: CircuitBreakerConfig;

  // Circuit breaker state
  private circuitState: CircuitState = 'CLOSED';
  private consecutiveFailures = 0;
  private lastFailureTime = 0;

  // Operational metrics
  private metrics: AdapterOperationalMetrics = {
    totalRequests: 0,
    successfulRequests: 0,
    failedRequests: 0,
    throttledRequests: 0,
    circuitState: 'CLOSED',
  };

  constructor(
    customConfig?: Partial<CircuitBreakerConfig>,
    envOverrides?: { apiKey?: string; defaultModel?: string }
  ) {
    this.apiKey =
      envOverrides?.apiKey ??
      Deno.env.get('OPENROUTER_API_KEY') ??
      Deno.env.get('OPENROUTER_API_KEY_ULTRA') ??
      Deno.env.get('OPENROUTER_API_KEY_SUPER') ??
      '';
    this.baseUrl = 'https://openrouter.ai/api/v1/chat/completions';
    this.defaultModel =
      envOverrides?.defaultModel ??
      Deno.env.get('OPENROUTER_MODEL_ID') ??
      'meta-llama/llama-3.3-70b-instruct';

    this.config = {
      failureThreshold: customConfig?.failureThreshold ?? 3,
      cooldownPeriodMs: customConfig?.cooldownPeriodMs ?? 45000,
      timeoutMs: customConfig?.timeoutMs ?? 12000,
      maxRetries: customConfig?.maxRetries ?? 2,
    };
  }

  public isProviderAvailable(): boolean {
    if (!this.apiKey || this.apiKey.trim().length === 0) return false;
    this.updateCircuitState();
    return this.circuitState !== 'OPEN';
  }

  public getModelId(): string {
    return this.defaultModel;
  }

  public getCircuitState(): CircuitState {
    this.updateCircuitState();
    return this.circuitState;
  }

  public getMetrics(): Readonly<AdapterOperationalMetrics> {
    return { ...this.metrics, circuitState: this.getCircuitState() };
  }

  private updateCircuitState(): void {
    if (this.circuitState === 'OPEN') {
      const elapsed = Date.now() - this.lastFailureTime;
      if (elapsed >= this.config.cooldownPeriodMs) {
        this.circuitState = 'HALF_OPEN';
      }
    }
  }

  private recordSuccess(latencyMs: number): void {
    this.metrics.totalRequests += 1;
    this.metrics.successfulRequests += 1;
    this.metrics.lastLatencyMs = latencyMs;
    this.consecutiveFailures = 0;
    this.circuitState = 'CLOSED';
    this.metrics.circuitState = 'CLOSED';
  }

  private recordFailure(isThrottled = false): void {
    this.metrics.totalRequests += 1;
    this.metrics.failedRequests += 1;
    if (isThrottled) {
      this.metrics.throttledRequests += 1;
    }
    this.consecutiveFailures += 1;
    this.lastFailureTime = Date.now();
    this.metrics.lastFailureTime = this.lastFailureTime;

    if (this.circuitState === 'HALF_OPEN' || this.consecutiveFailures >= this.config.failureThreshold) {
      this.circuitState = 'OPEN';
      this.metrics.circuitState = 'OPEN';
    }
  }

  public async synthesize(request: SynthesizerRequest, modelOverride?: string): Promise<ResearchAnswerPayload> {
    const startTime = Date.now();

    if (
      request.containsPersonalHealthData === true ||
      ServerHealthPrivacyGuard.containsPersonalHealthData(request.query)
    ) {
      throw new OpenRouterSensitiveDataError();
    }

    this.updateCircuitState();
    if (this.circuitState === 'OPEN') {
      throw new OpenRouterCircuitBreakerOpenError(
        `OpenRouter circuit breaker is OPEN (${this.consecutiveFailures} consecutive failures).`
      );
    }

    const modelToUse = modelOverride ?? this.defaultModel;

    const systemPrompt = `You are Nutrient Earth's health and science assistant.
Answer the user's exact question directly in simple, clear, natural English.
Put the direct answer in the very first sentence.
Never use robotic academic templates, filler introductions, or artificial section headers unless the user asks for a detailed breakdown.
Adapt length to the question: 1–3 sentences for simple questions, structured lists or tables only when comparing or explaining multi-step topics.

Respond ONLY with a valid JSON object matching this schema:
{
  "referenceId": "REF-OR-${Date.now()}",
  "domainCategory": "Health Intelligence",
  "quickAnswer": "<Clear direct 1-sentence answer>",
  "detailedExplanation": "<Clear natural-language explanation>",
  "answerSummary": "<Direct answer>",
  "evidenceBadge": "",
  "effectivenessAssessment": "neutral",
  "citations": [],
  "claims": [],
  "practicalSteps": [],
  "uncertaintyDisclaimer": ""
}`;

    const requestBody = {
      model: modelToUse,
      messages: [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: request.query },
      ],
      response_format: { type: 'json_object' },
      temperature: 0.3,
      max_tokens: 1500,
    };

    let attempts = 0;
    let lastError: Error | null = null;

    while (attempts <= this.config.maxRetries) {
      attempts++;
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), this.config.timeoutMs);

      try {
        const response = await fetch(this.baseUrl, {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${this.apiKey}`,
            'Content-Type': 'application/json',
            'HTTP-Referer': 'https://nutrientearth.win',
            'X-Title': 'Nutrient Earth Intelligence',
          },
          body: JSON.stringify(requestBody),
          signal: controller.signal,
        });

        clearTimeout(timeoutId);

        if (response.status === 429) {
          this.recordFailure(true);
          lastError = new Error('OpenRouter 429: Rate limited');
          await new Promise((r) => setTimeout(r, 1000 * attempts));
          continue;
        }

        if (!response.ok) {
          const errorText = await response.text();
          this.recordFailure();
          throw new Error(`OpenRouter HTTP ${response.status}: ${errorText}`);
        }

        const data = await response.json();
        const contentStr = data?.choices?.[0]?.message?.content;
        if (!contentStr) {
          this.recordFailure();
          throw new Error('OpenRouter returned an empty choices payload.');
        }

        const parsed = JSON.parse(contentStr);
        const latencyMs = Date.now() - startTime;
        this.recordSuccess(latencyMs);

        return {
          contractVersion: '2026.3',
          query: request.query,
          referenceId: parsed.referenceId || `REF-OR-${Date.now()}`,
          domainCategory: parsed.domainCategory || 'Health Intelligence',
          quickAnswer: parsed.quickAnswer || parsed.answerSummary,
          detailedExplanation: parsed.detailedExplanation || parsed.quickAnswer || '',
          answerSummary: parsed.answerSummary || parsed.quickAnswer || '',
          evidenceBadge: parsed.evidenceBadge || '',
          effectivenessAssessment: parsed.effectivenessAssessment || 'neutral',
          citations: parsed.citations || [],
          claims: parsed.claims || [],
          practicalSteps: parsed.practicalSteps || [],
          uncertaintyDisclaimer: parsed.uncertaintyDisclaimer || '',
          provider: 'OpenRouter Llama-3.3-70B',
          modelUsed: modelToUse,
          latencyMs,
          generatedAt: new Date().toISOString(),
        };
      } catch (e: any) {
        clearTimeout(timeoutId);
        lastError = e;
        if (e.name === 'AbortError') {
          this.recordFailure();
          lastError = new Error(`OpenRouter timeout exceeded (${this.config.timeoutMs}ms)`);
        }
      }
    }

    throw lastError ?? new Error('OpenRouter inference failed after retries.');
  }
}
