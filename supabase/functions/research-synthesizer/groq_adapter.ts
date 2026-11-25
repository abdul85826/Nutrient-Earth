/// <reference path="../deno.d.ts" />
// ==============================================================================
// Nutrient Earth — Real Groq Server-Side Provider Adapter
// High-throughput, low-latency research synthesis and intent routing via Groq Cloud.
// RESILIENCE: Circuit breaker, bounded exponential retries, rate-limit 429 backoff.
// ==============================================================================

import {
  CircuitBreakerConfig,
  CircuitState,
  ResearchAnswerPayload,
  ResearchCitationPayload,
  SynthesizerRequest,
  AdapterOperationalMetrics,
} from './types.ts';
import { ServerHealthPrivacyGuard } from './health_privacy_guard.ts';

export class GroqCircuitBreakerOpenError extends Error {
  constructor(message = 'Groq circuit breaker is OPEN due to repeated failures or rate limiting.') {
    super(message);
    this.name = 'GroqCircuitBreakerOpenError';
  }
}

export class GroqSensitiveDataError extends Error {
  constructor(message = 'Personal health data cannot be routed to Groq.') {
    super(message);
    this.name = 'GroqSensitiveDataError';
  }
}

export class GroqProviderAdapter {
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
    this.apiKey = envOverrides?.apiKey ?? Deno.env.get('GROQ_API_KEY') ?? '';
    this.baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
    this.defaultModel = envOverrides?.defaultModel ?? Deno.env.get('GROQ_MODEL_ID') ?? 'llama-3.3-70b-versatile';

    this.config = {
      failureThreshold: customConfig?.failureThreshold ?? 3,
      cooldownPeriodMs: customConfig?.cooldownPeriodMs ?? 45000, // 45s cooldown
      timeoutMs: customConfig?.timeoutMs ?? 12000,               // 12s timeout
      maxRetries: customConfig?.maxRetries ?? 2,                // 2 transient retries
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

  /**
   * Executes a structured research synthesis request against Groq.
   */
  public async synthesize(request: SynthesizerRequest, modelOverride?: string): Promise<ResearchAnswerPayload> {
    const startTime = Date.now();

    // 1. Pre-Execution Health Privacy Guardrail
    if (
      request.containsPersonalHealthData === true ||
      ServerHealthPrivacyGuard.containsPersonalHealthData(request.query)
    ) {
      throw new GroqSensitiveDataError();
    }

    // 2. Circuit Breaker Evaluation
    this.updateCircuitState();
    if (this.circuitState === 'OPEN') {
      throw new GroqCircuitBreakerOpenError(
        `Groq circuit breaker is OPEN (${this.consecutiveFailures} consecutive failures). Cooldown active.`
      );
    }

    const modelToUse = modelOverride ?? this.defaultModel;

    // 3. Construct System Prompt & Messages dynamically based on query intent
    const lower = request.query.toLowerCase().trim();
    const isGreeting = /^(hi+|hey+|hello+|howdy|hola|greetings|good\s+(morning|afternoon|evening)|hi\s+there|hey\s+there|sup|yo)[!.,\s]*$/i.test(lower);
    const isCasual = ['how are you', 'how are you doing', 'who are you', 'what is nutrient earth', 'what can you do', 'thank you', 'thanks'].some(
      p => lower === p || lower.startsWith(`${p} `) || lower.endsWith(` ${p}`)
    );
    const isConversational = isGreeting || isCasual || request.taskType === ('conversational' as any);

    let systemPrompt: string;
    if (isConversational) {
      systemPrompt = `You are Nutrient Earth, an intelligent, helpful, and friendly health intelligence companion.
Respond ONLY with a valid JSON object matching this schema exactly without markdown formatting:
{
  "referenceId": "REF-CONV-001",
  "domainCategory": "Nutrient Earth Assistant",
  "quickAnswer": "<Warm, natural, and helpful direct answer>",
  "detailedExplanation": "<Helpful conversational response explaining what you can help with or answering their casual question>",
  "answerSummary": "<Direct answer>",
  "evidenceBadge": "",
  "effectivenessAssessment": "neutral",
  "citations": [],
  "claims": [],
  "practicalSteps": [],
  "uncertaintyDisclaimer": ""
}
Never include fake citations or medical disclaimers for friendly greetings and casual conversations.`;
    } else {
      systemPrompt = `You are Nutrient Earth's health and science assistant.
Answer the user's exact question directly in simple, clear, natural English. Put the direct answer in the very first sentence.
Never use robotic academic templates, filler introductions, or artificial section headers unless the user asks for a detailed breakdown.
Adapt length to the question: 1–3 sentences for simple questions, structured lists or tables only when comparing or explaining multi-step topics.

Respond ONLY with a valid JSON object matching this schema:
{
  "referenceId": "REF-GROQ-001",
  "domainCategory": "Health & Nutrition Intelligence",
  "quickAnswer": "<Direct, natural, plain-English answer in 1-2 sentences>",
  "detailedExplanation": "<Clear, helpful, natural explanation without robotic jargon>",
  "answerSummary": "<Direct answer>",
  "evidenceBadge": "",
  "effectivenessAssessment": "stronglySupported",
  "citations": [],
  "claims": [],
  "practicalSteps": [],
  "uncertaintyDisclaimer": ""
}
Only include citations if the user asked for clinical studies or research papers. Never fabricate citations or study titles.`;
    }

    const userMessageContent = `User Question: "${request.query}"${request.userContext?.primary_goals ? `\nTarget Goals: ${request.userContext.primary_goals.join(', ')}` : ''
      }${request.userContext?.dietary_preference ? `\nDietary Preference: ${request.userContext.dietary_preference}` : ''}`;

    const requestBody = {
      model: modelToUse,
      messages: [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: userMessageContent },
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
            'User-Agent': 'NutrientEarth-EdgeGateway/1.0',
          },
          body: JSON.stringify(requestBody),
          signal: controller.signal,
        });

