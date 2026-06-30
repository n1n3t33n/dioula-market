import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/supabase_provider.dart';
import '../../shops/domain/shop.dart';
import '../domain/catalog_product.dart';
import '../domain/instant_request.dart';

/// Accès en **lecture** au catalogue public (produits, boutiques, demandes).
/// Lisible par tout le monde, y compris les visiteurs (RLS : select = true).
class CatalogRepository {
  CatalogRepository(this._client);
  final SupabaseClient _client;

  /// Tous les produits actifs, avec les infos de leur boutique (jointure).
  Future<List<CatalogProduct>> fetchProducts() async {
    final data = await _client
        .from('products')
        .select('*, shops(name, commune, rating_avg, rating_count)')
        .eq('is_active', true)
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => CatalogProduct.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Toutes les boutiques actives, triées par meilleure note.
  /// Jointure sur le propriétaire pour connaître son statut de vérification.
  Future<List<Shop>> fetchShops() async {
    final data = await _client
        .from('shops')
        .select('*, owner:profiles(verification_status)')
        .eq('is_active', true)
        .order('rating_avg', ascending: false);
    return (data as List)
        .map((e) => Shop.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Demandes instantanées ouvertes (avec l'auteur).
  Future<List<InstantRequest>> fetchOpenRequests() async {
    final data = await _client
        .from('requests')
        .select('*, profiles(full_name, commune)')
        .eq('status', 'ouverte')
        .order('created_at', ascending: false)
        .limit(10);
    return (data as List)
        .map((e) => InstantRequest.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository(ref.watch(supabaseProvider));
});

/// Tous les produits du catalogue (sert à l'accueil + à la recherche).
final allProductsProvider = FutureProvider<List<CatalogProduct>>((ref) {
  return ref.watch(catalogRepositoryProvider).fetchProducts();
});

/// Toutes les boutiques (triées par note).
final allShopsProvider = FutureProvider<List<Shop>>((ref) {
  return ref.watch(catalogRepositoryProvider).fetchShops();
});

/// Boutiques « producteurs » (catégorie = Producteur).
final producerShopsProvider = FutureProvider<List<Shop>>((ref) async {
  final shops = await ref.watch(allShopsProvider.future);
  return shops.where((s) => s.category == 'Producteur').toList();
});

/// Demandes instantanées ouvertes.
final openRequestsProvider = FutureProvider<List<InstantRequest>>((ref) {
  return ref.watch(catalogRepositoryProvider).fetchOpenRequests();
});

/// Produits d'une boutique donnée (pour l'écran détail boutique).
final shopProductsProvider =
    FutureProvider.family<List<CatalogProduct>, String>((ref, shopId) async {
  final all = await ref.watch(allProductsProvider.future);
  return all.where((p) => p.shopId == shopId).toList();
});
