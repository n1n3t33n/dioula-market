import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../data/shop_repository.dart';

/// Écran « Ma boutique ».
/// - Si l'utilisateur n'a pas de boutique → propose d'en créer une.
/// - Sinon → affiche la boutique + accès à la gestion des produits.
class MyShopScreen extends ConsumerWidget {
  const MyShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopAsync = ref.watch(myShopProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ma boutique')),
      body: shopAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (shop) {
          // Pas encore de boutique → invitation à en créer une.
          if (shop == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.storefront_outlined,
                        size: 72, color: AppTheme.orange),
                    const SizedBox(height: 16),
                    const Text(
                      "Tu n'as pas encore de boutique.",
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => context.push(AppRoutes.shopForm),
                      icon: const Icon(Icons.add_business),
                      label: const Text('Créer ma boutique'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Boutique existante.
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppTheme.orange,
                            child: Text(
                              shop.name.characters.first.toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 22),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(shop.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge),
                                if (shop.category != null)
                                  Text(shop.category!,
                                      style: TextStyle(
                                          color: Colors.grey.shade600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (shop.description != null &&
                          shop.description!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(shop.description!),
                      ],
                      const SizedBox(height: 12),
                      if (shop.commune != null && shop.commune!.isNotEmpty)
                        _InfoRow(Icons.location_on_outlined, shop.commune!),
                      if (shop.address != null && shop.address!.isNotEmpty)
                        _InfoRow(Icons.home_outlined, shop.address!),
                      if (shop.phone != null && shop.phone!.isNotEmpty)
                        _InfoRow(Icons.phone_outlined, shop.phone!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.push(AppRoutes.shopProducts),
                icon: const Icon(Icons.inventory_2_outlined),
                label: const Text('Gérer mes produits'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () =>
                    context.push(AppRoutes.shopForm, extra: shop),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Modifier la boutique'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
