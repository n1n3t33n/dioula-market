import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env.dart';
import '../../../core/constants/app_constants.dart';
import '../../profile/presentation/profile_page.dart';
import '../../shops/presentation/my_shop_screen.dart';
import 'home_feed_page.dart';

/// Coquille principale de l'app (après connexion) : barre de navigation
/// basse façon Foodly + contenu en `IndexedStack` (conserve l'état des onglets).
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _index = 0;

  void _goTo(int i) => setState(() => _index = i);

  /// Icône « sélectionnée » qui rebondit (élastique) à chaque changement
  /// d'onglet — la clé suit l'index pour rejouer l'animation.
  Widget _bounce(IconData icon) => Icon(icon)
      .animate(key: ValueKey(_index))
      .scaleXY(begin: 0.7, end: 1, duration: 350.ms, curve: Curves.elasticOut);

  @override
  Widget build(BuildContext context) {
    // Sans backend configuré : message d'aide (mode démo).
    if (!Env.isConfigured) return const _NotConfigured();

    final pages = [
      HomeFeedPage(onOpenShop: () => _goTo(1)),
      const MyShopScreen(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goTo,
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: _bounce(Icons.home),
              label: 'Accueil'),
          NavigationDestination(
              icon: const Icon(Icons.storefront_outlined),
              selectedIcon: _bounce(Icons.storefront),
              label: 'Boutique'),
          NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: _bounce(Icons.person),
              label: 'Profil'),
        ],
      ),
    );
  }
}

class _NotConfigured extends StatelessWidget {
  const _NotConfigured();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppInfo.appName)),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber, size: 64, color: Colors.orange),
              SizedBox(height: 16),
              Text('Supabase non configuré',
                  style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
