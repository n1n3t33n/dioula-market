import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/supabase_provider.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/guest_gate.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/guest_provider.dart';
import '../../reviews/presentation/widgets/star_rating.dart';
import '../data/profile_repository.dart';

/// Onglet « Profil » : infos utilisateur + paramètres (dark mode, déconnexion).
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mode visiteur : pas de profil → invitation à se connecter.
    if (ref.watch(isGuestProvider)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: const GuestGate(
          icon: Icons.person_outline,
          title: 'Tu explores en visiteur',
          message:
              'Connecte-toi ou crée un compte pour avoir un profil, une note et accéder à toutes les fonctionnalités.',
        ),
      );
    }

    final profile = ref.watch(currentProfileProvider).value;
    final email = ref.watch(supabaseProvider).auth.currentUser?.email ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = profile?.displayName ?? 'Utilisateur';
    final role = profile?.role;
    final avatarUrl = profile?.avatarUrl;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // En-tête profil
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.clay,
                  backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                      ? CachedNetworkImageProvider(avatarUrl)
                      : null,
                  child: (avatarUrl == null || avatarUrl.isEmpty)
                      ? Text(
                          name.characters.first.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(name,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                if (profile != null)
                  Chip(
                    label: Text(profile.role.label),
                    avatar: const Icon(Icons.badge_outlined, size: 16),
                  ),
                if (profile != null && profile.ratingCount > 0) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StarsDisplay(rating: profile.ratingAvg, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '${profile.ratingAvg.toStringAsFixed(1)} '
                        '(${profile.ratingCount} avis)',
                        style: const TextStyle(color: AppColors.body),
                      ),
                    ],
                  ),
                ],
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(email, style: const TextStyle(color: AppColors.body)),
                ],
                if (profile?.phone != null && profile!.phone!.isNotEmpty)
                  Text(profile.phone!,
                      style: const TextStyle(color: AppColors.body)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Paramètres',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode_outlined),
                  title: const Text('Mode sombre'),
                  value: isDark,
                  onChanged: (v) => ref
                      .read(themeModeProvider.notifier)
                      .set(v ? ThemeMode.dark : ThemeMode.light),
                ),
                // Boutique : réservée aux vendeurs (commerçant / producteur).
                if (role?.isSeller ?? false) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.storefront_outlined),
                    title: const Text('Ma boutique'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRoutes.myShop),
                  ),
                ],
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.school_outlined),
                  title: const Text('Revoir le tutoriel'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(
                    AppRoutes.tutorial,
                    extra: profile?.role,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: AppColors.danger.withValues(alpha: 0.08),
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppColors.danger),
              title: const Text('Se déconnecter',
                  style: TextStyle(color: AppColors.danger)),
              onTap: () =>
                  ref.read(authControllerProvider.notifier).signOut(),
            ),
          ),
        ],
      ),
    );
  }
}
