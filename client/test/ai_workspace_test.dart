import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrient_earth_client/features/your_health/data/ai_workspace_service.dart';
import 'package:nutrient_earth_client/features/your_health/domain/ai_conversation.dart';

void main() {
  group('AI Workspace & Health Synthesis Tests', () {
    test('Initializes with evidence-informed welcome message and practical next steps', () {
      final container = ProviderContainer();
      final conversation = container.read(aiWorkspaceProvider);

      expect(conversation.messages.isNotEmpty, true);
      final welcome = conversation.messages.first;
      expect(welcome.isUser, false);
      expect(welcome.practicalNextSteps.isNotEmpty, true);
      expect(welcome.evidenceQuality, EvidenceQuality.high);
    });

    test('Glucose query returns peer-reviewed citations and missing information questions', () async {
      final container = ProviderContainer();
      final notifier = container.read(aiWorkspaceProvider.notifier);

      await notifier.sendMessage(prompt: 'How is my fasting glucose trending?');

      final conversation = container.read(aiWorkspaceProvider);
      expect(conversation.messages.length, 3); // Welcome + User + AI Response

      final aiResponse = conversation.messages.last;
      expect(aiResponse.isUser, false);
      expect(aiResponse.content.contains('fasting blood glucose'), true);
      expect(aiResponse.sources.isNotEmpty, true);
      expect(aiResponse.sources.first.publication.isNotEmpty, true);
      expect(aiResponse.evidenceQuality, EvidenceQuality.high);
      expect(aiResponse.practicalNextSteps.isNotEmpty, true);
      expect(aiResponse.missingInformationQuestions.isNotEmpty, true);
    });

    test(
      'Sleep query addresses sleep architecture with clinical sources',
      () async {
        final container = ProviderContainer();
        final notifier = container.read(aiWorkspaceProvider.notifier);

        await notifier.sendMessage(prompt: 'How can I improve my deep sleep?');

        final conversation = container.read(aiWorkspaceProvider);
        final aiResponse = conversation.messages.last;
        expect(aiResponse.isUser, false);
        expect(aiResponse.content.contains('deep sleep'), true);
        expect(
          aiResponse.sources.any((s) => s.publication.contains('Lancet')),
          true,
        );
      },
    );

    test(
      'Report attachment is synthesized with personal profile context',
      () async {
        final container = ProviderContainer();
        final notifier = container.read(aiWorkspaceProvider.notifier);

        final attachment = HealthReportAttachment(
          id: 'rep-01',
          filename: 'Comprehensive_Metabolic_Panel_Oct2026.pdf',
          fileType: 'pdf',
          fileSize: 1024 * 350, // 350 KB
          uploadedAt: DateTime.now(),
        );

        await notifier.sendMessage(
          prompt: 'Please synthesize my uploaded metabolic panel',
          reportAttachment: attachment,
        );

        final conversation = container.read(aiWorkspaceProvider);
        final aiResponse = conversation.messages.last;

        expect(
          aiResponse.content.contains(
            'Comprehensive_Metabolic_Panel_Oct2026.pdf',
          ),
          true,
        );
        expect(aiResponse.sources.isNotEmpty, true);
      },
    );
  });
}
