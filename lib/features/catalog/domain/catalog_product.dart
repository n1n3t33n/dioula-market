import '../../../core/utils/format.dart';

/// Produit enrichi pour le catalogue : champs du produit + infos de sa
/// boutique (nom, commune, note) obtenues via une jointure Supabase.
class CatalogProduct {
  const CatalogProduct({
    required this.id,
    required this.shopId,
    required this.name,
    required this.unit,
    required this.price,
    required this.stock,
    this.description,
    this.category,
    this.imageUrl,
    this.shopName = 'Boutique',
    this.shopCommune,
    this.shopRating = 0,
    this.shopRatingCount = 0,
  });

  final String id;
  final String shopId;
  final String name;
  final String unit;
  final double price;
  final double stock;
  final String? description;
  final String? category;
  final String? imageUrl;

  final String shopName;
  final String? shopCommune;
  final double shopRating;
  final int shopRatingCount;

  bool get inStock => stock > 0;
  String get priceLabel => formatFcfa(price);

  factory CatalogProduct.fromMap(Map<String, dynamic> map) {
    final shop = map['shops'] as Map<String, dynamic>?;
    return CatalogProduct(
      id: map['id'] as String,
      shopId: map['shop_id'] as String,
      name: map['name'] as String,
      unit: map['unit'] as String? ?? 'unité',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      stock: (map['stock'] as num?)?.toDouble() ?? 0,
      description: map['description'] as String?,
      category: map['category'] as String?,
      imageUrl: map['image_url'] as String?,
      shopName: shop?['name'] as String? ?? 'Boutique',
      shopCommune: shop?['commune'] as String?,
      shopRating: (shop?['rating_avg'] as num?)?.toDouble() ?? 0,
      shopRatingCount: (shop?['rating_count'] as num?)?.toInt() ?? 0,
    );
  }
}
