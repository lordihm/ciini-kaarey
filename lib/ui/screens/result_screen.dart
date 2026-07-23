import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/khatim.dart';
import '../../core/models/khatim_dimension.dart';
import '../../services/export_service.dart';
import '../providers/khatim_provider.dart';
import '../widgets/characteristics_display.dart';
import '../widgets/khatim_grid.dart';
import '../widgets/spirits_display.dart';

/// Écran de résultat : génère (en isolate) puis affiche le Khatim.
class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.dimension,
    required this.method,
    required this.pm,
    this.sourceText,
    this.abjadSystem,
  });

  final KhatimDimension dimension;
  final ConstructionMethod method;
  final int pm;
  final String? sourceText;
  final AbjadSystem? abjadSystem;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  Khatim? _khatim;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _generate());
  }

  Future<void> _generate() async {
    final provider = context.read<KhatimProvider>();
    final result = await provider.generateKhatim(
      pm: widget.pm,
      dimension: widget.dimension,
      method: widget.method,
      sourceText: widget.sourceText,
      abjadSystem: widget.abjadSystem,
    );
    if (!mounted) return;
    setState(() {
      _khatim = result;
      _error = result == null ? provider.errorMessage : null;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat du Khatim'),
        actions: [
          if (_khatim != null) ...[
            IconButton(
              tooltip: 'Partager',
              icon: const Icon(Icons.share),
              onPressed: () => ExportService.shareText(_khatim!),
            ),
            IconButton(
              tooltip: 'Imprimer / PDF',
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () => ExportService.printPdf(_khatim!),
            ),
          ],
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null || _khatim == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 12),
              Text(_error ?? 'Erreur lors de la génération.',
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
      );
    }

    final k = _khatim!;
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _card(
            context,
            'Khatim — ${k.dimension.displayLabel}',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PM=${k.pm} · Entrée=${k.entry} · Sortie=${k.exit} · '
                  'Reste=${k.remainder}',
                  style: theme.textTheme.bodySmall,
                ),
                Text('Méthode : ${k.method.labelFr}',
                    style: theme.textTheme.bodySmall),
                if (k.sourceText != null)
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text('النص : ${k.sourceText}',
                        style: theme.textTheme.bodyMedium),
                  ),
                const SizedBox(height: 12),
                KhatimGrid(grid: k.grid),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _card(context, 'Caractéristiques', CharacteristicsDisplay(khatim: k)),
          const SizedBox(height: 16),
          _card(context, 'Esprits-servants (Rawhân)', SpiritsDisplay(khatim: k)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => ExportService.sharePdf(k),
                  icon: const Icon(Icons.file_download),
                  label: const Text('Exporter PDF'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => ExportService.shareText(k),
                  icon: const Icon(Icons.share),
                  label: const Text('Partager'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, String title, Widget child) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: theme.textTheme.titleLarge
                    ?.copyWith(color: theme.colorScheme.primary)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
