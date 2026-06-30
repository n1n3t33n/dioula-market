import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../data/orders_repository.dart';
import 'widgets/order_card.dart';

/// Espace livreur : **pool de courses disponibles** + **mes courses**.
/// Un livreur prend une course (→ en livraison) puis la marque livrée.
class CourierCoursesScreen extends StatelessWidget {
  const CourierCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Courses'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Disponibles'),
              Tab(text: 'Mes courses'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_AvailableTab(), _MyCoursesTab()],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Onglet « Disponibles » (pool)
// ---------------------------------------------------------------------------
class _AvailableTab extends ConsumerWidget {
  const _AvailableTab();

  Future<void> _claim(BuildContext context, WidgetRef ref, String id) async {
    try {
      await ref.read(ordersRepositoryProvider).claimOrder(id);
      ref.invalidate(availableCoursesProvider);
      ref.invalidate(myCoursesProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course acceptée 🛵 — bonne livraison !')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(availableCoursesProvider);
    return RefreshIndicator(
      color: AppColors.clay,
      onRefresh: () async => ref.invalidate(availableCoursesProvider),
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (orders) {
          if (orders.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 80),
                EmptyState(
                  icon: Icons.local_shipping_outlined,
                  title: 'Aucune course disponible',
                  message:
                      'Les commandes à livrer apparaîtront ici dès qu\'elles sont prêtes.',
                ),
              ],
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final o = orders[i];
              return OrderCard(
                order: o,
                showBuyer: true,
                action: FilledButton.icon(
                  onPressed: () => _claim(context, ref, o.id),
                  icon: const Icon(Icons.two_wheeler, size: 18),
                  label: const Text('Prendre la course'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Onglet « Mes courses »
// ---------------------------------------------------------------------------
class _MyCoursesTab extends ConsumerWidget {
  const _MyCoursesTab();

  Future<void> _deliver(BuildContext context, WidgetRef ref, String id) async {
    try {
      await ref.read(ordersRepositoryProvider).markDelivered(id);
      ref.invalidate(myCoursesProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commande livrée ✅')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myCoursesProvider);
    return RefreshIndicator(
      color: AppColors.clay,
      onRefresh: () async => ref.invalidate(myCoursesProvider),
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (orders) {
          if (orders.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 80),
                EmptyState(
                  icon: Icons.two_wheeler,
                  title: 'Aucune course en cours',
                  message:
                      'Prends une course dans l\'onglet « Disponibles » pour commencer.',
                ),
              ],
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final o = orders[i];
              return OrderCard(
                order: o,
                showBuyer: true,
                action: o.isDelivering
                    ? FilledButton.icon(
                        onPressed: () => _deliver(context, ref, o.id),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Marquer comme livrée'),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle,
                              size: 16, color: AppColors.success),
                          SizedBox(width: 6),
                          Text('Livrée',
                              style: TextStyle(color: AppColors.body)),
                        ],
                      ),
              );
            },
          );
        },
      ),
    );
  }
}
