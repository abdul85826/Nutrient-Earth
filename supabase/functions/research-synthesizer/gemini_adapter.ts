/// <reference path="../deno.d.ts" />
// ==============================================================================
// Nutrient Earth — Real Gemini Server-Side Multimodal Provider Adapter
// Supports live text research synthesis, food plate image scanning, and nutritional extraction.
// DIRECTIVE: Explicit uncertainty scoring, strict image validation, zero fabricated nutrition.
// ==============================================================================

import {
  CircuitBreakerConfig,
  CircuitState,
  FoodAnalysisPayload,
  MultimodalImagePayload,
  ResearchAnswerPayload,
  ResearchCitationPayload,
  SynthesizerRequest,
  AdapterOperationalMetrics,
} from './types.ts';
import { ServerHealthPrivacyGuard } from './health_privacy_guard.ts';

export class GeminiCircuitBreakerOpenError extends Error {
  constructor(message = 'Gemini circuit breaker is OPEN due to repeated failures.') {
    super(message);
    this.name = 'GeminiCircuitBreakerOpenError';
  }
}

export class GeminiValidationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'GeminiValidationError';
  }
}

export class GeminiSensitiveDataError extends Error {
  constructor(message = 'Personal health data cannot be routed to Gemini without approved safeguards.') {
    super(message);
    this.name = 'GeminiSensitiveDataError';
  }
}

export class GeminiProviderAdapter {
  private readonly apiKey: string;
  private readonly baseUrl: string;
  private readonly defaultModel: string;
  private readonly config: CircuitBreakerConfig;

  // Image validation constraints
  private static readonly MAX_IMAGE_SIZE_BYTES = 10 * 1024 * 1024; // 10MB
  private static readonly ALLOWED_MIME_TYPES = new Set(['image/jpeg', 'image/png', 'image/webp']);

  // Circuit breaker state
  private circuitState: CircuitState = 'CLOSED';
  private consecutiveFailures = 0;
  private lastFailureTime = 0;

  // Metrics
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
    this.apiKey = envOverrides?.apiKey ?? Deno.env.get('GEMINI_API_KEY') ?? '';
    this.baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';
    this.defaultModel = envOverrides?.defaultModel ?? Deno.env.get('GEMINI_MODEL_ID') ?? 'gemini-2.0-flash';

    this.config = {
      failureThreshold: customConfig?.failureThreshold ?? 3,
      cooldownPeriodMs: customConfig?.cooldownPeriodMs ?? 60000,
      timeoutMs: customConfig?.timeoutMs ?? 12000, // 12s for multimodal
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
    if (isThrottled) this.metrics.throttledRequests += 1;
    this.consecutiveFailures += 1;
    this.lastFailureTime = Date.now();
    this.metrics.lastFailureTime = this.lastFailureTime;

    if (this.circuitState === 'HALF_OPEN' || this.consecutiveFailures >= this.config.failureThreshold) {
      this.circuitState = 'OPEN';
      this.metrics.circuitState = 'OPEN';
    }
  }

  /**
   * Validates image MIME type, payload structure, and estimated size.
   */
  public static validateImagePayload(image: MultimodalImagePayload): void {
    if (!image.base64Data || image.base64Data.trim().length === 0) {
      throw new GeminiValidationError('Image base64 data cannot be empty.');
    }

    if (!GeminiProviderAdapter.ALLOWED_MIME_TYPES.has(image.mimeType)) {
      throw new GeminiValidationError(
        `Unsupported image MIME type: ${image.mimeType}. Allowed: JPEG, PNG, WEBP.`
      );
    }

    // Estimate decoded bytes: 4 base64 chars = 3 bytes
    const estimatedBytes = Math.ceil((image.base64Data.length * 3) / 4);
    if (estimatedBytes > GeminiProviderAdapter.MAX_IMAGE_SIZE_BYTES) {
      throw new GeminiValidationError(
        `Image size (${(estimatedBytes / (1024 * 1024)).toFixed(1)}MB) exceeds maximum allowed 10MB limit.`
      );
    }
  }

