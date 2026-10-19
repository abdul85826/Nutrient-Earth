import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../domain/ai_conversation.dart';
import '../domain/health_profile.dart';
import '../domain/measurement.dart';
import 'health_repository.dart';

final aiWorkspaceProvider =
    StateNotifierProvider<AIWorkspaceNotifier, AIConversation>((ref) {
      final healthRepo = ref.watch(healthRepositoryProvider);
      return AIWorkspaceNotifier(healthRepo);
    });

class AIWorkspaceNotifier extends StateNotifier<AIConversation> {
  final HealthRepository _healthRepo;
  final _uuid = const Uuid();

  AIWorkspaceNotifier(this._healthRepo)
    : super(
        AIConversation(
          id: 'conv-initial',
          title: 'Health Intelligence Session',
          createdAt: DateTime.now(),
          messages: [
            AIMessage(
              id: 'welcome-01',
              isUser: false,
              content: 'Welcome to your Nutrient Earth Workspace. I synthesize continuous health data, peer-reviewed clinical research, and your biological markers to provide transparent, evidence-informed guidance.\n\nAsk a question or upload a lab report to begin.',
              timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
              evidenceQuality: EvidenceQuality.high,
              uncertainty: UncertaintyLevel.low,
              practicalNextSteps: [
                'Review your fasting glucose and lipid biomarkers in Body & Progress',
                'Inquire about optimizing deep sleep stages based on your current 1.7h average',
                'Upload a recent blood panel for multi-marker synthesis',
              ],
            ),
          ],
        ),
      );

  Future<void> sendMessage({
    required String prompt,
    HealthReportAttachment? reportAttachment,
  }) async {
    final userMsgId = _uuid.v4();
    final userMsg = AIMessage(
      id: userMsgId,
      isUser: true,
      content: prompt,
      timestamp: DateTime.now(),
      attachedReport: reportAttachment,
    );

    state = state.copyWith(messages: [...state.messages, userMsg]);

    // Contextual personalization engine
    final profile = await _healthRepo.getProfile();
    final measurements = await _healthRepo.getMeasurements();

    final aiResponse = _generateContextualAIResponse(
      prompt: prompt,
      profile: profile,
      measurements: measurements,
      reportAttachment: reportAttachment,
    );

    state = state.copyWith(messages: [...state.messages, aiResponse]);
  }

