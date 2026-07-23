import 'package:flutter/material.dart';

import '../../core/models/khatim.dart';
import '../../core/models/spirit.dart';

/// Affiche les noms d'esprits-servants (célestes et terrestres).
class SpiritsDisplay extends StatelessWidget {
  const SpiritsDisplay({super.key, required this.khatim});

  final Khatim khatim;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Céleste (علوي) : valeur − 51 + ياءيل   •   '
          'Terrestre (سفلي) : (−1019, +360 si besoin) + طيش',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        for (final pair in khatim.spiritPairs) _pairCard(theme, pair),
        if (khatim.coupledSpirits.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Couplage Mourabba (par colonnes)',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          _coupledSection(theme),
        ],
      ],
    );
  }

  Widget _pairCard(ThemeData theme, SpiritPair pair) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${pair.sourceLabel} = ${pair.sourceValue}',
              style: theme.textTheme.titleSmall),
          const SizedBox(height: 6),
          _spiritLine(theme, 'علوي', pair.celestial),
          _spiritLine(theme, 'سفلي', pair.terrestrial),
        ],
      ),
    );
  }

  Widget _spiritLine(ThemeData theme, String tag, Spirit spirit) {
    final revNote = spirit.revolutionsAdded > 0
        ? '  (+${spirit.revolutionsAdded}×360)'
        : '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              '$tag : ${spirit.name}$revNote',
              textAlign: TextAlign.right,
              style: theme.textTheme.titleMedium,
            ),
          ),
          Text(spirit.transliteration,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              )),
        ],
      ),
    );
  }

  Widget _coupledSection(ThemeData theme) {
    final terrestrial =
        khatim.coupledSpirits.where((s) => s.type == SpiritType.terrestrial);
    final celestial =
        khatim.coupledSpirits.where((s) => s.type == SpiritType.celestial);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Esprits terrestres (سفلي)',
            style: theme.textTheme.labelLarge
                ?.copyWith(color: theme.colorScheme.tertiary)),
        for (final s in terrestrial)
          Text('${s.first}/${s.second} → ${s.name}  (${s.transliteration})',
              style: theme.textTheme.bodySmall),
        const SizedBox(height: 8),
        Text('Esprits célestes (علوي)',
            style: theme.textTheme.labelLarge
                ?.copyWith(color: theme.colorScheme.secondary)),
        for (final s in celestial)
          Text('${s.first}/${s.second} → ${s.name}  (${s.transliteration})',
              style: theme.textTheme.bodySmall),
      ],
    );
  }
}
