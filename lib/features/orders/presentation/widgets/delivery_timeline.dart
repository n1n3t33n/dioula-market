import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Roadmap verticale de suivi d'un colis : Commande passée → Prise en charge →
/// Livrée. L'avancement est déduit du `status` de la commande (qui peut être
/// alimenté en temps réel par un stream).
class DeliveryTimeline extends StatelessWidget {
  const DeliveryTimeline({super.key, required this.status});

  final String status;

  static const _steps = <(IconData, String, String)>[
    (Icons.receipt_long, 'Commande passée', 'Ta commande a été enregistrée.'),
    (Icons.two_wheeler, 'Prise en charge', 'Un livreur achemine ton colis.'),
    (Icons.home_rounded, 'Livrée', 'Colis remis au client.'),
  ];

  @override
  Widget build(BuildContext context) {
    if (status == 'annulee') {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel_outlined, color: AppColors.danger),
            SizedBox(width: 10),
            Expanded(child: Text('Commande annulée.')),
          ],
        ),
      );
    }

    // Nombre d'étapes franchies.
    final completed = switch (status) {
      'livree' => 3,
      'en_livraison' => 2,
      _ => 1, // en_cours / preparee
    };

    return Column(
      children: [
        for (var i = 0; i < _steps.length; i++)
          _StepRow(
            icon: _steps[i].$1,
            title: _steps[i].$2,
            subtitle: _steps[i].$3,
            done: i < completed,
            current: i == completed && completed < _steps.length,
            isLast: i == _steps.length - 1,
          ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.done,
    required this.current,
    required this.isLast,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool done;
  final bool current;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final active = done || current;
    final nodeColor = done
        ? AppColors.success
        : (current ? AppColors.clay : AppColors.body.withValues(alpha: 0.3));

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colonne nœud + connecteur.
          Column(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: active ? nodeColor : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: nodeColor, width: 2),
                ),
                child: Icon(
                  done ? Icons.check : icon,
                  size: 18,
                  color: active ? Colors.white : nodeColor,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: done
                        ? AppColors.success
                        : AppColors.body.withValues(alpha: 0.25),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          // Texte de l'étape.
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 22, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: active ? AppColors.ink : AppColors.body,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    current ? '$subtitle  •  en cours…' : subtitle,
                    style: const TextStyle(color: AppColors.body, fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