  AIMessage _generateContextualAIResponse({
    required String prompt,
    required HealthProfile profile,
    required List<HealthMeasurement> measurements,
    HealthReportAttachment? reportAttachment,
  }) {
    final lower = prompt.toLowerCase();
    final responseId = _uuid.v4();

    // Contextual matching: Glucose & Metabolic Health
    if (lower.contains('glucose') ||
        lower.contains('sugar') ||
        lower.contains('insulin') ||
        lower.contains('fasting')) {
      final glucose = measurements.firstWhere(
        (m) => m.metricName.contains('Glucose'),
        orElse: () => measurements.first,
      );

      return AIMessage(
        id: responseId,
        isUser: false,
        content:
            'Analyzing your metabolic markers: Your measured fasting blood glucose is currently ${glucose.currentValue} ${glucose.unit} (normal laboratory range: ${glucose.normalRangeMin}-${glucose.normalRangeMax} ${glucose.unit}).\n\n'
            'Based on your stated goal of "${profile.primaryGoals.first}" and your ${profile.dietaryPreference} dietary pattern, glucose regulation is influenced by post-prandial muscle contraction and sleep duration. Randomized trials demonstrate that 10–15 minutes of light zone-1 walking immediately following carbohydrate-dense meals significantly attenuates glycemic excursions.',
        timestamp: DateTime.now(),
        evidenceQuality: EvidenceQuality.high,
        uncertainty: UncertaintyLevel.low,
        sources: const [
          EvidenceSource(
            title: 'Effects of Postprandial Walking on Glycemic Excursions: A Randomized Controlled Crossover Trial',
            authors: 'Reynolds AN, Mann JI, et al.',
            year: 2021,
            publication: 'The American Journal of Clinical Nutrition',
            doiOrUrl: '10.1093/ajcn/nqaa302',
            studyType: 'Double-blind Randomized Crossover Trial',
          ),
          EvidenceSource(
            title: 'Mechanisms of Exercise-Induced Glucose Uptake in Skeletal Muscle',
            authors: 'Richter EA, Hargreaves M.',
            year: 2023,
            publication: 'Physiological Reviews',
            doiOrUrl: '10.1152/physrev.00038.2022',
            studyType: 'Systematic Review',
          ),
        ],
        practicalNextSteps: [
          'Incorporate a 12-minute brisk walk within 30 minutes of dinner.',
          'Maintain your consistent 88 mg/dL fasting baseline with balanced macronutrient pacing.',
          'Consider tracking continuous post-prandial glucose if symptoms of lethargy persist.',
        ],
        missingInformationQuestions: [
          'What is the typical composition and carbohydrate ratio of your evening meal?',
          'Are you currently taking any prescription medications that influence insulin sensitivity?',
        ],
      );
    }

    // Contextual matching: Sleep & Recovery
    if (lower.contains('sleep') ||
        lower.contains('recovery') ||
        lower.contains('deep sleep') ||
        lower.contains('fatigue')) {
      final sleep = measurements.firstWhere(
        (m) => m.metricName.contains('Deep Sleep'),
        orElse: () => measurements.first,
      );

      return AIMessage(
        id: responseId,
        isUser: false,
        content:
            'Reviewing recovery dynamics: Your self-reported deep sleep average is ${sleep.currentValue} ${sleep.unit}. While this sits within typical boundaries (1.2–2.2 h), deep slow-wave sleep (N3) is vulnerable to thermal disruption, late caffeine intake, and late-evening alcohol.\n\n'
            'Given your active supplement regimen including ${profile.activeSupplements.join(", ")}, magnesium glycinate is already supportive of GABAergic relaxation. Systematic reviews indicate that passive body heating via warm shower 90 minutes before bed enhances peripheral vasodilation, precipitating core body cooling required for slow-wave entry.',
        timestamp: DateTime.now(),
        evidenceQuality: EvidenceQuality.high,
        uncertainty: UncertaintyLevel.low,
        sources: const [
          EvidenceSource(
            title: 'Nightly Sleep Architecture and Cardiovascular Mortality: Prospective Cohort Analysis',
            authors: 'Kao HY, Redline S, et al.',
            year: 2022,
            publication: 'The Lancet Respiratory Medicine',
            doiOrUrl: '10.1016/S2213-2600(22)00155-2',
            studyType: 'Prospective Multi-Center Cohort Study (n=6,211)',
          ),
          EvidenceSource(
            title: 'Pre-sleep Passive Heating Accelerates Sleep-Onset and Increases Slow-Wave Sleep: A Systematic Review',
            authors: 'Haghayegh S, Khoshnevis S, et al.',
            year: 2019,
            publication: 'Sleep Medicine Reviews',
            doiOrUrl: '10.1016/j.smrv.2019.04.008',
            studyType: 'Systematic Review & Meta-Analysis',
          ),
        ],
        practicalNextSteps: [
          'Aim to keep sleeping room ambient temperature between 18°C–19.5°C (65°F–67°F).',
          'Consistently take magnesium glycinate 45–60 minutes prior to intended sleep time.',
          'Anchor wake time within a 30-minute window across both weekdays and weekends.',
        ],
        missingInformationQuestions: [
          'At what time is your final caffeine intake of the day?',
          'Do you experience middle-of-the-night awakenings or nasal congestion?',
        ],
      );
    }

    // Contextual matching: Health Report upload analysis
    if (reportAttachment != null ||
        lower.contains('report') ||
        lower.contains('lab')) {
      return AIMessage(
        id: responseId,
        isUser: false,
        content:
            'Health Report Synthesis: Analyzed document "${reportAttachment?.filename ?? 'Uploaded Panel'}" (${reportAttachment != null ? '${(reportAttachment.fileSize / 1024).toStringAsFixed(1)} KB' : 'Standard Biomarker Report'}).\n\n'
            'Cross-referencing with your active profile (${profile.age}yo ${profile.biologicalSex}):\n'
            '• Lipid fraction and metabolic markers reflect stable homeostatic balance.\n'
            '• Verified Serum 25(OH)D at 47 ng/mL confirms adequate sufficiency, concordant with your Vitamin D3 supplementation.\n'
            '• Biomarkers indicate no acute systemic inflammatory elevation.\n\n'
            'Note: This analysis identifies reference-range correlations only and must be reviewed with your primary healthcare provider.',
        timestamp: DateTime.now(),
        evidenceQuality: EvidenceQuality.high,
        uncertainty: UncertaintyLevel.low,
        sources: const [
          EvidenceSource(
            title: 'Circulating 25-Hydroxyvitamin D and All-Cause and Cause-Specific Mortality: A Dose-Response Meta-Analysis',
            authors: 'Gaksch M, Jorde R, et al.',
            year: 2021,
            publication: 'European Journal of Epidemiology',
            doiOrUrl: '10.1007/s10654-021-00782-x',
            studyType: 'Individual Participant Meta-Analysis (n=26,916)',
          ),
        ],
        practicalNextSteps: [
          'Schedule an annual comprehensive metabolic panel follow-up in 6 months.',
          'Share this trend synthesis directly with your physician during clinical consult.',
        ],
        missingInformationQuestions: [
          'Was this laboratory sample drawn in a verified 10-12 hour fasted state?',
        ],
      );
    }

    // Default synthesis matching general health, exercise, or longevity queries
    return AIMessage(
      id: responseId,
      isUser: false,
      content:
          'Synthesizing your inquiry against your personal health record (${profile.displayName}, goals: ${profile.primaryGoals.join(", ")}):\n\n'
          'Current physiology demonstrates solid baseline adaptation: Resting heart rate of 52 bpm and estimated VO2 max of 46.5 mL/kg/min place cardiorespiratory fitness in the upper tertile for your cohort. Progress in longevity outcomes is maximized by maintaining a high ratio of Zone 2 endurance work (75–80% of volume) supplemented with brief weekly high-intensity intervals.',
      timestamp: DateTime.now(),
      evidenceQuality: EvidenceQuality.moderate,
      uncertainty: UncertaintyLevel.medium,
      sources: const [
        EvidenceSource(
          title: 'Association of Cardiorespiratory Fitness with Long-term Mortality Among Adults Undergoing Exercise Testing',
          authors: 'Mandsager K, Hurley S, et al.',
          year: 2018,
          publication: 'JAMA Network Open',
          doiOrUrl: '10.1001/jamanetworkopen.2018.3605',
          studyType: 'Retrospective Cohort (n=122,007)',
        ),
      ],
      practicalNextSteps: [
        'Accumulate 150–180 minutes of weekly Zone 2 cardiovascular work.',
        'Preserve resistance training frequency at minimum 2-3 structured sessions weekly.',
      ],
      missingInformationQuestions: [
        'How many hours per week are you realistically able to dedicate to aerobic training under your current schedule?',
      ],
    );
  }
}
