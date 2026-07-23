import 'package:flutter/material.dart';

import '../../core/models/khatim_dimension.dart';

/// Sélecteur de méthode de construction (radios).
class MethodSelector extends StatelessWidget {
  const MethodSelector({
    super.key,
    required this.value,
    required this.dimension,
    required this.onChanged,
  });

  final ConstructionMethod value;
  final KhatimDimension dimension;
  final ValueChanged<ConstructionMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEven = dimension.order.isEven;
    return Column(
      children: [
        for (final m in ConstructionMethod.values)
          _tile(context, theme, m, isEven),
      ],
    );
  }

  Widget _tile(
    BuildContext context,
    ThemeData theme,
    ConstructionMethod m,
    bool isEven,
  ) {
    final disabled = m != ConstructionMethod.advanced && isEven;
    return Opacity(
      opacity: disabled ? 0.45 : 1,
      child: RadioListTile<ConstructionMethod>(
        contentPadding: EdgeInsets.zero,
        value: m,
        groupValue: value,
        onChanged: disabled ? null : (v) => onChanged(v!),
        title: Text(m.labelFr, style: theme.textTheme.titleSmall),
        subtitle: Text(
          disabled
              ? 'Réservé aux dimensions impaires (3, 5, 7, 9).'
              : m.descriptionFr,
          style: theme.textTheme.bodySmall,
        ),
      ),
    );
  }
}
