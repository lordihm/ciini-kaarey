import 'package:flutter/material.dart';

import '../../core/models/khatim_dimension.dart';

/// Sélecteur de dimension via menu déroulant + description.
class DimensionSelector extends StatelessWidget {
  const DimensionSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final KhatimDimension value;
  final ValueChanged<KhatimDimension> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<KhatimDimension>(
          value: value,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Type de Khatim',
            prefixIcon: Icon(Icons.grid_on),
          ),
          items: [
            for (final d in KhatimDimension.values)
              DropdownMenuItem(
                value: d,
                child: Text('${d.frenchName} · ${d.size}',
                    overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.auto_awesome,
                  size: 18, color: theme.colorScheme.tertiary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${value.arabicName} — Planète : ${value.planet}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.tertiary,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(height: 4),
                    Text(value.usageSummary, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
