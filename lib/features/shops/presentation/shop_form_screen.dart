import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/supabase_provider.dart';
import '../domain/shop.dart';
import 'shop_controller.dart';

/// Formulaire de création / édition d'une boutique.
/// [existing] est passé via `context.push(..., extra: shop)` pour l'édition.
class ShopFormScreen extends ConsumerStatefulWidget {
  const ShopFormScreen({super.key, this.existing});
  final Shop? existing;

  @override
  ConsumerState<ShopFormScreen> createState() => _ShopFormScreenState();
}

class _ShopFormScreenState extends ConsumerState<ShopFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _category;
  late final TextEditingController _commune;
  late final TextEditingController _address;
  late final TextEditingController _phone;
  late final TextEditingController _description;
  bool _loading = false;

  bool get _isNew => widget.existing == null;

  @override
  void initState() {
    super.initState();
    final s = widget.existing;
    _name = TextEditingController(text: s?.name ?? '');
    _category = TextEditingController(text: s?.category ?? '');
    _commune = TextEditingController(text: s?.commune ?? '');
    _address = TextEditingController(text: s?.address ?? '');
    _phone = TextEditingController(text: s?.phone ?? '');
    _description = TextEditingController(text: s?.description ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _category.dispose();
    _commune.dispose();
    _address.dispose();
    _phone.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = ref.read(supabaseProvider).auth.currentUser?.id;
    if (uid == null) return;

    setState(() => _loading = true);
    // On part de la boutique existante (pour garder id/owner/géoloc) ou on
    // en crée une nouvelle.
    final shop = (widget.existing ??
            Shop(id: '', ownerId: uid, name: _name.text.trim()))
        .copyWith(
      name: _name.text.trim(),
      category: _category.text.trim(),
      commune: _commune.text.trim(),
      address: _address.text.trim(),
      phone: _phone.text.trim(),
      description: _description.text.trim(),
    );

    final ok =
        await ref.read(shopControllerProvider.notifier).save(shop, isNew: _isNew);
    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isNew ? 'Boutique créée' : 'Boutique mise à jour')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'enregistrement')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(_isNew ? 'Créer ma boutique' : 'Modifier la boutique')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                      labelText: 'Nom de la boutique *',
                      prefixIcon: Icon(Icons.storefront)),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nom requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _category,
                  decoration: const InputDecoration(
                      labelText: 'Catégorie (ex: Vivriers, Épicerie)',
                      prefixIcon: Icon(Icons.category_outlined)),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _commune,
                  decoration: const InputDecoration(
                      labelText: 'Commune (ex: Cocody)',
                      prefixIcon: Icon(Icons.location_city_outlined)),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _address,
                  decoration: const InputDecoration(
                      labelText: 'Adresse',
                      prefixIcon: Icon(Icons.home_outlined)),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                      labelText: 'Téléphone',
                      prefixIcon: Icon(Icons.phone_outlined)),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _description,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.notes_outlined)),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _loading ? null : _save,
                  child: _loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_isNew ? 'Créer' : 'Enregistrer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