  /**
   * Synthesizes text or analyzes a meal plate image using Gemini API.
   */
  public async synthesize(request: SynthesizerRequest, modelOverride?: string): Promise<ResearchAnswerPayload> {
    const startTime = Date.now();

    // 1. Privacy Guardrail Check
    if (
      request.containsPersonalHealthData === true ||
      ServerHealthPrivacyGuard.containsPersonalHealthData(request.query)
    ) {
      throw new GeminiSensitiveDataError();
    }

    // 2. Circuit Breaker Check
    this.updateCircuitState();
    if (this.circuitState === 'OPEN') {
      throw new GeminiCircuitBreakerOpenError(
        `Gemini circuit breaker is OPEN due to repeated upstream failures.`
      );
    }

    // 3. Image Validation if Image is Present
    if (request.image) {
      GeminiProviderAdapter.validateImagePayload(request.image);
    }

    const modelToUse = modelOverride ?? this.defaultModel;
    const url = `${this.baseUrl}/${modelToUse}:generateContent?key=${this.apiKey}`;

    const parts: Array<Record<string, unknown>> = [];

    if (request.image) {
      // Clean base64 string
      const cleanBase64 = request.image.base64Data.replace(/^data:image\/[a-z]+;base64,/, '');
      parts.push({
        inlineData: {
          mimeType: request.image.mimeType,
          data: cleanBase64,
        },
      });

      const foodPrompt = `Analyze this food image scientifically for the Nutrient Earth clinical platform.
Identify visible ingredients, estimate total meal weight (grams), macronutrient breakdown, and key micronutrients.
CRITICAL NUTRITIONAL HONESTY & ACCURACY:
- If portion sizes, hidden fats, or ingredients are ambiguous, explicitly state uncertainties in "uncertaintyNotes" and mark portionConfidence as "low" or "medium".
- NEVER invent or fabricate precise nutrient counts for foods that cannot be identified with reasonable certainty.

Respond ONLY with a valid JSON object matching this schema:
{
  "referenceId": "REF-MEAL-SCAN",
  "domainCategory": "Multimodal Food Recognition & Nutrient Analysis",
  "quickAnswer": "<1 sentence identification of meal components>",
  "detailedExplanation": "<Detailed breakdown of ingredients, culinary preparation, and metabolic impacts>",
  "answerSummary": "<Full nutritional overview>",
  "evidenceBadge": "COMPUTER VISION • DIETARY ASSESSMENT",
  "foodAnalysis": {
    "identifiedFood": "<Primary dish name>",
    "confidenceScore": 0.85,
    "estimatedPortionGrams": 350,
    "portionConfidence": "medium",
    "calories": 480,
    "proteinGrams": 32,
    "carbohydrateGrams": 45,
    "fatGrams": 18,
    "fiberGrams": 6,
    "micronutrients": [
      { "name": "Potassium", "amount": 620, "unit": "mg" },
      { "name": "Magnesium", "amount": 55, "unit": "mg" }
    ],
    "uncertaintyNotes": "<Disclose visual limitations, e.g. unmeasured cooking oils or portion depth>",
    "healthObservations": ["<E.g., high protein density supports muscle recovery>"]
  },
  "citations": [
    {
      "title": "Dietary Assessment with Image-Assisted Dietary Records",
      "authorsOrJournal": "Nutrients",
      "year": "2022",
      "evidenceGrade": "Validation Study",
      "verificationStatus": "peerReviewedArchive"
    }
  ],
  "practicalSteps": ["<Meal optimization suggestion>"],
  "uncertaintyDisclaimer": "Visual nutritional estimations are approximate and intended for educational reference, not clinical dosing."
}`;
      parts.push({ text: foodPrompt });
    } else {
      const lower = request.query.toLowerCase().trim();
      const isGreeting = /^(hi+|hey+|hello+|howdy|hola|greetings|good\s+(morning|afternoon|evening)|hi\s+there|hey\s+there|sup|yo)[!.,\s]*$/i.test(lower);
      const isCasual = ['how are you', 'how are you doing', 'who are you', 'what is nutrient earth', 'what can you do', 'thank you', 'thanks'].some(
        p => lower === p || lower.startsWith(`${p} `) || lower.endsWith(` ${p}`)
      );
      const isConversational = isGreeting || isCasual || request.taskType === ('conversational' as any);

      let textPrompt: string;
      if (isConversational) {
        textPrompt = `You are Nutrient Earth, an intelligent, helpful, and friendly health intelligence companion.
Respond ONLY with a valid JSON object matching this schema:
{
  "referenceId": "REF-GEMINI-CONV",
  "domainCategory": "Nutrient Earth Assistant",
  "quickAnswer": "<Warm, friendly, helpful direct answer>",
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
        textPrompt = `You are Nutrient Earth's health and science assistant.
Answer the user's exact question directly in simple, clear, natural English. Put the direct answer in the very first sentence.
Never use robotic academic templates, filler introductions, or artificial section headers unless the user asks for a detailed breakdown.
Adapt length to the question: 1–3 sentences for simple questions, structured lists or tables only when comparing or explaining multi-step topics.

Inquiry: "${request.query}"
Respond ONLY with a valid JSON object matching this schema:
{
  "referenceId": "REF-GEMINI-001",
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
      parts.push({ text: textPrompt });
    }

    const requestBody = {
      contents: [{ parts }],
      generationConfig: {
        temperature: 0.2,
        maxOutputTokens: 2048,
        responseMimeType: 'application/json',
      },
    };

    let attempts = 0;
    let lastError: Error | null = null;

    while (attempts <= this.config.maxRetries) {
      attempts++;
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), this.config.timeoutMs);

      try {
        const response = await fetch(url, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(requestBody),
          signal: controller.signal,
        });

        clearTimeout(timeoutId);

        if (response.status === 429) {
          this.recordFailure(true);
          if (attempts <= this.config.maxRetries) {
            await new Promise((r) => setTimeout(r, 2000 * attempts));
            continue;
          }
          throw new Error('Gemini API rate limit exceeded (HTTP 429).');
        }

        if (!response.ok) {
          const errBody = await response.text().catch(() => '');
          throw new Error(`Gemini HTTP ${response.status}: ${errBody.substring(0, 250)}`);
        }

        const data = await response.json();
        const candidateText = data.candidates?.[0]?.content?.parts?.[0]?.text;
        if (!candidateText || typeof candidateText !== 'string' || candidateText.trim().length === 0) {
          throw new Error('Gemini returned empty candidate content');
        }

        const parsed = JSON.parse(candidateText.trim());
        const latencyMs = Date.now() - startTime;
        this.recordSuccess(latencyMs);

        return this.mapToAnswerPayload(parsed, request.query, modelToUse, latencyMs);
      } catch (err: unknown) {
        clearTimeout(timeoutId);
        lastError = err instanceof Error ? err : new Error(String(err));
        if (attempts <= this.config.maxRetries) {
          await new Promise((r) => setTimeout(r, 600 * Math.pow(2, attempts - 1)));
        }
      }
    }

