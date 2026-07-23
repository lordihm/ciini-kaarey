import 'package:flutter/material.dart';

import '../../core/models/khatim.dart';
import '../../utils/extensions.dart';

/// Affiche les 7 caractéristiques d'un Khatim.
class CharacteristicsDisplay extends StatelessWidget {
  const CharacteristicsDisplay({super.key, required this.khatim});

  final Khatim khatim;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = khatim.characteristics.asList();
    final weekday = khatim.characteristics.wafq.mysticalWeekday;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text('${item.label} (${item.arabic})',
                      style: theme.textTheme.bodyMedium),
                ),
                Text('${item.value}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ),
        const Divider(),
        Row(
          children: [
            Icon(Icons.event, size: 18, color: theme.colorScheme.tertiary),
            const SizedBox(width: 8),
            Text('Jour propice (WAFQ ÷ 7) : $weekday',
                style: theme.textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              khatim.isBalanced ? Icons.check_circle : Icons.info_outline,
              size: 18,
              color: khatim.isBalanced
                  ? theme.colorScheme.tertiary
                  : theme.colorScheme.secondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                khatim.isBalanced
                    ? 'Équilibré — lignes et colonnes = ${khatim.characteristics.wafq}'
                    : 'Lignes/colonnes = ${khatim.pm} ; diagonales : '
                        '${khatim.diagonalSums.join(" et ")}',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
