import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/features/learn_discover/data/learn_discover_repository.dart';

void main() {
  group('Learn & Discover Domain Tests', () {
    late LearnDiscoverRepository repository;

    setUp(() {
      repository = LearnDiscoverRepository();
    });

    test('Loads peer-reviewed learn articles with primary citations', () async {
      final articles = await repository.getArticles();
      expect(articles.isNotEmpty, true);

      for (final article in articles) {
        expect(article.title.isNotEmpty, true);
        expect(article.primarySourceCitation.isNotEmpty, true);
        expect(article.evidenceScore >= 80, true);
        expect(article.keyTakeaways.isNotEmpty, true);
      }
    });

    test(
      'Loads exercise routines with movement cues and injury modifications',
      () async {
        final routines = await repository.getExerciseRoutines();
        expect(routines.isNotEmpty, true);

        for (final routine in routines) {
          expect(routine.name.isNotEmpty, true);
          expect(routine.movements.isNotEmpty, true);
          expect(routine.injuryModifications.isNotEmpty, true);
          expect(routine.scientificRationale.isNotEmpty, true);
        }
      },
    );

    test('Loads store products with transparent pricing breakdowns and third-party certifications', () async {
      final products = await repository.getStoreProducts();
      expect(products.isNotEmpty, true);

      for (final product in products) {
        expect(product.name.isNotEmpty, true);
        expect(product.price > 0, true);
        expect(product.thirdPartyCert.isNotEmpty, true);
        expect(product.transparentPricingBreakdown.isNotEmpty, true);
        expect(product.verifiedSpecs.isNotEmpty, true);
      }
    });
  });
}