    this.recordFailure(false);
    throw lastError ?? new Error('Gemini invocation failed after retries');
  }

  private mapToAnswerPayload(
    parsed: Record<string, unknown>,
    query: string,
    model: string,
    latencyMs: number
  ): ResearchAnswerPayload {
    const foodAnalysis = parsed.foodAnalysis as FoodAnalysisPayload | undefined;
    const isConversational = String(parsed.domainCategory || '').toLowerCase().includes('assistant') ||
      /^(hi+|hey+|hello+|howdy|hola|good\s+(morning|afternoon|evening))/i.test(query.trim());

    const citations: ResearchCitationPayload[] = [];
    if (Array.isArray(parsed.citations)) {
      for (const item of parsed.citations) {
        if (!item || typeof item !== 'object') continue;
        const c = item as Record<string, unknown>;
        const pmidRaw = c.pmid ? String(c.pmid).trim() : undefined;
        const validPmid = pmidRaw && /^\d{4,10}$/.test(pmidRaw) ? pmidRaw : undefined;
        const doiRaw = c.doi ? String(c.doi).trim() : undefined;
        const validDoi = doiRaw && /^10\.\d{4,9}\//.test(doiRaw) ? doiRaw : undefined;

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

    return {
      contractVersion: '2026.3',
      query: query,
      referenceId: String(parsed.referenceId || `REF-GEMINI-${Date.now().toString(36).toUpperCase()}`),
      domainCategory: String(parsed.domainCategory || (isConversational ? 'Nutrient Earth Assistant' : 'Multimodal Nutritional Assessment')),
      quickAnswer: parsed.quickAnswer ? String(parsed.quickAnswer) : undefined,
      detailedExplanation: parsed.detailedExplanation ? String(parsed.detailedExplanation) : undefined,
      answerSummary: String(parsed.answerSummary || parsed.detailedExplanation || parsed.quickAnswer || ''),
      evidenceBadge: isConversational ? '' : String(parsed.evidenceBadge || (citations.length > 0 ? 'PEER REVIEWED EVIDENCE' : '')),
      effectivenessAssessment: String(parsed.effectivenessAssessment || (isConversational ? 'neutral' : 'stronglySupported')),
      citations: citations,
      claims: Array.isArray(parsed.claims) ? (parsed.claims as any) : [],
      foodAnalysis: foodAnalysis,
      practicalSteps: Array.isArray(parsed.practicalSteps)
        ? parsed.practicalSteps.map(String)
        : [],
      uncertaintyDisclaimer: isConversational
        ? ''
        : String(
          parsed.uncertaintyDisclaimer ||
          'Nutrient Earth provides nutritional research syntheses for educational guidance.'
        ),
      provider: 'Google Gemini Multimodal AI',
      modelUsed: model,
      latencyMs: latencyMs,
      generatedAt: new Date().toISOString(),
    };
  }
}

