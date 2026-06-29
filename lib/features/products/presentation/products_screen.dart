import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_theme.dart';
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
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.green.withValues(alpha: 0.15),
          child: const Icon(Icons.shopping_basket_outlined,
              color: AppTheme.green),
        ),
        title: Text(product.name),
        subtitle: Text(
          '${product.price.toStringAsFixed(0)} FCFA / ${product.unit}'
          '  •  Stock : ${product.stock.toStringAsFixed(0)}'
          '${lowStock ? " (épuisé)" : ""}',
          style: TextStyle(color: lowStock ? Colors.red : null),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Modifier',
              onPressed: () => context.push(
                AppRoutes.productForm,
                extra: (shopId, product),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
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
