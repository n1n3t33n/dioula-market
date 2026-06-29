import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import '../../auth/presentation/guest_provider.dart';
import '../../profile/data/profile_repository.dart';

/// Onglet « Accueil » — style Foodly : en-tête (salutation + avatar),
/// barre de recherche, catégories, bannière promo, et raccourcis.
class HomeFeedPage extends ConsumerWidget {
  const HomeFeedPage({super.key, required this.onOpenShop});

  /// Permet d'ouvrir l'onglet Boutique depuis une carte de l'accueil.
  final VoidCallback onOpenShop;

  static const _categories = <(IconData, String)>[
    (Icons.eco_outlined, 'Vivriers'),
    (Icons.set_meal_outlined, 'Poisson'),
    (Icons.local_florist_outlined, 'Légumes'),
    (Icons.apple_outlined, 'Fruits'),
    (Icons.shopping_bag_outlined, 'Épicerie'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGuest = ref.watch(isGuestProvider);
    final profile = isGuest ? null : ref.watch(currentProfileProvider).value;
    final name = profile?.displayName ?? (isGuest ? 'Visiteur' : 'Utilisateur');

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _Header(name: name, initial: name.characters.first.toUpperCase()),
            const SizedBox(height: 20),
            const _SearchBar(),
            const SizedBox(height: 24),
            _SectionTitle('Catégories'),
            const SizedBox(height: 12),
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => _CategoryChip(
                  icon: _categories[i].$1,
                  label: _categories[i].$2,
                ).animate().fadeIn(delay: (i * 70).ms).slideX(
                      begin: 0.3,
                      end: 0,
                      duration: 350.ms,
                      curve: Curves.easeOut,
                    ),
              ),
            ),
            const SizedBox(height: 24),
            const _PromoBanner()
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.12, end: 0, curve: Curves.easeOut),
            const SizedBox(height: 24),
            _SectionTitle('Explorer'),
            const SizedBox(height: 12),
            _ShortcutCard(
              icon: Icons.storefront,
              title: 'Ma boutique & produits',
              subtitle: 'Crée ta boutique, gère ton stock',
              onTap: onOpenShop,
            ),
            const _ShortcutCard(
              icon: Icons.search,
              title: 'Catalogue & recherche',
              subtitle: 'Bientôt disponible',
              locked: true,
            ),
            const _ShortcutCard(
              icon: Icons.bolt_outlined,
              title: 'Demande instantanée',
              subtitle: 'Bientôt disponible',
              locked: true,
            ),
            const _ShortcutCard(
              icon: Icons.event_available_outlined,
              title: 'Réservation avec acompte',
              subtitle: 'Bientôt disponible',
              locked: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name, required this.initial});
  final String name;
  final String initial;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bonjour 👋',
                  style: TextStyle(color: AppColors.body, fontSize: 13)),
              const SizedBox(height: 2),
              Text(name,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const ThemeToggleButton(),
        CircleAvatar(
          backgroundColor: AppColors.green,
          child: Text(initial, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catalogue & recherche — bientôt (étape 4)')),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.body),
            const SizedBox(width: 12),
            Text('Rechercher un produit, une boutique…',
                style: TextStyle(color: AppColors.body)),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold));
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: AppColors.green.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, color: AppColors.green),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.orange, Color(0xFFF7B733)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Demande instantanée',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text('Publie ton besoin, les commerçants répondent en direct.',
                    style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.bolt, color: Colors.white, size: 44),
        ],
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.locked = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: (locked ? AppColors.body : AppColors.green)
                .withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: locked ? AppColors.body : AppColors.green),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: Icon(
          locked ? Icons.lock_clock : Icons.chevron_right,
          color: locked ? AppColors.body : null,
        ),
        enabled: !locked,
        onTap: locked
            ? null
            : (onTap ??
                () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bientôt disponible')),
                    )),
      ),
    );
  }
}
