import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/guest_gate.dart';
import '../../auth/presentation/guest_provider.dart';
import '../data/orders_repository.dart';
import 'widgets/order_card.dart';

/// « Mes commandes » (acheteur) : suivi du statut de livraison.
class MyOrdersScreen extends ConsumerWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(isGuestProvider)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mes commandes')),
        body: const GuestGate(
          icon: Icons.receipt_long,
          title: 'Mes commandes',
          message:
              'Crée un compte pour passer commande et suivre tes livraisons.',
        ),
      );
    }

    final async = ref.watch(myOrdersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Mes commandes')),
      body: RefreshIndicator(
        color: AppColors.clay,
        onRefresh: () async => ref.invalidate(myOrdersProvider),
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur : $e')),
          data: (orders) {
            if (orders.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 80),
                  EmptyState(
                    icon: Icons.receipt_long,
                    title: 'Aucune commande',
                    message:
                        'Accepte une offre sur une demande pour créer ta première commande.',
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => OrderCard(order: orders[i]),
            );
          },
        ),
      ),
    );
  }
}
