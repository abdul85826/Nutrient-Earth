// ==============================================================================
// Nutrient Earth — Evidence Integrity & Scientific Verification Tests
// Permanent Automated Evaluation Suite with Mandatory Adversarial Test Cases:
//
// 1. Animal study falsely claimed as human trial (Rule 2).
// 2. Observational association claimed as causation (Rule 3).
// 3. Retracted publication detection & emergency kill switch.
// 4. Corrected publication detection & erratum warning.
// 5. Malformed/Fake DOI & PMID rejection.
// 6. Abstract-only analysis flagged vs full-text analysis.
// 7. Cell culture result claimed as proven cancer cure (Rule 1 & Rule 6).
// 8. Chemical hazard detection claimed as clinical toxicity without dose (Rule 4).
// 9. DNA damage marker claimed as proven clinical disease (Rule 7).
// 10. Trivial statistical significance exaggerated as major benefit (Rule 5).
// 11. High-impact oncology claim held at NEEDS_HUMAN_REVIEW until human signoff.
// 12. 11-Part Editorial completeness verification.
// 13. 8-Step Knowledge Change Propagation & Recommendation Kill Switch.
// 14. Universal 25-Domain Taxonomy mapping across multiple research areas.
// 15. RoB 2, ROBINS-I, AMSTAR 2, and GRADE calculation verification.
// ==============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/core/domain/evidence/canonical_claim_models.dart';
import 'package:nutrient_earth_client/core/domain/taxonomy/universal_research_taxonomy_registry.dart';
import 'package:nutrient_earth_client/core/services/evidence/continuous_knowledge_update_engine.dart';
import 'package:nutrient_earth_client/core/services/evidence/human_evidence_separation_guard.dart';
import 'package:nutrient_earth_client/core/services/evidence/methodological_evidence_assessment_service.dart';
import 'package:nutrient_earth_client/core/services/evidence/research_integrity_verification_engine.dart';
import 'package:nutrient_earth_client/core/services/evidence/source_authentication_service.dart';
import 'package:nutrient_earth_client/core/services/publishing/publishing_gate_service.dart';
import 'package:nutrient_earth_client/core/services/publishing/scientific_editorial_service.dart';

