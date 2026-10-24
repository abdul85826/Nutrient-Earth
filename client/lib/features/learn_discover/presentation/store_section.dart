import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/design_system.dart';
import '../data/learn_discover_repository.dart';
import '../domain/learn_discover_models.dart';

class StoreSection extends ConsumerWidget {
  const StoreSection({super.key});

  void _showProductDetails(BuildContext context, ProductItem product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: NETokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(NETokens.radiusLg),
        ),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(NETokens.space20),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: NETokens.borderDefault,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: NETokens.space16),
            Row(
              children: [
                NEChip(label: product.category, type: NEChipType.outline),
                const SizedBox(width: NETokens.space8),
                NEChip(
                  label: product.thirdPartyCert,
                  type: NEChipType.measured,
                ),
              ],
            ),
            const SizedBox(height: NETokens.space12),
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: NETokens.textPrimary,
              ),
            ),
            const SizedBox(height: NETokens.space8),
            Text(
              '\$${product.price.toStringAsFixed(2)} ${product.currency}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: NETokens.primary,
              ),
            ),
            const SizedBox(height: NETokens.space12),
            Text(
              product.summary,
              style: const TextStyle(
                fontSize: 14,
                color: NETokens.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: NETokens.space20),
            const Text(
              'Verified Purity & Specifications:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: NETokens.primary,
              ),
            ),
            const SizedBox(height: NETokens.space8),
            ...product.verifiedSpecs.map(
              (spec) => Padding(
                padding: const EdgeInsets.only(bottom: NETokens.space6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified_outlined,
                      size: 15,
                      color: NETokens.primaryLight,
                    ),
                    const SizedBox(width: NETokens.space8),
                    Expanded(
                      child: Text(
                        spec,
                        style: const TextStyle(
                          fontSize: 12,
                          color: NETokens.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: NETokens.space16),
            const Text(
              'Transparent Pricing Breakdown:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: NETokens.textPrimary,
              ),
            ),
            const SizedBox(height: NETokens.space8),
            Container(
              padding: const EdgeInsets.all(NETokens.space12),
              decoration: BoxDecoration(
                color: NETokens.surfaceElevated,
                borderRadius: BorderRadius.circular(NETokens.radiusMd),
                border: Border.all(color: NETokens.borderSubtle),
              ),
              child: Text(
                product.transparentPricingBreakdown,
                style: const TextStyle(
                  fontSize: 12,
                  color: NETokens.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: NETokens.space24),
            NEButton(
              label: 'Add to Regimen Plan',
              icon: Icons.check_rounded,
              fullWidth: true,
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${product.name} added to verified active plan.',
                    ),
                    backgroundColor: NETokens.success,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(storeProductsProvider);

    return productsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error loading store: $err')),
      data: (products) => ListView.builder(
        padding: const EdgeInsets.all(NETokens.space16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: NETokens.space12),
            child: NECard(
              onTap: () => _showProductDetails(context, product),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: NETokens.surfaceElevated,
                      borderRadius: BorderRadius.circular(NETokens.radiusMd),
                      border: Border.all(color: NETokens.borderSubtle),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: NETokens.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: NETokens.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            NEChip(
                              label: product.category,
                              type: NEChipType.outline,
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 15,
                                  color: NETokens.warning,
                                ),
                                const SizedBox(width: NETokens.space2),
                                Text(
                                  '${product.rating} (${product.reviewCount})',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: NETokens.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: NETokens.space8),
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: NETokens.textPrimary,
                          ),
                        ),
                        const SizedBox(height: NETokens.space4),
                        Text(
                          product.thirdPartyCert,
                          style: const TextStyle(
                            fontSize: 11,
                            color: NETokens.primaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: NETokens.space8),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: NETokens.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
