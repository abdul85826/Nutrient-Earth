import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/core/domain/health/health_data_types.dart';
import 'package:nutrient_earth_client/core/domain/health/health_platform_adapter.dart';
import 'package:nutrient_earth_client/core/services/health/health_integration_service.dart';
import 'package:nutrient_earth_client/features/health_sync/presentation/widgets/health_sync_card.dart';
import 'package:nutrient_earth_client/features/health_sync/presentation/widgets/health_sync_modal.dart';
import 'package:nutrient_earth_client/features/health_sync/state/health_sync_state.dart';

class MockPlatformAdapter implements HealthPlatformAdapter {
  @override
  String get platformName => 'Mock Health Connect';

  @override
  Future<bool> isPlatformSupported() async => true;

  @override
  Future<bool> isHealthStoreAvailable() async => true;

  @override
  Future<bool> checkPermissions(List<HealthDataType> types) async => true;

  @override
  Future<bool> requestPermissions(List<HealthDataType> types) async => true;

  @override
  Future<List<HealthRecord>> readRecords({
    required List<HealthDataType> types,
    required DateTime startTime,
    required DateTime endTime,
    String? syncCursor,
  }) async =>
      const [];

  @override
  Future<void> revokePermissions() async {}
}

void main() {
  testWidgets('HealthSyncCard renders with zero overflows on narrow (320px) viewport', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final service = HealthIntegrationService(adapter: MockPlatformAdapter());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          healthSyncStateProvider.overrideWith((ref) => HealthSyncNotifier(service)),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HealthSyncCard(),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Steps'), findsOneWidget);
    expect(find.text('Distance'), findsOneWidget);
    expect(find.text('Active Cal'), findsOneWidget);
    expect(find.text('Heart Rate'), findsOneWidget);
    expect(find.text('Sleep'), findsOneWidget);
  });

  testWidgets('HealthSyncCard renders with zero overflows on standard (380px) viewport', (tester) async {
    tester.view.physicalSize = const Size(380, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final service = HealthIntegrationService(adapter: MockPlatformAdapter());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          healthSyncStateProvider.overrideWith((ref) => HealthSyncNotifier(service)),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HealthSyncCard(),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Steps'), findsOneWidget);
    expect(find.text('Heart Rate'), findsOneWidget);
  });

  testWidgets('HealthSyncModal opens with zero bottom overflows on constrained height', (tester) async {
    tester.view.physicalSize = const Size(360, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final service = HealthIntegrationService(adapter: MockPlatformAdapter());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          healthSyncStateProvider.overrideWith((ref) => HealthSyncNotifier(service)),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showHealthSyncModal(context),
                child: const Text('Open Modal'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Native Health Sync'), findsOneWidget);
  });
}
