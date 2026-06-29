import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/primary_button.dart';
import '../../catalog/domain/catalog_product.dart';
import '../data/reservations_repository.dart';

/// Écran de réservation : quantité + échéance, calcul de l'acompte (30 %) et
/// du solde, puis paiement simulé.
class ReserveScreen extends ConsumerStatefulWidget {
  const ReserveScreen({super.key, required this.product});
  final CatalogProduct product;

  @override
  ConsumerState<ReserveScreen> createState() => _ReserveScreenState();
}

class _ReserveScreenState extends ConsumerState<ReserveScreen> {
  double _qty = 1;
  int _deadlineHours = 48;
  bool _loading = false;

  static const _deadlines = <(String, int)>[
    ('24 h', 24),
    ('2 j', 48),
    ('3 j', 72),
  ];

  CatalogProduct get _p => widget.product;
  double get _total => _p.price * _qty;
  double get _deposit => (_total * kDepositRate).roundToDouble();
  double get _balance => _total - _deposit;

  Future<void> _pay() async {
    if (_qty < 1 || _qty > _p.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quantité invalide (stock : ${formatQty(_p.stock)}).')),
      );
      return;
    }
    // Paiement simulé de l'acompte.
    final ok = await context.push<bool>(
      AppRoutes.payment,
      extra: (_deposit, 'Acompte — ${_p.name}'),
    );
    if (ok != true || !mounted) return;

    setState(() => _loading = true);
    try {
      await ref.read(reservationsRepositoryProvider).reserveProduct(
            productId: _p.id,
            quantity: _qty,
            deadline: DateTime.now().add(Duration(hours: _deadlineHours)),
          );
      ref.invalidate(myReservationsProvider);
      if (!mounted) return;
      context.pushReplacement(AppRoutes.reservations);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxQty = _p.stock < 1 ? 1.0 : _p.stock;
    return Scaffold(
      appBar: AppBar(title: const Text('Réserver')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(_p.name,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          Text('${_p.shopName} · ${formatFcfa(_p.price)} / ${_p.unit}',
              style: const TextStyle(color: AppColors.body)),
          const SizedBox(height: 24),

          // Quantité
          Text('Quantité : ${formatQty(_qty)} ${_p.unit}',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: _qty > 1 ? () => setState(() => _qty -= 1) : null,
                icon: const Icon(Icons.remove),
              ),
              Expanded(
                child: Slider(
                  value: _qty.clamp(1, maxQty),
                  min: 1,
                  max: maxQty,
                  divisions: maxQty > 1 ? (maxQty - 1).toInt().clamp(1, 100) : 1,
                  activeColor: AppColors.clay,
                  label: formatQty(_qty),
                  onChanged: (v) => setState(() => _qty = v.roundToDouble()),
                ),
              ),
              IconButton.filledTonal(
                onPressed:
                    _qty < maxQty ? () => setState(() => _qty += 1) : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Échéance de retrait
          const Text('Échéance de retrait',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: [
              for (final d in _deadlines)
                ChoiceChip(
                  label: Text(d.$1),
                  selected: _deadlineHours == d.$2,
                  onSelected: (_) => setState(() => _deadlineHours = d.$2),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Récapitulatif
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _row('Total', formatFcfa(_total)),
                  const SizedBox(height: 8),
                  _row('Acompte (30 %)', formatFcfa(_deposit), accent: true),
                  const Divider(height: 20),
                  _row('Solde au retrait', formatFcfa(_balance), muted: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Annulation possible jusqu\'à 12 h avant l\'échéance '
            '(remboursement de l\'acompte).',
            style: TextStyle(color: AppColors.body, fontSize: 12),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Payer l\'acompte ${formatFcfa(_deposit)}',
            icon: Icons.lock,
            gradient: true,
            loading: _loading,
            onPressed: _pay,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value,
      {bool accent = false, bool muted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(color: muted ? AppColors.body : null)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: accent ? 18 : 15,
            color: accent ? AppColors.clay : (muted ? AppColors.body : null),
          ),
        ),
      ],
    );
  }
}
