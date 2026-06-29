import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/supabase_provider.dart';
import '../domain/shop.dart';

/// Accès aux boutiques dans Supabase (table `shops`).
class ShopRepository {
  ShopRepository(this._client);
  final SupabaseClient _client;

  /// Récupère la boutique du propriétaire (la 1ʳᵉ s'il en a plusieurs).
  /// Renvoie `null` s'il n'en a pas encore.
  Future<Shop?> fetchByOwner(String ownerId) async {
    final data = await _client
        .from('shops')
        .select()
        .eq('owner_id', ownerId)
        .order('created_at')
        .limit(1)
        .maybeSingle();
    return data == null ? null : Shop.fromMap(data);
  }

  /// Crée une boutique et renvoie la version enregistrée (avec id généré).
  Future<Shop> create(Shop shop) async {
    final data =
        await _client.from('shops').insert(shop.toWriteMap()).select().single();
    return Shop.fromMap(data);
  }

  /// Met à jour une boutique existante.
  Future<Shop> update(Shop shop) async {
    final data = await _client
        .from('shops')
        .update(shop.toWriteMap())
        .eq('id', shop.id)
        .select()
        .single();
    return Shop.fromMap(data);
  }
}

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  return ShopRepository(ref.watch(supabaseProvider));
});

/// Boutique de l'utilisateur connecté (null s'il n'en a pas).
/// On l'invalide après création/édition pour rafraîchir l'écran.
final myShopProvider = FutureProvider<Shop?>((ref) async {
  ref.watch(authStateProvider);
  final uid = ref.watch(supabaseProvider).auth.currentUser?.id;
  if (uid == null) return null;
  return ref.watch(shopRepositoryProvider).fetchByOwner(uid);
});
