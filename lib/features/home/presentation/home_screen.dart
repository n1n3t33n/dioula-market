import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env.dart';
import '../../../core/constants/app_constants.dart';

/// Écran d'accueil temporaire (étape 1).
/// Sert de point d'entrée visuel et affiche l'état de configuration Supabase.
/// Il sera remplacé par la vraie navigation aux étapes suivantes.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configured = Env.isConfigured;

    final features = <(IconData, String)>[
      (Icons.lock_outline, 'Authentification + 2FA SMS (simulée)'),
      (Icons.storefront_outlined, 'Boutiques virtuelles & produits'),
      (Icons.search, 'Catalogue & recherche'),
      (Icons.bolt_outlined, 'Demande instantanée (temps réel)'),
      (Icons.event_available_outlined, 'Réservation avec acompte'),
      (Icons.map_outlined, 'Commerçants proches (carte)'),
      (Icons.star_outline, 'Notation croisée 5 étoiles'),
      (Icons.bar_chart, 'Dashboard commerçant'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text(AppInfo.appName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          Text(
            AppInfo.tagline,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Card(
            color: configured
                ? Colors.green.shade50
                : Colors.orange.shade50,
            child: ListTile(
              leading: Icon(
                configured ? Icons.check_circle : Icons.warning_amber,
                color: configured ? Colors.green : Colors.orange,
              ),
              title: Text(
                configured
                    ? 'Supabase configuré'
                    : 'Supabase non configuré',
              ),
              subtitle: Text(
                configured
                    ? 'Connexion backend prête.'
                    : 'Copie .env.example → .env et renseigne tes clés.',
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Fonctionnalités prévues',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ...features.map(
            (f) => Card(
              child: ListTile(
                leading: Icon(f.$1, color: AppThemeColors.orange),
                title: Text(f.$2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Petit alias couleur pour éviter d'importer le thème ici.
class AppThemeColors {
  static const orange = Color(0xFFF77F00);
}
