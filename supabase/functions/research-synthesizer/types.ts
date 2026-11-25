// ==============================================================================
// Types for Nutrient Earth Multi-Provider AI Gateway & Synthesizer
// ==============================================================================

export type UserInputType =
  | 'text'
  | 'image'
  | 'videoUpload'
  | 'socialVideoUrl'
  | 'webUrl'
  | 'documentPdf'
  | 'productQuery'
  | 'barcode'
  | 'healthData';

export type TaskType =
  | 'general_scientific_inquiry'
  | 'personalized_clinical_guidance'
  | 'biometric_trend_analysis'
  | 'food_image_analysis'
  | 'document_processing'
  | 'video_understanding'
  | 'social_url_retrieval'
  | 'intent_classification';

export type AIProviderId = 'groq' | 'gemini' | 'openrouter' | 'deepseek' | 'deterministic';

export interface AnonymizedUserProfileContext {
  age?: number;
  biological_sex?: string;
  primary_goals?: string[];
  activity_level?: string;
  dietary_preference?: string;
  known_conditions?: string[];
  active_supplements?: string[];
}

export interface MultimodalImagePayload {
  base64Data: string;
  mimeType: 'image/jpeg' | 'image/png' | 'image/webp';
  sizeBytes?: number;
}

export interface SynthesizerRequest {
  query: string;
  taskType?: TaskType;
  containsPersonalHealthData?: boolean;
  preferredDomain?: string;
  preferredProvider?: AIProviderId;
  preferredModel?: string;
  referenceId?: string;
  userContext?: AnonymizedUserProfileContext;
  image?: MultimodalImagePayload;
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
  status: 'aligned' | 'partiallyAligned' | 'misaligned' | 'insufficientInformation' | 'neutral';
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

export interface FoodNutrientItem {
  name: string;
  amount: number;
  unit: string;
}

export interface FoodAnalysisPayload {
  identifiedFood: string;
  confidenceScore: number; // 0.0 to 1.0
  estimatedPortionGrams?: number;
  portionConfidence: 'high' | 'medium' | 'low';
  calories: number;
  proteinGrams: number;
  carbohydrateGrams: number;
  fatGrams: number;
  fiberGrams: number;
  micronutrients: FoodNutrientItem[];
  uncertaintyNotes: string;
  healthObservations: string[];
}

export interface GoalMatchIndicatorPayload {
  matchPercentage?: number;
  status: 'aligned' | 'partiallyAligned' | 'misaligned' | 'insufficientInformation' | 'neutral';
  matchLabel: string;
  rationale: string;
  positiveFactors: string[];
  riskFactors: string[];
  missingContextNotes?: string;
}

export interface EvidenceProvenancePayload {
  hasVerifiedSources: boolean;
  classification: 'wellSupported' | 'limitedEvidence' | 'mixedEvidence' | 'notVerified';
  watermarkLabel: string;
  citations: ResearchCitationPayload[];
  claims: ScientificClaimPayload[];
  limitationsNotes?: string;
}

export interface UniversalIntelligenceAnswerPayload {
  contractVersion: '2026.2' | '2026.3';
  referenceId: string;
  detectedInputType: UserInputType;
  query: string;
  heroAnswer: string;
  recommendation: string;
  detailedExplanation: string;
  goalMatch: GoalMatchIndicatorPayload;
  evidence: EvidenceProvenancePayload;
  practicalSteps: string[];
  foodAnalysis?: FoodAnalysisPayload;
  uncertaintyDisclaimer: string;
  depthStrategy?: string;
  responseType?: string;
  blocks?: any[];
  providerUsed: string;
  generatedAt: string;
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
  foodAnalysis?: FoodAnalysisPayload;
  practicalSteps: string[];
  uncertaintyDisclaimer: string;
  depthStrategy?: string;
  responseType?: string;
  blocks?: any[];
  provider: string;
  modelUsed?: string;
  latencyMs?: number;
  generatedAt: string;
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

export type ClinicalReliabilityTier =
  | 'deterministic_gold'
  | 'high_clinical_rigor'
  | 'standard_synthesis'
  | 'unverified_draft';

export interface ModelCapabilityDescriptor {
  id: string;
  providerId: AIProviderId;
  displayName: string;
  version: string;
  clinicalReliabilityTier: ClinicalReliabilityTier;
  supportsMultimodal: boolean;
  supportsStructuredOutput: boolean;
  maxContextTokens: number;
  taskSuitability: TaskType[];
  isAvailable: boolean;
}

export interface DeepSeekChatCompletionRequest {
  model: string;
  messages: Array<{ role: string; content: string }>;
  temperature?: number;
  max_tokens?: number;
  response_format?: { type: string };
}

export interface DeepSeekChatCompletionResponse {
  id?: string;
  choices: Array<{
    message?: {
      content?: string;
      role?: string;
    };
    finish_reason?: string;
  }>;
  usage?: {
    prompt_tokens?: number;
    completion_tokens?: number;
    total_tokens?: number;
  };
}

