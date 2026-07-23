import 'package:flutter/material.dart';

/// Affiche le carré magique dans une grille responsive.
class KhatimGrid extends StatelessWidget {
  const KhatimGrid({
    super.key,
    required this.grid,
    this.highlightMinMax = true,
  });

  final List<List<int>> grid;
  final bool highlightMinMax;

  @override
  Widget build(BuildContext context) {
    final n = grid.length;
    final scheme = Theme.of(context).colorScheme;
    final flat = grid.expand((r) => r);
    final minV = flat.reduce((a, b) => a < b ? a : b);
    final maxV = flat.reduce((a, b) => a > b ? a : b);

    final fontSize = switch (n) {
      >= 9 => 11.0,
      >= 8 => 12.0,
      >= 6 => 14.0,
      _ => 18.0,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: scheme.outline, width: 2),
            borderRadius: BorderRadius.circular(8),
            color: scheme.primary.withOpacity(0.06),
          ),
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var r = 0; r < n; r++)
                Row(
                  children: [
                    for (var c = 0; c < n; c++)
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            margin: const EdgeInsets.all(1.5),
                            decoration: BoxDecoration(
                              color: _cellColor(scheme, grid[r][c], minV, maxV),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: scheme.outline.withOpacity(0.4),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: FittedBox(
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: Text(
                                  '${grid[r][c]}',
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.w600,
                                    color: _textColor(
                                        scheme, grid[r][c], minV, maxV),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Color _cellColor(ColorScheme s, int v, int minV, int maxV) {
    if (!highlightMinMax) return s.surface;
    if (v == minV) return s.tertiary.withOpacity(0.25);
    if (v == maxV) return s.secondary.withOpacity(0.25);
    return s.surface;
  }

  Color _textColor(ColorScheme s, int v, int minV, int maxV) => s.onSurface;
}
