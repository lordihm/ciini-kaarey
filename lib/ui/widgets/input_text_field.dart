import 'package:flutter/material.dart';

import '../../core/calculators/abjad_calculator.dart';
import '../../core/models/khatim_dimension.dart';

/// Champ de saisie du texte arabe + choix du système + aperçu du PM.
class InputTextField extends StatelessWidget {
  const InputTextField({
    super.key,
    required this.controller,
    required this.abjadSystem,
    required this.onSystemChanged,
    this.preview,
  });

  final TextEditingController controller;
  final AbjadSystem abjadSystem;
  final ValueChanged<AbjadSystem> onSystemChanged;
  final AbjadResult? preview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Directionality(
          textDirection: TextDirection.rtl,
          child: TextField(
            controller: controller,
            textAlign: TextAlign.right,
            style: theme.textTheme.headlineSmall,
            decoration: const InputDecoration(
              labelText: 'Texte en arabe',
              hintText: 'مثال: لطيف',
              prefixIcon: Icon(Icons.translate),
            ),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<AbjadSystem>(
          value: abjadSystem,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Système de comput',
            prefixIcon: Icon(Icons.calculate),
          ),
          items: [
            for (final s in AbjadSystem.values)
              DropdownMenuItem(value: s, child: Text(s.labelFr)),
          ],
          onChanged: (v) {
            if (v != null) onSystemChanged(v);
          },
        ),
        if (preview != null) ...[
          const SizedBox(height: 12),
          if (preview!.isSuccess)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PM calculé : ${preview!.weight}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.tertiary,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 4),
                  Text(
                    preview!.breakdown
                        .map((e) => '${e.letter}=${e.value}')
                        .join('  +  '),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            )
          else
            Text(
              preview!.error ?? '',
              style: TextStyle(color: theme.colorScheme.error),
            ),
        ],
      ],
    );
  }
}
