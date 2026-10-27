// ==============================================================================
// Nutrient Earth — Server-Side Health Data Privacy Guard
// Classifies personal health disclosures, clinical biomarkers, and prescription
// medications on the server to prevent leakage to unauthenticated external endpoints.
// ==============================================================================

export class ServerHealthPrivacyGuard {
  // 1. Personal possessives combined with health or clinical markers
  private static readonly PERSONAL_HEALTH_SIGNALS: RegExp[] = [
    /\b(my|i have been diagnosed|i am diagnosed|diagnosed with|prescribed to me|prescribed for me|my doctor|my dosage|my dose|my symptoms|i suffer from|my lab|my blood|my glucose|my insulin|my cholesterol|my hba1c|my panel|my test results)\b/i,
    /\b(i take|i am taking|i inject|i was prescribed)\s+[a-z0-9\-]+/i,
  ];

  // 2. Clinical and laboratory numerical measurement units (blood biomarkers, vitals)
  private static readonly BIOMARKER_MEASUREMENTS: RegExp[] = [
    /\b\d+(\.\d+)?\s*(mg\/dl|mmol\/l|ng\/ml|pg\/ml|ug\/dl|µg\/dl|uiu\/ml|miu\/l|meq\/l|g\/dl)\b/i,
    /\b\d{2,3}\/\d{2,3}\s*(mmhg)?\b/i, // Blood pressure format e.g. 120/80 mmHg
    /\bhba1c\s*(of|is|:)?\s*\d+(\.\d+)?%?\b/i,
  ];

  // 3. Clinical prescription medications (distinct from dietary vitamins / minerals)
  private static readonly PRESCRIPTION_MEDICATIONS: RegExp[] = [
    /\b(metformin|atorvastatin|lisinopril|levothyroxine|adderall|ozempic|wegovy|mounjaro|rybelsus|semaglutide|tirzepatide)\b/i,
    /\b(lipitor|synthroid|amlodipine|losartan|gabapentin|sertraline|zoloft|fluoxetine|prozac|metoprolol|omeprazole)\b/i,
    /\b(prednisone|hydrochlorothiazide|furosemide|warfarin|eliquis|xarelto|humira|insulin\s+glargine|lantus)\b/i,
  ];

  /**
   * Deterministically classifies whether an inquiry contains personal health data.
   * Never trusts client-supplied flags.
   *
   * Note on Detection Limits:
   * Pattern heuristics identify standard diagnostic, biometric, and pharmacological
   * disclosures. Unconventional or colloquial self-disclosures are managed conservatively
   * by combining personal pronoun context with clinical terms.
   */
  public static containsPersonalHealthData(query: string): boolean {
    if (!query || typeof query !== 'string') return false;
    const clean = query.trim();

    // Check biomarker measurements (always personal data when numeric values are present)
    for (const pattern of this.BIOMARKER_MEASUREMENTS) {
      if (pattern.test(clean)) return true;
    }

    // Check personal health disclosures
    for (const pattern of this.PERSONAL_HEALTH_SIGNALS) {
      if (pattern.test(clean)) return true;
    }

    // Check prescription medication mentions in personal context
    for (const medPattern of this.PRESCRIPTION_MEDICATIONS) {
      if (medPattern.test(clean)) {
        // Any query mentioning a prescription drug with a personal pronoun or action is personal data
        if (/\b(my|i|take|taking|dose|prescribed|started|stopped|side effects)\b/i.test(clean)) {
          return true;
        }
      }
    }

    return false;
  }
}
