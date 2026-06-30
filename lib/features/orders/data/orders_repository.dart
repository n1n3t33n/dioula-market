import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/supabase_provider.dart';
import '../domain/order.dart';

/// Accès aux commandes + livraison (table `orders`).
/// Les transitions (prise en charge, livraison) sont des RPC atomiques
/// côté SQL (`step10.sql`).
class OrdersRepository {
  OrdersRepository(this._client);
  final SupabaseClient _client;

  // Jointures : boutique, acheteur (FK buyer_id), lignes de commande.
  static const _select =
      '*, shops(name), buyer:profiles!buyer_id(full_name), '
      'order_items(product_name, quantity)';

  /// Pool des courses disponibles (non assignées) — visible par les livreurs.
  Future<List<Order>> fetchAvailable() async {
    final data = await _client
        .from('orders')
        .select(_select)
        .isFilter('courier_id', null)
        .inFilter('status', ['en_cours', 'preparee']).order('created_at');
    return (data as List)
        .map((e) => Order.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Les courses du livreur connecté (en cours + historique).
  Future<List<Order>> fetchMyCourses() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return [];
    final data = await _client
        .from('orders')
        .select(_select)
        .eq('courier_id', uid)
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => Order.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Les commandes de l'acheteur connecté (suivi).
  Future<List<Order>> fetchMyOrders() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return [];
    final data = await _client
        .from('orders')
        .select(_select)
        .eq('buyer_id', uid)
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => Order.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> claimOrder(String id) =>
      _client.rpc('claim_order', params: {'p_order_id': id});

  Future<void> markDelivered(String id) =>
      _client.rpc('mark_order_delivered', params: {'p_order_id': id});
}

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepository(ref.watch(supabaseProvider));
});

/// Pool des courses disponibles (livreur).
final availableCoursesProvider =
    FutureProvider.autoDispose<List<Order>>((ref) {
  return ref.watch(ordersRepositoryProvider).fetchAvailable();
});

/// Courses prises en charge par le livreur connecté.
final myCoursesProvider = FutureProvider.autoDispose<List<Order>>((ref) {
  return ref.watch(ordersRepositoryProvider).fetchMyCourses();
});

/// Commandes de l'acheteur connecté (suivi).
final myOrdersProvider = FutureProvider.autoDispose<List<Order>>((ref) {
  return ref.watch(ordersRepositoryProvider).fetchMyOrders();
});
