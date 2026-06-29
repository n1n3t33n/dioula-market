import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/env.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../profile/data/profile_repository.dart';

/// Accueil après connexion. Affiche le profil + le rôle + la liste des
/// fonctionnalités. Les écrans réels seront branchés aux étapes suivantes.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  // (icône, libellé, route active ou null si pas encore disponible)
  static const _features = <(IconData, String, String?)>[
    (Icons.storefront_outlined, 'Ma boutique & produits', AppRoutes.myShop),
    (Icons.search, 'Catalogue & recherche', null),
    (Icons.bolt_outlined, 'Demande instantanée (temps réel)', null),
    (Icons.event_available_outlined, 'Réservation avec acompte', null),
    (Icons.map_outlined, 'Commerçants proches (carte)', null),
    (Icons.star_outline, 'Notation croisée 5 étoiles', null),
    (Icons.bar_chart, 'Dashboard commerçant', null),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!Env.isConfigured) {
      return _NotConfigured();
    }

    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppInfo.appName),
        actions: [
          const ThemeToggleButton(),
          IconButton(
            tooltip: 'Se déconnecter',
            icon: const Icon(Icons.logout),
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          profileAsync.when(
            loading: () => const Card(
              child: ListTile(
                leading: CircularProgressIndicator(),
                title: Text('Chargement du profil…'),
              ),
            ),
            error: (e, _) => Card(
              color: Colors.red.shade50,
              child: ListTile(
                leading: const Icon(Icons.error_outline, color: Colors.red),
                title: const Text('Erreur de chargement du profil'),
                subtitle: Text('$e'),
              ),
            ),
            data: (profile) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.green,
                  child: Text(
                    (profile?.displayName ?? '?')
                        .characters
                        .first
                        .toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text('Bonjour, ${profile?.displayName ?? "Utilisateur"}'),
                subtitle: profile == null
                    ? null
                    : Wrap(
                        spacing: 6,
                        children: [
                          Chip(
                            label: Text(profile.role.label),
                            visualDensity: VisualDensity.compact,
                          ),
                          if (profile.phone != null &&
                              profile.phone!.isNotEmpty)
                            Chip(
                              label: Text(profile.phone!),
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Fonctionnalités',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ..._features.map(
            (f) => Card(
              child: ListTile(
                leading: Icon(f.$1, color: AppTheme.orange),
                title: Text(f.$2),
                trailing: Icon(
                  f.$3 == null ? Icons.lock_clock : Icons.chevron_right,
                  color: f.$3 == null ? Colors.grey : null,
                ),
                enabled: f.$3 != null,
                onTap: f.$3 == null
                    ? null
                    : () => context.push(f.$3!),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotConfigured extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppInfo.appName)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.warning_amber, size: 64, color: Colors.orange),
              SizedBox(height: 16),
              Text('Supabase non configuré',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(
                'Copie .env.example → .env et renseigne SUPABASE_URL et '
                'SUPABASE_ANON_KEY, puis relance l\'application.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
