// ==============================================================================
// Types for Nutrient Earth Research Synthesizer & DeepSeek Adapter
// ==============================================================================

export type TaskType = 
  | 'general_scientific_inquiry'
  | 'personalized_clinical_guidance'
  | 'biometric_trend_analysis';

export interface AnonymizedUserProfileContext {
  age?: number;
  biological_sex?: string;
  primary_goals?: string[];
  activity_level?: string;
  dietary_preference?: string;
  known_conditions?: string[];
  active_supplements?: string[];
}

export interface SynthesizerRequest {
  query: string;
  taskType?: TaskType;
  containsPersonalHealthData?: boolean;
  preferredDomain?: string;
  referenceId?: string;
  userContext?: AnonymizedUserProfileContext;
}

export interface ResearchCitationPayload {
  title: string;
  authorsOrJournal: string;
  year: string;
  evidenceGrade: string;
  studyDesign?: string;
  url?: string;
  pmid?: string;
  doi?: string;
  supportingClaim?: string;
  verificationStatus?: string;
  sampleSize?: number;
}

export interface ScientificClaimPayload {
  claimText: string;
  supportStatus: 'supported' | 'contradicted' | 'unresolved' | 'insufficientEvidence';
  physiologicalMechanism: string;
  clinicalTakeaway?: string;
}

export interface GoalAssessmentResultPayload {
  status: 'aligned' | 'partiallyAligned' | 'misaligned' | 'insufficientInformation';
  matchedGoals: string[];
  alignmentRationale: string;
  contraindicationsOrWarnings: string[];
  missingContextNotes?: string;
}

export interface SafetyInformationPayload {
  tolerableUpperIntakeLevel?: string;
  drugInteractions: string[];
  populationContraindications: string[];
  generalMedicalDisclaimer: string;
}

export interface ResearchAnswerPayload {
  contractVersion?: string;
  query: string;
  referenceId: string;
  domainCategory: string;
  quickAnswer?: string;
  detailedExplanation?: string;
  answerSummary: string;
  evidenceBadge: string;
  effectivenessAssessment?: string;
  comparisonCallout?: string;
  comparisonIndex?: number;
  evidenceGap?: string;
  studyLimitations?: string;
  citations: ResearchCitationPayload[];
  claims?: ScientificClaimPayload[];
  goalAlignment?: GoalAssessmentResultPayload;
  safetyInformation?: SafetyInformationPayload;
  practicalSteps: string[];
  uncertaintyDisclaimer: string;
  provider: string;
  generatedAt: string;
}

export interface DeepSeekChatMessage {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

export interface DeepSeekChatCompletionRequest {
  model: string;
  messages: DeepSeekChatMessage[];
  temperature?: number;
  max_tokens?: number;
  response_format?: { type: 'json_object' };
}

export interface DeepSeekChatCompletionResponse {
  id?: string;
  object?: string;
  created?: number;
  model?: string;
  choices?: Array<{
    index: number;
    message: {
      role: string;
      content: string;
    };
    finish_reason: string;
  }>;
  usage?: {
    prompt_tokens: number;
    completion_tokens: number;
    total_tokens: number;
  };
  error?: {
    message?: string;
    type?: string;
    code?: string;
  };
}

export type CircuitState = 'CLOSED' | 'OPEN' | 'HALF_OPEN';

export interface CircuitBreakerConfig {
  failureThreshold: number; // consecutive failures before OPEN
  cooldownPeriodMs: number; // time to stay OPEN before HALF_OPEN
  timeoutMs: number;        // request timeout in ms
  maxRetries: number;       // retries for transient failures (429/503)
}

export interface AdapterOperationalMetrics {
  totalRequests: number;
  successfulRequests: number;
  failedRequests: number;
  throttledRequests: number;
  circuitState: CircuitState;
  lastFailureTime?: number;
  lastLatencyMs?: number;
}