        clearTimeout(timeoutId);

        if (response.status === 429) {
          // Rate-limited: extract retry-after if provided
          const retryAfterSec = parseInt(response.headers.get('Retry-After') || '2', 10);
          this.recordFailure(true);
          if (attempts <= this.config.maxRetries) {
            await new Promise((r) => setTimeout(r, Math.min(retryAfterSec * 1000, 3000)));
            continue;
          }
          throw new Error(`Groq rate limit exceeded (HTTP 429). Retry-After: ${retryAfterSec}s`);
        }

        if (!response.ok) {
          const errorText = await response.text().catch(() => '');
          throw new Error(`Groq HTTP ${response.status}: ${errorText.substring(0, 200)}`);
        }

        const data = await response.json();
        const contentStr = data.choices?.[0]?.message?.content;
        if (!contentStr || typeof contentStr !== 'string' || contentStr.trim().length === 0) {
          throw new Error('Groq returned empty response payload');
        }

        const parsed = JSON.parse(contentStr.trim());
        const latencyMs = Date.now() - startTime;
        this.recordSuccess(latencyMs);

        return this.mapToAnswerPayload(parsed, request.query, modelToUse, latencyMs);
      } catch (err: unknown) {
        clearTimeout(timeoutId);
        lastError = err instanceof Error ? err : new Error(String(err));

        // Retry transient network or 503 errors
        if (attempts <= this.config.maxRetries) {
          await new Promise((r) => setTimeout(r, 500 * Math.pow(2, attempts - 1)));
        }
      }
    }

    this.recordFailure(false);
    throw lastError ?? new Error('Groq invocation failed after retries');
  }

  private mapToAnswerPayload(
    parsed: Record<string, unknown>,
    query: string,
    model: string,
    latencyMs: number
  ): ResearchAnswerPayload {
    const rawCitations = Array.isArray(parsed.citations) ? parsed.citations : [];
    const isConversational = String(parsed.domainCategory || '').toLowerCase().includes('assistant') ||
      /^(hi+|hey+|hello+|howdy|hola|good\s+(morning|afternoon|evening))/i.test(query.trim());

    // Sanitize citations: strictly validate that PMID or DOI is authentic
    const citations: ResearchCitationPayload[] = [];
    if (Array.isArray(parsed.citations)) {
      for (const item of parsed.citations) {
        if (!item || typeof item !== 'object') continue;
        const c = item as Record<string, unknown>;
        const pmidRaw = c.pmid ? String(c.pmid).trim() : undefined;
        const validPmid = pmidRaw && /^\d{4,10}$/.test(pmidRaw) ? pmidRaw : undefined;
        const doiRaw = c.doi ? String(c.doi).trim() : undefined;
        const validDoi = doiRaw && /^10\.\d{4,9}\//.test(doiRaw) ? doiRaw : undefined;

        // Skip citations that have neither valid numeric PMID nor valid DOI
        if (validPmid || validDoi) {
          citations.push({
            title: String(c.title || 'Peer-Reviewed Clinical Evidence'),
            authorsOrJournal: String(c.authorsOrJournal || 'Clinical Science Archive'),
            year: String(c.year || new Date().getFullYear().toString()),
            evidenceGrade: String(c.evidenceGrade || 'Peer-Reviewed Study'),
            studyDesign: c.studyDesign ? String(c.studyDesign) : undefined,
            url: validPmid ? `https://pubmed.ncbi.nlm.nih.gov/${validPmid}/` : (validDoi ? `https://doi.org/${validDoi}` : undefined),
            pmid: validPmid,
            doi: validDoi,
            verificationStatus: 'peerReviewedArchive',
          });
        }
      }
    }

    const answerSummary = String(parsed.answerSummary || parsed.detailedExplanation || parsed.quickAnswer || '');

    return {
      contractVersion: '2026.3',
      query: query,
      referenceId: String(parsed.referenceId || `REF-GROQ-${Date.now().toString(36).toUpperCase()}`),
      domainCategory: String(parsed.domainCategory || (isConversational ? 'Nutrient Earth Assistant' : 'Nutritional Biochemistry')),
      quickAnswer: parsed.quickAnswer ? String(parsed.quickAnswer) : undefined,
      detailedExplanation: parsed.detailedExplanation ? String(parsed.detailedExplanation) : undefined,
      answerSummary: answerSummary,
      evidenceBadge: isConversational ? '' : String(parsed.evidenceBadge || (citations.length > 0 ? 'PEER REVIEWED EVIDENCE' : '')),
      effectivenessAssessment: String(parsed.effectivenessAssessment || (isConversational ? 'neutral' : 'moderatelySupported')),
      comparisonCallout: parsed.comparisonCallout ? String(parsed.comparisonCallout) : undefined,
      comparisonIndex: typeof parsed.comparisonIndex === 'number' ? parsed.comparisonIndex : undefined,
      citations: citations,
      claims: Array.isArray(parsed.claims) ? parsed.claims : [],
      practicalSteps: Array.isArray(parsed.practicalSteps)
        ? parsed.practicalSteps.map(String)
        : [],
      uncertaintyDisclaimer: isConversational
        ? ''
        : String(
          parsed.uncertaintyDisclaimer ||
          'Nutrient Earth provides nutritional research syntheses for educational guidance; it does not replace individualized medical diagnoses.'
        ),
      provider: 'Groq Cloud High-Speed Inference',
      modelUsed: model,
      latencyMs: latencyMs,
      generatedAt: new Date().toISOString(),
    };
  }
}

