import '../../../core/constants/app_constants.dart';

/// Modèle d'un profil utilisateur (table `profiles`).
class Profile {
  const Profile({
    required this.id,
    required this.role,
    this.fullName,
    this.phone,
    this.avatarUrl,
    this.commune,
    this.latitude,
    this.longitude,
    this.ratingAvg = 0,
    this.ratingCount = 0,
  });

  final String id;
  final UserRole role;
  final String? fullName;
  final String? phone;
  final String? avatarUrl;
  final String? commune;
  final double? latitude;
  final double? longitude;
  final double ratingAvg;
  final int ratingCount;

  /// Nom affichable (fallback si vide).
  String get displayName =>
      (fullName == null || fullName!.trim().isEmpty) ? 'Utilisateur' : fullName!;

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      role: UserRole.fromValue(map['role'] as String?),
      fullName: map['full_name'] as String?,
      phone: map['phone'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      commune: map['commune'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      ratingAvg: (map['rating_avg'] as num?)?.toDouble() ?? 0,
      ratingCount: (map['rating_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'role': role.value,
        'full_name': fullName,
        'phone': phone,
        'avatar_url': avatarUrl,
        'commune': commune,
        'latitude': latitude,
        'longitude': longitude,
      };
}