void main() {
  group('Universal 25-Domain Research Taxonomy Tests (Section 11)', () {
    test('Registry contains all 25 distinct health research domains', () {
      expect(UniversalResearchTaxonomyRegistry.allDomains.length, 25);

      // Verify domain numbering 1 to 25
      for (int i = 1; i <= 25; i++) {
        final d = UniversalResearchTaxonomyRegistry.getDomainByNumber(i);
        expect(d, isNotNull);
        expect(d!.domainNumber, i);
      }
    });

    test('Maps diverse everyday health inquiries to correct specific domains', () {
      // Nutrition
      final d1 = UniversalResearchTaxonomyRegistry.matchQueryToDomain('protein muscle synthesis kinetics');
      expect(d1.domainNumber, 1);

      // Cookware
      final d4 = UniversalResearchTaxonomyRegistry.matchQueryToDomain('cast iron pan acidic tomato leaching');
      expect(d4.domainNumber, 4);

      // Plastics & cutting boards
      final d5 = UniversalResearchTaxonomyRegistry.matchQueryToDomain('cutting board microplastics shedding');
      expect(d5.domainNumber, 5);

      // Sleep
      final d10 = UniversalResearchTaxonomyRegistry.matchQueryToDomain('slow wave sleep and core body temperature');
      expect(d10.domainNumber, 10);

      // Cancer
      final d18 = UniversalResearchTaxonomyRegistry.matchQueryToDomain('acrylamide in food and cancer risk epidemiology');
      expect(d18.domainNumber, 18);

      // DNA
      final d19 = UniversalResearchTaxonomyRegistry.matchQueryToDomain('oxidative DNA damage and 8-OHdG repair');
      expect(d19.domainNumber, 19);

      // Footwear
      final d14 = UniversalResearchTaxonomyRegistry.matchQueryToDomain('minimalist footwear foot intrinsic muscle strength');
      expect(d14.domainNumber, 14);

      // Traditional AYUSH
      final d22 = UniversalResearchTaxonomyRegistry.matchQueryToDomain('ayurveda agni and ragi millet preparation');
      expect(d22.domainNumber, 22);
    });
  });

  group('Source Authentication & Retraction Screening (Section 3)', () {
    const authService = SourceAuthenticationService();

    test('Authenticates valid PubMed and DOI references', () {
      final report = authService.authenticate(
        title: 'Dose-dependent response of muscle protein synthesis',
        authorsOrJournal: 'Moore DR, et al. Am J Clin Nutr',
        year: '2009',
        pmid: '19056590',
        doi: '10.3945/ajcn.2008.26401',
      );

      expect(report.isAuthenticated, isTrue);
      expect(report.authenticatedRecord, isNotNull);
      expect(report.authenticatedRecord!.pmid, '19056590');
      expect(report.authenticatedRecord!.doi, '10.3945/ajcn.2008.26401');
      expect(report.failureReasons, isEmpty);
    });

    test('Rejects malformed DOI and non-numeric PMID', () {
      final report = authService.authenticate(
        title: 'Unverified Blog Post',
        authorsOrJournal: 'Internet Article',
        year: '2025',
        pmid: 'not_a_number_pmid',
        doi: 'invalid-doi-format',
      );

      expect(report.isAuthenticated, isFalse);
      expect(report.failureReasons, contains(predicate((String s) => s.contains('Malformed PubMed ID'))));
      expect(report.failureReasons, contains(predicate((String s) => s.contains('Malformed DOI'))));
    });

    test('Adversarial: Retracted publication is instantly detected and blocked', () {
      // Known retracted Lancet Surgisphere COVID-19 dataset
      final report = authService.authenticate(
        title: 'Hydroxychloroquine or chloroquine with or without a macrolide',
        authorsOrJournal: 'The Lancet',
        year: '2020',
        pmid: '32492290',
        doi: '10.1016/s0140-6736(20)31180-6',
      );

      expect(report.isAuthenticated, isFalse);
      expect(report.isRetractedBlocked, isTrue);
      expect(report.failureReasons.first, contains('RETRACTED PUBLICATION DETECTED'));
    });

    test('Detects corrected publications and preserves erratum warning', () {
      final report = authService.authenticate(
        title: 'Primary Prevention of Cardiovascular Disease with a Mediterranean Diet',
        authorsOrJournal: 'Estruch R, et al. N Engl J Med',
        year: '2018',
        doi: '10.1056/nejmoa1200303',
      );

      expect(report.isAuthenticated, isTrue);
      expect(report.authenticatedRecord!.isCorrected, isTrue);
      expect(report.warningFlags.first, contains('published erratum/correction'));
    });

    test('Distinguishes abstract-only analysis from full-text analysis', () {
      final report = authService.authenticate(
        title: 'Pilot study on rare botanical extract',
        authorsOrJournal: 'Phytother Res',
        year: '2024',
        doi: '10.1002/ptr.9999',
        fullTextAccessed: false, // Abstract only!
      );

      expect(report.isAuthenticated, isTrue);
      expect(report.authenticatedRecord!.hasFullTextAccessed, isFalse);
      expect(report.authenticatedRecord!.analysisScope, 'abstract_only');
      expect(report.warningFlags.first, contains('abstract only'));
    });
  });

  group('Methodological Quality Assessment Standards (Section 4)', () {
    const assessmentService = MethodologicalEvidenceAssessmentService();

    test('RoB 2 evaluates RCTs across 5 Cochrane domains', () {
      final appraisal = assessmentService.assessRctRoB2(
        publicationId: 'pub_rct_01',
        randomizationProcess: 'low',
        deviationsFromIntervention: 'low',
        missingOutcomeData: 'low',
        measurementOfOutcome: 'some_concerns',
        selectionOfReportedResult: 'low',
        justificationNotes: 'Outcome assessors were unblinded for subjective fatigue scale.',
      );

      expect(appraisal.toolUsed, MethodologicalTool.rob2);
      expect(appraisal.overallRisk, RiskOfBiasLevel.someConcerns);
      expect(appraisal.domainJudgements['D4_measurement_of_outcome'], 'some_concerns');
    });

    test('ROBINS-I evaluates confounding in observational studies', () {
      final appraisal = assessmentService.assessObservationalRobinsI(
        publicationId: 'pub_obs_01',
        confounding: 'serious',
        participantSelection: 'low',
        interventionClassification: 'low',
        deviationsFromIntervention: 'low',
        missingData: 'low',
        outcomeMeasurement: 'low',
        selectionOfReportedResult: 'low',
        justificationNotes: 'Residual confounding from socio-economic status was not adjusted.',
      );

      expect(appraisal.toolUsed, MethodologicalTool.robinsI);
      expect(appraisal.overallRisk, RiskOfBiasLevel.highRisk);
    });

    test('AMSTAR 2 critically rates systematic reviews', () {
      final appraisal = assessmentService.assessSystematicReviewAmstar2(
        publicationId: 'pub_meta_01',
        priorProtocolRegistered: true,
        comprehensiveLiteratureSearch: true,
        justificationOfExcludedStudies: true,
        riskOfBiasAssessedInIndividualStudies: true,
        appropriateMetaAnalyticMethods: true,
        riskOfBiasConsideredInInterpretation: true,
        publicationBiasAssessed: true,
        justificationNotes: 'Flawless Cochrane Systematic Review.',
      );

      expect(appraisal.toolUsed, MethodologicalTool.amstar2);
      expect(appraisal.overallRisk, RiskOfBiasLevel.lowRisk);
    });

    test('GRADE Certainty downgrades appropriately for risk of bias and imprecision', () {
      final grade = assessmentService.assessGradeCertainty(
        outcomeName: 'Muscle Protein Synthesis (MPS)',
        studyCount: 3,
        totalParticipants: 45,
        studyDesigns: [EvidenceTier.humanRandomizedTrial],
        riskOfBiasDowngrade: -1, // Downgrade 1 level for unblinded design
        imprecisionDowngrade: -1, // Downgrade 1 level for small sample size
        justificationSummary: 'Downgraded 2 levels for RoB and small sample size imprecision.',
      );

      // Started at High (4) -> -1 -1 = Moderate/Low (2) -> Low Certainty
      expect(grade.finalCertainty, GradeCertainty.low);
      expect(grade.studyCount, 3);
    });
  });

  group('Human Evidence & Mechanism Separation Safety Guard (Section 5)', () {
    const guard = HumanEvidenceSeparationGuard();

    const samplePop = TargetPopulation(
      description: 'Adults aged 20-35',
      sampleSize: 30,
    );

    const sampleExposure = ExposureSpecification(
      agentOrIntervention: 'Bioactive Polyphenol',
      doseAmount: '500 mg',
      duration: '8 weeks',
    );

    test('Rule 1: Rejects cellular in-vitro mechanism claimed as proven human disease cure', () {
      final res = guard.verifyClaimSafety(
        statement: 'This in-vitro compound completely cures human cancer and prevents tumors.',
        evidenceTier: EvidenceTier.inVitroCellularAssay,
        population: samplePop,
        exposure: sampleExposure,
      );

      expect(res.isSafe, isFalse);
      expect(res.violations.first.ruleIdentifier, 'RULE_1_CELLULAR_MECHANISM_EXTRAPOLATION');
      expect(res.violations.first.violationMessage, contains('In-vitro cellular'));
    });

    test('Rule 2: Rejects animal trial claimed as human clinical outcome', () {
      final res = guard.verifyClaimSafety(
        statement: 'Proven in humans: This peptide burns fat in human patients.',
        evidenceTier: EvidenceTier.preclinicalAnimalModel,
        population: samplePop,
        exposure: sampleExposure,
      );

      expect(res.isSafe, isFalse);
      expect(res.violations.first.ruleIdentifier, 'RULE_2_ANIMAL_EXTRAPOLATION');
      expect(res.violations.first.violationMessage, contains('Preclinical animal trials'));
    });

    test('Rule 3: Rejects observational cohort association claimed as direct causation', () {
      final res = guard.verifyClaimSafety(
        statement: 'This prospective cohort proves that eating butter causes heart attacks.',
        evidenceTier: EvidenceTier.humanObservationalCohort,
        population: samplePop,
        exposure: sampleExposure,
      );

      expect(res.isSafe, isFalse);
      expect(res.violations.first.ruleIdentifier, 'RULE_3_ASSOCIATION_AS_CAUSATION');
      expect(res.violations.first.correctiveAction, contains('Replace "causes" with "is associated with"'));
    });

    test('Rule 4: Rejects chemical hazard claimed as clinical harm without dose specification', () {
      const exposureWithoutDose = ExposureSpecification(
        agentOrIntervention: 'Chemical compound',
        // doseAmount is null!
      );

      final res = guard.verifyClaimSafety(
        statement: 'This food contains a deadly chemical and toxic poison.',
        evidenceTier: EvidenceTier.humanObservationalCohort,
        population: samplePop,
        exposure: exposureWithoutDose,
      );

      expect(res.isSafe, isFalse);
      expect(res.violations.first.ruleIdentifier, 'RULE_4_HAZARD_WITHOUT_DOSE');
    });

    test('Rule 5: Rejects trivial statistical difference exaggerated as major benefit', () {
      const negligibleEffect = EffectEstimate(
        measureType: 'Mean Difference (MD)',
        pointEstimate: 0.05,
        pValue: 0.04, // Statistically significant (p < 0.05)
        isStatisticallySignificant: true,
        isClinicallyMeaningful: false, // But clinically trivial!
        clinicalTakeaway: 'Clinically negligible effect size (Cohen d = 0.05)',
      );

      final res = guard.verifyClaimSafety(
        statement: 'Study proves a massive benefit and huge improvement in fat loss.',
        evidenceTier: EvidenceTier.humanRandomizedTrial,
        population: samplePop,
        exposure: sampleExposure,
        effectEstimate: negligibleEffect,
      );

      expect(res.isSafe, isFalse);
      expect(res.violations.first.ruleIdentifier, 'RULE_5_TRIVIAL_STATISTICAL_SIGNIFICANCE');
    });

    test('Rule 6: Cancer claims require explicit IARC hazard classification', () {
      final res = guard.verifyClaimSafety(
        statement: 'Substance is linked to cancer risk in everyday cooking.',
        evidenceTier: EvidenceTier.humanObservationalCohort,
        population: samplePop,
        exposure: sampleExposure,
        cancerDetails: null, // Missing hazard class!
      );

      expect(res.isSafe, isFalse);
      expect(res.violations.first.ruleIdentifier, 'RULE_6_CANCER_HAZARD_UNSPECIFIED');
    });

    test('Rule 7: DNA damage marker cannot be claimed as clinical disease without proof', () {
      final res = guard.verifyClaimSafety(
        statement: 'Cooking method damages dna and causes disease.',
        evidenceTier: EvidenceTier.inVitroCellularAssay,
        population: samplePop,
        exposure: sampleExposure,
        dnaDetails: {'clinical_disease_proven': false},
      );

      expect(res.isSafe, isFalse);
      expect(res.violations.first.ruleIdentifier, 'RULE_7_DNA_DAMAGE_VS_DISEASE_OUTCOME');
    });
  });

  group('Publishing Gate & Review Workflow (Section 8)', () {
    const gateService = PublishingGateService();

    test('Blocks claim from publishing if high-impact without human signoff', () {
      const samplePop = TargetPopulation(description: 'Cancer patients');
      const sampleExposure = ExposureSpecification(agentOrIntervention: 'Therapy');

      final highImpactClaim = CanonicalClaim(
        id: 'clm-cancer-01',
        claimUid: 'CLM-18-001',
        domainId: 'domain_18_cancer_research',
        exactStatement: 'Experimental therapy for cancer patients improves biomarkers.',
        evidenceTier: EvidenceTier.humanRandomizedTrial,
        isHumanEvidence: true,
        population: samplePop,
        exposure: sampleExposure,
        biologicalMechanism: 'Apoptosis induction',
        healthOutcome: 'Biomarker stabilization',
        studyLimitations: 'Phase II trial',
        requiresHumanSignoff: true,
        reviewedAt: DateTime.now(),
        cancerHazardAudit: {'hazard_class': 'Group 2B'},
      );

      final authSource = AuthenticatedSourceRecord(
        sourceIdentifier: '10.1000/cancer.2026',
        doi: '10.1000/cancer.2026',
        canonicalTitle: 'Phase II Cancer Trial',
        authors: ['Smith J', 'Doe A'],
        journal: 'J Clin Oncol',
        publicationYear: 2026,
        evidenceTier: EvidenceTier.humanRandomizedTrial,
        originalSourceUrl: 'https://doi.org/10.1000/cancer.2026',
        retrievalTimestamp: DateTime.now(),
      );

      // Without human approval:
      final outcomeBlocked = gateService.evaluateClaimForPublication(
        claim: highImpactClaim,
        source: authSource,
        humanReviewerApproved: false,
      );

      expect(outcomeBlocked.canPublish, isFalse);
      expect(outcomeBlocked.targetState, PublishingState.needsHumanReview);
      expect(outcomeBlocked.requiresHumanReview, isTrue);

      // With human approval:
      final outcomeApproved = gateService.evaluateClaimForPublication(
        claim: highImpactClaim,
        source: authSource,
        humanReviewerApproved: true,
        humanReviewerNotes: 'Reviewed by Board-Certified Medical Oncologist Dr. Patel, MD.',
      );

      expect(outcomeApproved.canPublish, isTrue);
      expect(outcomeApproved.targetState, PublishingState.published);
    });
  });

  group('Continuous Knowledge Updating & Emergency Kill Switch (Sections 9 & 10)', () {
    test('8-Step Change Propagation engages Kill Switch on retracted trial', () async {
      final updateEngine = ContinuousKnowledgeUpdateEngine();

      const samplePop = TargetPopulation(description: 'Adults');
      const sampleExposure = ExposureSpecification(agentOrIntervention: 'Supplement');

      final claim1 = CanonicalClaim(
        id: 'clm-001',
        claimUid: 'CLM-01-001',
        domainId: 'domain_01_nutrition',
        exactStatement: 'Supplement X accelerates recovery.',
        evidenceTier: EvidenceTier.humanRandomizedTrial,
        isHumanEvidence: true,
        population: samplePop,
        exposure: sampleExposure,
        biologicalMechanism: 'Glycogen resynthesis',
        healthOutcome: 'Recovery time',
        supportingPublicationDois: ['10.1016/retracted.trial.2026'],
        studyLimitations: 'Small sample',
        reviewedAt: DateTime.now(),
      );

      final dependencyMap = {
        'rec_take_supplement_x': ['clm-001'],
        'rec_general_hydration': ['clm-other'],
      };

      // Ensure recommendation is active before event
      expect(updateEngine.isRecommendationActive('rec_take_supplement_x'), isTrue);

      // Trigger retraction update
      final changeEvent = await updateEngine.propagateEvidenceUpdate(
        triggerType: 'retraction_detected',
        sourceDoiOrPmid: '10.1016/retracted.trial.2026',
        existingClaims: [claim1],
        recommendationDependencyMap: dependencyMap,
        sourceMetadataUpdateNotes: 'Journal issued retraction due to data integrity failures.',
      );

      expect(changeEvent.isMaterialChange, isTrue);
      expect(changeEvent.requiresUserNotification, isTrue);
      expect(changeEvent.affectedClaimIds, contains('clm-001'));
      expect(changeEvent.affectedRecommendationIds, contains('rec_take_supplement_x'));

      // Kill Switch must have deactivated the compromised recommendation and claim
      expect(updateEngine.isRecommendationActive('rec_take_supplement_x'), isFalse);
      expect(updateEngine.isClaimActive('clm-001'), isFalse);

      // Unrelated recommendations remain completely unaffected
      expect(updateEngine.isRecommendationActive('rec_general_hydration'), isTrue);
    });
  });

  group('Master Research Integrity Verification Engine End-to-End Orchestration', () {
    const engine = ResearchIntegrityVerificationEngine();

    test('Processes and publishes verified human clinical trial with 11-part editorial article', () {
      const pop = TargetPopulation(
        description: 'Resistance-trained men and women',
        sampleSize: 48,
      );
      const exp = ExposureSpecification(
        agentOrIntervention: 'Whey Protein Isolate',
        doseAmount: '25g',
        frequency: 'Daily post-workout',
        duration: '12 weeks',
      );

      final submission = engine.processAndVerifyResearch(
        title: 'Effects of post-workout whey protein on myofibrillar protein synthesis',
        authorsOrJournal: 'Phillips SM, et al. J Physiol',
        year: '2023',
        doi: '10.1113/jphysiol.2023.123456',
        evidenceTier: EvidenceTier.humanRandomizedTrial,
        rawStatement: 'Post-workout protein intake of 20-30g stimulates myofibrillar protein synthesis in resistance-trained adults.',
        population: pop,
        exposure: exp,
        biologicalMechanism: 'Leucine-mediated mTORC1 signaling and ribosomal translation initiation',
        healthOutcome: 'Myofibrillar Protein Synthesis Rate',
      );

      expect(submission.isApproved, isTrue);
      expect(submission.finalState, PublishingState.published);
      expect(submission.verifiedClaim, isNotNull);
      expect(submission.editorialArticle, isNotNull);

      // Verify the 11-Part Editorial Completeness
      final art = submission.editorialArticle!;
      expect(art.part01DirectAnswer, isNotEmpty);
      expect(art.part02WhatResearchFound, isNotEmpty);
      expect(art.part03WhoWasStudied, contains('Resistance-trained'));
      expect(art.part04ExposureOrIntervention, contains('Whey Protein Isolate'));
      expect(art.part05WhatResultMeans, isNotEmpty);
      expect(art.part06WhatResultDoesNotProve, isNotEmpty);
      expect(art.part07PracticalActions, isNotEmpty);
      expect(art.part08EvidenceCertainty, contains('GRADE'));
      expect(art.part09ImportantLimitations, isNotEmpty);
      expect(art.part10OriginalSources, isNotEmpty);
      expect(art.part10OriginalSources.first['doi'], '10.1113/jphysiol.2023.123456');
    });
  });
}
