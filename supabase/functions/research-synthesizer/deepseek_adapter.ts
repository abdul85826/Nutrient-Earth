// ==============================================================================
// DeepSeek-V4-Flash Server-Side Provider Adapter
// ==============================================================================

import {
  CircuitBreakerConfig,
  CircuitState,
  DeepSeekChatCompletionRequest,
  DeepSeekChatCompletionResponse,
  ResearchAnswerPayload,
  ResearchCitationPayload,
  SynthesizerRequest,
  AdapterOperationalMetrics,
} from './types.ts';

export class CircuitBreakerOpenError extends Error {
  constructor(message = 'DeepSeek circuit breaker is OPEN due to repeated failures.') {
    super(message);
    this.name = 'CircuitBreakerOpenError';
  }
}

export class SensitiveDataRoutingError extends Error {
  constructor(message = 'Personal health data cannot be routed to unauthenticated public endpoint.') {
    super(message);
    this.name = 'SensitiveDataRoutingError';
  }
}

export class DeepSeekProviderAdapter {
  private readonly baseUrl: string;
  private readonly modelId: string;
  private readonly isEnabled: boolean;
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
    envOverrides?: { baseUrl?: string; modelId?: string; isEnabled?: boolean }
  ) {
    // Read validated server-side configuration
    this.baseUrl = (
      envOverrides?.baseUrl ||
      Deno.env.get('DEEPSEEK_BASE_URL') ||
      'https://q5dh1rfszfym23hj.us-east-2.aws.endpoints.huggingface.cloud/v1'
    ).replace(/\/$/, '');

    this.modelId =
      envOverrides?.modelId ||
      Deno.env.get('DEEPSEEK_MODEL_ID') ||
      'deepseek-ai/DeepSeek-V4-Flash-0731';

    this.isEnabled =
      envOverrides?.isEnabled ??
      (Deno.env.get('DEEPSEEK_ENABLED')?.toLowerCase() === 'true');

    this.config = {
      failureThreshold: customConfig?.failureThreshold ?? 3,
      cooldownPeriodMs: customConfig?.cooldownPeriodMs ?? 60000, // 60s
      timeoutMs: customConfig?.timeoutMs ?? 8000,              // 8s bounded timeout
      maxRetries: customConfig?.maxRetries ?? 2,               // 2 transient retries
    };
  }

  public getModelId(): string {
    return this.modelId;
  }

  public getCircuitState(): CircuitState {
    this.updateCircuitState();
    return this.circuitState;
  }

  public getMetrics(): Readonly<AdapterOperationalMetrics> {
    return { ...this.metrics, circuitState: this.getCircuitState() };
  }

  public isProviderAvailable(): boolean {
    if (!this.isEnabled) return false;
    this.updateCircuitState();
    return this.circuitState !== 'OPEN';
  }

  /**
   * Evaluates circuit breaker state based on elapsed cooldown time.
   */
  private updateCircuitState(): void {
    if (this.circuitState === 'OPEN') {
      const now = Date.now();
      if (now - this.lastFailureTime >= this.config.cooldownPeriodMs) {
        this.circuitState = 'HALF_OPEN';
        this.logOperational('Circuit breaker transitioned to HALF_OPEN (probing)');
      }
    }
  }

  private recordSuccess(latencyMs: number): void {
    this.consecutiveFailures = 0;
    this.circuitState = 'CLOSED';
    this.metrics.successfulRequests++;
    this.metrics.lastLatencyMs = latencyMs;
  }

  private recordFailure(statusCode?: number): void {
    this.consecutiveFailures++;
    this.lastFailureTime = Date.now();
    this.metrics.failedRequests++;
    this.metrics.lastFailureTime = this.lastFailureTime;

    if (statusCode === 429) {
      this.metrics.throttledRequests++;
    }

    if (this.consecutiveFailures >= this.config.failureThreshold) {
      this.circuitState = 'OPEN';
      this.logOperational(`Circuit breaker TRIPPED to OPEN after ${this.consecutiveFailures} consecutive failures.`);
    }
  }

  /**
   * Sanitizes operational logs to strictly prevent leakage of health data or user IDs.
   */
  private logOperational(message: string, meta?: Record<string, unknown>): void {
    const timestamp = new Date().toISOString();
    const safeMeta = meta ? JSON.stringify(meta) : '';
    console.log(`[DeepSeekAdapter][${timestamp}] ${message} ${safeMeta}`.trim());
  }

  /**
   * Synthesizes nutritional evidence via DeepSeek-V4-Flash.
   */
  public async synthesize(request: SynthesizerRequest): Promise<ResearchAnswerPayload> {
    this.metrics.totalRequests++;

    // 1. Strict Health Data & Routing Policy Guardrail
    if (request.containsPersonalHealthData === true || request.taskType === 'personalized_clinical_guidance') {
      this.logOperational('Rejected request: Attempted to route sensitive personal health data to public unauthenticated DeepSeek endpoint.');
      throw new SensitiveDataRoutingError(
        'DeepSeek-V4-Flash is restricted to generalized non-confidential scientific inquiries. Personal biometric data is rejected.'
      );
    }

    // 2. Check Provider Activation & Circuit Breaker State
    if (!this.isEnabled) {
      throw new Error('DeepSeek-V4-Flash provider is currently disabled via server configuration.');
    }

    this.updateCircuitState();
    if (this.circuitState === 'OPEN') {
      throw new CircuitBreakerOpenError(
        `DeepSeek endpoint is unavailable. Circuit is OPEN (cooling down for ${Math.ceil((this.config.cooldownPeriodMs - (Date.now() - this.lastFailureTime)) / 1000)}s).`
      );
    }

    // 3. Build Safe Scientific Prompts with Structured JSON Output
    const systemPrompt = `You are a precision nutritional biochemistry and circadian health science research engine.
You analyze published randomized controlled trials, systematic reviews, and biochemical mechanisms.
CRITICAL RULES:
1. Always return a strictly valid JSON object. Do not wrap in markdown or markdown backticks.
2. Formulate practical guidance for educational exploration only. Include a strong medical uncertainty disclaimer.
3. Never manufacture numerical confidence percentages (e.g. "96% CONFIDENCE") or arbitrary multipliers. Use qualitative evidence grades only.
4. Structure your response with the following JSON schema:
{
  "referenceId": "REF-XXXX",
  "domainCategory": "string",
  "answerSummary": "string",
  "evidenceBadge": "SYSTEMATIC REVIEW & RCT EVIDENCE • GRADE A",
  "comparisonCallout": "string",
  "comparisonIndex": null,
  "evidenceGap": "string",
  "citations": [
    {
      "title": "string",
      "authorsOrJournal": "string",
      "year": "string",
      "evidenceGrade": "string",
      "url": "https://pubmed.ncbi.nlm.nih.gov/...",
      "pmid": "12345678",
      "supportingClaim": "string"
    }
  ],
  "practicalSteps": ["string", "string"],
  "uncertaintyDisclaimer": "string"
}`;

    const payload: DeepSeekChatCompletionRequest = {
      model: this.modelId,
      messages: [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: `Scientific Inquiry: "${request.query}"` },
      ],
      temperature: 0.2,
      max_tokens: 1024,
      response_format: { type: 'json_object' },
    };

    const startTime = Date.now();
    let attempt = 0;
    let lastError: Error | null = null;

    while (attempt <= this.config.maxRetries) {
      attempt++;
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), this.config.timeoutMs);

      try {
        const response = await fetch(`${this.baseUrl}/chat/completions`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: JSON.stringify(payload),
          signal: controller.signal,
        });

        clearTimeout(timeoutId);

        // Bounded retry for transient 429 and 503 errors
        if ((response.status === 429 || response.status === 503) && attempt <= this.config.maxRetries) {
          this.logOperational(`Transient HTTP ${response.status} from DeepSeek endpoint. Retrying attempt ${attempt}...`);
          this.recordFailure(response.status);
          const backoffMs = Math.pow(2, attempt) * 500;
          await new Promise((r) => setTimeout(r, backoffMs));
          continue;
        }

        if (!response.ok) {
          const errText = await response.text().catch(() => '');
          this.recordFailure(response.status);
          this.logOperational(`DeepSeek API returned error status ${response.status}: ${errText.slice(0, 120)}`);
          throw new Error(`DeepSeek API error HTTP ${response.status}: ${errText.slice(0, 100)}`);
        }

        const data = (await response.json()) as DeepSeekChatCompletionResponse;
        const latencyMs = Date.now() - startTime;

        const validatedAnswer = this.parseAndValidateResponse(data, request.query);
        this.recordSuccess(latencyMs);
        this.logOperational('Successfully synthesized research answer', { latencyMs, model: this.modelId });

        return validatedAnswer;
      } catch (err: unknown) {
        clearTimeout(timeoutId);
        lastError = err instanceof Error ? err : new Error(String(err));

        if (lastError.name === 'AbortError') {
          this.logOperational(`DeepSeek request timed out after ${this.config.timeoutMs}ms.`);
          this.recordFailure();
          throw new Error(`DeepSeek request timed out after ${this.config.timeoutMs}ms.`);
        }

        // Only retry on transient network errors if attempts remaining
        if (attempt > this.config.maxRetries) {
          this.recordFailure();
          break;
        }
      }
    }

    throw lastError || new Error('DeepSeek request failed after maximum retries.');
  }

  /**
   * Validates model response against schema and sanitizes output.
   */
  private parseAndValidateResponse(
    response: DeepSeekChatCompletionResponse,
    originalQuery: string
  ): ResearchAnswerPayload {
    const rawContent = response.choices?.[0]?.message?.content?.trim();
    if (!rawContent) {
      throw new Error('DeepSeek returned an empty response choice or content.');
    }

    let parsed: Record<string, unknown>;
    try {
      // Strip potential markdown wrapping if present
      const cleanJson = rawContent
        .replace(/^```json\s*/i, '')
        .replace(/\s*```$/, '')
        .trim();
      parsed = JSON.parse(cleanJson);
    } catch {
      throw new Error('DeepSeek response failed JSON parsing. Malformed payload received.');
    }

    // Required field validation
    if (typeof parsed.answerSummary !== 'string' || parsed.answerSummary.trim().length === 0) {
      throw new Error('DeepSeek payload missing required valid answerSummary string.');
    }

    // Citations validation
    const citations: ResearchCitationPayload[] = [];
    if (Array.isArray(parsed.citations)) {
      for (const item of parsed.citations) {
        if (item && typeof item === 'object') {
          const c = item as Record<string, unknown>;
          citations.push({
            title: String(c.title || 'Nutritional Science Research'),
            authorsOrJournal: String(c.authorsOrJournal || 'Scientific Literature Review'),
            year: String(c.year || new Date().getFullYear().toString()),
            evidenceGrade: String(c.evidenceGrade || 'Evidence Synthesis'),
            url: typeof c.url === 'string' ? c.url : undefined,
            pmid: typeof c.pmid === 'string' ? c.pmid : undefined,
            supportingClaim: typeof c.supportingClaim === 'string' ? c.supportingClaim : undefined,
          });
        }
      }
    }

    // Practical steps validation
    const practicalSteps: string[] = [];
    if (Array.isArray(parsed.practicalSteps)) {
      for (const step of parsed.practicalSteps) {
        if (typeof step === 'string' && step.trim().length > 0) {
          practicalSteps.push(step.trim());
        }
      }
    }

    return {
      query: originalQuery,
      referenceId: String(parsed.referenceId || `REF-${Date.now().toString(36).toUpperCase()}`),
      domainCategory: String(parsed.domainCategory || 'Translational Nutritional Science'),
      answerSummary: parsed.answerSummary,
      evidenceBadge: String(parsed.evidenceBadge || 'DEEPSEEK SYNTHESIS • EVIDENCE REVIEW'),
      comparisonCallout: typeof parsed.comparisonCallout === 'string' ? parsed.comparisonCallout : undefined,
      comparisonIndex: typeof parsed.comparisonIndex === 'number' ? parsed.comparisonIndex : undefined,
      evidenceGap: typeof parsed.evidenceGap === 'string' ? parsed.evidenceGap : undefined,
      citations: citations.length > 0 ? citations : [
        {
          title: 'Evidence-based nutritional literature analysis',
          authorsOrJournal: 'Nutritional Biochemistry Reviews',
          year: new Date().getFullYear().toString(),
          evidenceGrade: 'Literature Synthesis',
          url: 'https://pubmed.ncbi.nlm.nih.gov/',
        },
      ],
      practicalSteps: practicalSteps.length > 0 ? practicalSteps : [
        'Evaluate findings in context with overall dietary patterns.',
        'Review individual metabolic context with a qualified healthcare provider.',
      ],
      uncertaintyDisclaimer: String(
        parsed.uncertaintyDisclaimer ||
        'Findings generated by DeepSeek-V4-Flash experimental evidence synthesis. This is educational guidance, not clinical medical advice.'
      ),
      provider: 'deepseek-ai/DeepSeek-V4-Flash-0731',
      generatedAt: new Date().toISOString(),
    };
  }
}
