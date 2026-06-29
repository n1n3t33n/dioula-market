import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../data/reservations_repository.dart';
import 'widgets/reservation_card.dart';

/// « Réservations reçues » (vendeur) : confirme le retrait (solde réglé).
class ShopReservationsScreen extends ConsumerWidget {
  const ShopReservationsScreen({super.key, required this.shopId});
  final String shopId;

  Future<void> _complete(
      BuildContext context, WidgetRef ref, String id) async {
    try {
      await ref.read(reservationsRepositoryProvider).completeReservation(id);
      ref.invalidate(shopReservationsProvider(shopId));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Retrait confirmé ✅ Réservation terminée.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(shopReservationsProvider(shopId));
    return Scaffold(
      appBar: AppBar(title: const Text('Réservations reçues')),
      body: RefreshIndicator(
        color: AppColors.clay,
        onRefresh: () async => ref.invalidate(shopReservationsProvider(shopId)),
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur : $e')),
          data: (list) {
            if (list.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 80),
                  EmptyState(
                    icon: Icons.event_note_outlined,
                    title: 'Aucune réservation',
                    message:
                        'Les réservations de tes clients apparaîtront ici.',
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final r = list[i];
                return ReservationCard(
                  reservation: r,
                  action: r.isActive
                      ? FilledButton.icon(
                          onPressed: () => _complete(context, ref, r.id),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Confirmer le retrait'),
                        )
                      : null,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
