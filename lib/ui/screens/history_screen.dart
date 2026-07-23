import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/khatim.dart';
import '../../utils/formatters.dart';
import '../providers/history_provider.dart';
import '../widgets/khatim_grid.dart';
import 'result_screen.dart';

/// Historique des Khatim générés.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
        actions: [
          Consumer<HistoryProvider>(
            builder: (context, provider, _) => provider.history.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: 'Tout effacer',
                    icon: const Icon(Icons.delete_sweep),
                    onPressed: () => _confirmClear(context, provider),
                  ),
          ),
        ],
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, provider, _) {
          final items = provider.history;
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Aucun Khatim enregistré pour le moment.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) => _tile(context, provider, items[i]),
          );
        },
      ),
    );
  }

  Widget _tile(BuildContext context, HistoryProvider provider, Khatim k) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: SizedBox(
          width: 56,
          height: 56,
          child: KhatimGrid(grid: k.grid, highlightMinMax: false),
        ),
        title: Text('${k.dimension.frenchName} · ${k.dimension.size}',
            style: theme.textTheme.titleMedium),
        subtitle: Text(
          'PM ${k.pm} · ${k.method.labelFr}\n${Formatters.dateTime(k.createdAt)}',
          style: theme.textTheme.bodySmall,
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => provider.remove(k),
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              dimension: k.dimension,
              method: k.method,
              pm: k.pm,
              sourceText: k.sourceText,
              abjadSystem: k.abjadSystem,
            ),
          ),
        ),
      ),
    );
  }

  void _confirmClear(BuildContext context, HistoryProvider provider) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Effacer l\'historique ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              provider.clear();
              Navigator.pop(ctx);
            },
            child: const Text('Effacer'),
          ),
        ],
      ),
    );
  }
}
