import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../shops/data/shop_repository.dart';
import '../data/product_repository.dart';
import '../domain/product.dart';
import 'product_controller.dart';

/// Liste des produits de MA boutique, avec ajout / édition / suppression.
class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopAsync = ref.watch(myShopProvider);

    return shopAsync.when(
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text('Erreur : $e'))),
      data: (shop) {
        if (shop == null) {
          return const Scaffold(
            body: Center(child: Text('Crée d\'abord ta boutique.')),
          );
        }

        final productsAsync = ref.watch(productsByShopProvider(shop.id));

        return Scaffold(
          appBar: AppBar(title: const Text('Mes produits')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push(
              AppRoutes.productForm,
              // On passe (shopId, produit-à-éditer=null) pour une création.
              extra: (shop.id, null),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter'),
          ),
          body: productsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erreur : $e')),
            data: (products) {
              if (products.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Aucun produit pour le moment.\nAppuie sur « Ajouter ».',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) =>
                    _ProductTile(products[i], shop.id),
              );
            },
          ),
        );
      },
    );
  }
}

class _ProductTile extends ConsumerWidget {
  const _ProductTile(this.product, this.shopId);
  final Product product;
  final String shopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lowStock = product.stock <= 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            // Vignette produit (image si fournie, sinon icône).
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                height: 64,
                width: 64,
                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.imageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const _Placeholder(),
                        placeholder: (_, __) => const _Placeholder(),
                      )
                    : const _Placeholder(),
              ),
            ),
            const SizedBox(width: 12),
            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (product.category != null &&
                      product.category!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(product.category!,
                        style: const TextStyle(
                            color: AppColors.body, fontSize: 12)),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '${product.price.toStringAsFixed(0)} FCFA',
                        style: const TextStyle(
                            color: AppColors.green,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(' / ${product.unit}',
                          style: const TextStyle(color: AppColors.body)),
                      const SizedBox(width: 8),
                      _StockBadge(stock: product.stock, low: lowStock),
                    ],
                  ),
                ],
              ),
            ),
            // Actions
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Modifier',
              onPressed: () => context.push(
                AppRoutes.productForm,
                extra: (shopId, product),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              tooltip: 'Supprimer',
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ce produit ?'),
        content: Text('« ${product.name} » sera définitivement supprimé.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Supprimer')),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(productControllerProvider.notifier).delete(product);
    }
  }
}

/// Vignette par défaut quand le produit n'a pas d'image.
class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.green.withValues(alpha: 0.12),
      child: const Icon(Icons.shopping_basket_outlined,
          color: AppColors.green),
    );
  }
}

/// Petit badge d'état du stock (disponible / épuisé).
class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.stock, required this.low});
  final double stock;
  final bool low;

  @override
  Widget build(BuildContext context) {
    final color = low ? AppColors.danger : AppColors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        low ? 'Épuisé' : 'Stock ${stock.toStringAsFixed(0)}',
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
