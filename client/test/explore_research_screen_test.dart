// ==============================================================================
// Nutrient Earth — Explore & Research Tab Screen Test Suite
// Verifies search interactions, multimodal inputs, 10-stage progressive loading,
// research answer dossier, citation rendering, and blockchain proof modal.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nutrient_earth_client/core/domain/blockchain/evidence_integrity_service.dart';
import 'package:nutrient_earth_client/core/domain/blockchain/mock_testnet_anchor_provider.dart';
import 'package:nutrient_earth_client/features/explore/presentation/explore_screen.dart';
import 'package:nutrient_earth_client/features/explore/presentation/widgets/blockchain_provenance_card.dart';
import 'package:nutrient_earth_client/features/explore/presentation/widgets/citation_card.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    dotenv.testLoad(fileInput: 'SUPABASE_URL=https://placeholder.supabase.co\nSUPABASE_ANON_KEY=placeholder-anon-key\n');
  });
  Widget createTestWidget({String? initialQuery}) {
    return ProviderScope(
      overrides: [
        evidenceIntegrityServiceProvider.overrideWithValue(
          EvidenceIntegrityService(anchorProvider: MockTestnetAnchorProvider()),
        ),
      ],
      child: MaterialApp(
        home: ExploreScreen(initialQuery: initialQuery),
      ),
    );
  }

  group('ExploreScreen: Initial Empty State & Curated Inquiries', () {
    testWidgets('Renders header, search bar, multimodal chips, and curated research queries', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Explore & Research'), findsOneWidget);
      expect(find.text('PEER-REVIEWED EVIDENCE COMPANION'), findsOneWidget);

      // Verify Search Bar and Multimodal Chips
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Meal / Label'), findsOneWidget);
      expect(find.text('Voice'), findsOneWidget);
      expect(find.text('PubMed URL'), findsOneWidget);

      // Verify Curated Research Categories
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Sleep & Recovery'), findsOneWidget);
      expect(find.text('Protein Kinetics'), findsOneWidget);

      // Verify Curated Cards
      expect(find.textContaining('Magnesium bisglycinate vs oxide'), findsOneWidget);
      expect(find.textContaining('Dose-dependent muscle protein synthesis'), findsOneWidget);
    });

    testWidgets('Tapping multimodal chip opens educational attachment dialog', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Meal / Label'));
      await tester.pumpAndSettle();

      expect(find.text('Scan Meal or Supplement Label'), findsOneWidget);
      expect(find.text('Analyze Food Plate'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Scan Meal or Supplement Label'), findsNothing);
    });
  });

  group('ExploreScreen: Research Inquiry Submission & Evidence Dossier', () {
    testWidgets('Submitting inquiry executes pipeline and displays complete evidence dossier', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter query
      await tester.enterText(
        find.byType(TextField),
        'How does dietary magnesium glycinate compare to magnesium oxide for sleep quality?',
      );
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump(); // Start search loading

      await tester.pumpAndSettle(); // Settle pipeline completion

      // Verify Evidence Badge & Synthesis
      expect(find.textContaining('GRADE A'), findsOneWidget);
      expect(find.text('SCIENTIFIC SYNTHESIS'), findsOneWidget);
      expect(find.textContaining('Magnesium bisglycinate demonstrates significantly higher intestinal absorption'), findsOneWidget);

      // Verify Citations Grid
      expect(find.byType(CitationCard), findsWidgets);
      expect(find.textContaining('Bioavailability of US commercially available magnesium preparations'), findsOneWidget);
      expect(find.text('PMID: 11794633'), findsOneWidget);

      // Verify Blockchain Provenance Card
      expect(find.byType(BlockchainProvenanceCard), findsOneWidget);
      expect(find.text('EVIDENCE PROVENANCE'), findsOneWidget);
      expect(find.text('Manifest SHA-256'), findsOneWidget);
      expect(find.text('Merkle Root'), findsOneWidget);
      expect(find.text('sepolia-testnet'), findsOneWidget);
      expect(find.text('Verify Cryptographic Proof'), findsOneWidget);
    });

    testWidgets('Tapping Verify Cryptographic Proof triggers verification and opens audit modal', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Submit query
      await tester.enterText(find.byType(TextField), 'Magnesium glycinate sleep');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      // Tap Verify Cryptographic Proof
      final verifyButton = find.text('Verify Cryptographic Proof');
      expect(verifyButton, findsOneWidget);
      await tester.ensureVisible(verifyButton);
      await tester.tap(verifyButton);
      await tester.pumpAndSettle();

      // Modal should be displayed
      expect(find.text('Cryptographic Proof Audit'), findsOneWidget);
      expect(find.text('Merkle Inclusion Audit Path (RFC-6962)'), findsOneWidget);
      expect(find.text('Merkle Proof Path Verified Valid'), findsOneWidget);
      expect(find.text('1. LEAF HASH (CANONICAL MANIFEST)'), findsOneWidget);
      expect(find.text('3. EVALUATED MERKLE ROOT'), findsOneWidget);

      // Close modal
      await tester.tap(find.text('Close Verification Dossier'));
      await tester.pumpAndSettle();

      expect(find.text('Cryptographic Proof Audit'), findsNothing);
    });

    testWidgets('Displays Contradictory Evidence Alert when scientific outcomes are divided', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Submit query on antioxidants and training adaptation (conflicting evidence)
      await tester.enterText(
        find.byType(TextField),
        'Do high dose antioxidant supplements blunt exercise training adaptations?',
      );
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      // Verify conflicting evidence banner
      expect(find.text('STUDY LIMITATIONS & CONFLICTING EVIDENCE'), findsOneWidget);
      expect(find.textContaining('blunts long-term aerobic enzyme adaptation'), findsOneWidget);
    });
  });
}
