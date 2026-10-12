import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth/features/growth/presentation/growth_screen.dart';

void main() {
  group('Growth Evidence Protocols Tests', () {
    test('contains verified evidence protocols', () {
      expect(kStandardEvidenceProtocols.length, equals(5));
      expect(
        kStandardEvidenceProtocols.any((p) => p.id == 'circadian_lux'),
        isTrue,
      );
      expect(
        kStandardEvidenceProtocols.any((p) => p.id == 'morning_hydration'),
        isTrue,
      );
      expect(
        kStandardEvidenceProtocols.any((p) => p.id == 'protein_pacing'),
        isTrue,
      );
      expect(
        kStandardEvidenceProtocols.any((p) => p.id == 'postprandial_walk'),
        isTrue,
      );
      expect(
        kStandardEvidenceProtocols.any((p) => p.id == 'evening_attenuation'),
        isTrue,
      );
    });

    test('ProtocolCompletionNotifier tracks daily protocol completion', () {
      final notifier = ProtocolCompletionNotifier();
      expect(notifier.state.isEmpty, isTrue);

      notifier.toggleProtocol('circadian_lux');
      expect(notifier.state.contains('circadian_lux'), isTrue);
      expect(notifier.state.length, equals(1));

      notifier.toggleProtocol('morning_hydration');
      expect(notifier.state.length, equals(2));

      // Untoggle
      notifier.toggleProtocol('circadian_lux');
      expect(notifier.state.contains('circadian_lux'), isFalse);
      expect(notifier.state.length, equals(1));

      // Reset
      notifier.resetAll();
      expect(notifier.state.isEmpty, isTrue);
    });
  });
}
