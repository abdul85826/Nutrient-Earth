import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth/core/intelligence/medical_safety_guard.dart';

void main() {
  group('MedicalSafetyGuard Acute Emergency Triage Tests', () {
    test('detects acute cardiac emergency symptoms', () {
      final result = MedicalSafetyGuard.evaluate(
        'I feel sudden crushing chest pain radiating to my left arm and jaw',
      );
      expect(result.isEmergency, isTrue);
      expect(result.emergencyCategory, equals('cardiac_coronary'));
      expect(result.recommendedAction, contains('911'));
    });

    test('detects acute stroke symptoms (FAST)', () {
      final result = MedicalSafetyGuard.evaluate(
        'My mother has sudden facial drooping, arm numbness and slurred speech',
      );
      expect(result.isEmergency, isTrue);
      expect(result.emergencyCategory, equals('neurological_stroke'));
      expect(result.emergencyNotice, contains('emergency'));
    });

    test('detects severe respiratory distress and anaphylaxis', () {
      final result1 = MedicalSafetyGuard.evaluate(
        'I ate peanuts and my throat is swelling shut, having severe anaphylaxis',
      );
      expect(result1.isEmergency, isTrue);
      expect(result1.emergencyCategory, equals('anaphylaxis_allergic'));

      final result2 = MedicalSafetyGuard.evaluate(
        'Severe shortness of breath, cannot catch breath and gasping',
      );
      expect(result2.isEmergency, isTrue);
      expect(result2.emergencyCategory, equals('acute_respiratory'));
    });

    test('detects crisis and self-harm keywords', () {
      final result = MedicalSafetyGuard.evaluate(
        'Feeling like ending my life, wanting to commit suicide',
      );
      expect(result.isEmergency, isTrue);
      expect(result.emergencyCategory, equals('crisis_support'));
      expect(result.recommendedAction, contains('988'));
    });

    test('safe evidence research queries pass without false positives', () {
      final queries = [
        'Pea protein bioavailability and muscle synthesis',
        'Magnesium bisglycinate chelate for slow-wave sleep',
        'Circadian daylight photon timing and melatonin synthesis',
        'Postprandial walking and GLUT4 translocation',
        'Liposomal Vitamin D3 and K2 osteocalcin activation',
      ];

      for (final query in queries) {
        final result = MedicalSafetyGuard.evaluate(query);
        expect(
          result.isEmergency,
          isFalse,
          reason: 'Query "$query" should not trigger emergency',
        );
        expect(result.emergencyNotice, isNull);
      }
    });
  });
}
