import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../auth/presentation/widgets/guest_invite_sheet.dart';
import '../../reviews/data/reviews_repository.dart';
import '../../reviews/presentation/widgets/review_tile.dart';
import '../../shops/domain/shop.dart';
import '../data/catalog_repository.dart';
import '../domain/categories.dart';
import 'widgets/product_card.dart';

/// Fiche d'une boutique : en-tête (note, commune, catégorie) + ses produits.
class ShopDetailScreen extends ConsumerWidget {
  const ShopDetailScreen({super.key, required this.shopId});

  final String shopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopsAsync = ref.watch(allShopsProvider);
    final productsAsync = ref.watch(shopProductsProvider(shopId));

    final Shop? shop = shopsAsync.maybeWhen(
      data: (list) {
        final match = list.where((s) => s.id == shopId);
        return match.isEmpty ? null : match.first;
      },
      orElse: () => null,
    );
    final accent = colorForCategory(shop?.category);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
            backgroundColor: accent,
            foregroundColor: Colors.white,
            title: Text(shop?.name ?? 'Boutique'),
            flexibleSpace: FlexibleSpaceBar(
              background: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [accent.withValues(alpha: 0.85), accent],
                  ),
                ),
                child: Center(
                  child: Icon(iconForCategory(shop?.category),
                      size: 56, color: Colors.white.withValues(alpha: 0.9)),
                ),
              ),
            ),
          ),
          if (shop != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 20, color: AppColors.warning),
                        const SizedBox(width: 4),
                        Text(
                          '${shop.ratingAvg.toStringAsFixed(1)} '
                          '(${shop.ratingCount} avis)',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.location_on_outlined,
                            size: 18, color: AppColors.body),
                        const SizedBox(width: 2),
                        Text(shop.commune ?? 'Côte d\'Ivoire',
                            style: const TextStyle(color: AppColors.body)),
                      ],
                    ),
                    if (shop.description != null) ...[
                      const SizedBox(height: 10),
                      Text(shop.description!,
                          style: const TextStyle(
                              color: AppColors.body, height: 1.4)),
                    ],
                    const SizedBox(height: 16),
                    Text('Produits',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          productsAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Erreur de chargement : $e'),
              ),
            ),
            data: (products) {
              if (products.isEmpty) {
                return const SliverToBoxAdapter(
                  child: EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: 'Aucun produit',
                    message: 'Cette boutique n\'a pas encore publié de produit.',
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.66,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final p = products[i];
                      return ProductCard(
                        product: p,
                        onTap: () => context.push(AppRoutes.productDetail,
                            extra: p),
                        onAdd: () => requireAccount(context, ref,
                            action: 'réserver ce produit'),
                      );
                    },
                    childCount: products.length,
                  ),
                ),
              );
            },
          ),
          if (shop != null)
            SliverToBoxAdapter(child: _ReviewsSection(shopId: shopId)),
        ],
      ),
    );
  }
}

/// Section « Avis » de la fiche boutique (liste des notations reçues).
class _ReviewsSection extends ConsumerWidget {
  const _ReviewsSection({required this.shopId});
  final String shopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(shopReviewsProvider(shopId));
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          async.maybeWhen(
            data: (reviews) => Text('Avis (${reviews.length})',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            orElse: () => Text('Avis',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 4),
          async.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('Erreur : $e',
                style: const TextStyle(color: AppColors.body)),
            data: (reviews) {
              if (reviews.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Aucun avis pour le moment.',
                      style: TextStyle(color: AppColors.body)),
                );
              }
              return Column(
                children: [
                  for (final rv in reviews) ReviewTile(review: rv),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
