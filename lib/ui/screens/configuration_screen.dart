import 'package:flutter/material.dart';

import '../../core/calculators/abjad_calculator.dart';
import '../../core/models/khatim_dimension.dart';
import '../../utils/validators.dart';
import '../widgets/dimension_selector.dart';
import '../widgets/input_text_field.dart';
import '../widgets/method_selector.dart';
import 'result_screen.dart';

/// Écran de configuration du Khatim (dimension, méthode, PM).
class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({super.key});

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  KhatimDimension _dimension = KhatimDimension.moussala;
  ConstructionMethod _method = ConstructionMethod.advanced;
  AbjadSystem _abjadSystem = AbjadSystem.occidental;
  bool _useManualInput = true;

  final _pmController = TextEditingController(
    text: KhatimDimension.moussala.standardMagicConstant.toString(),
  );
  final _arabicController = TextEditingController();
  AbjadResult? _preview;

  @override
  void dispose() {
    _pmController.dispose();
    _arabicController.dispose();
    super.dispose();
  }

  void _onDimensionChanged(KhatimDimension d) {
    setState(() {
      _dimension = d;
      _pmController.text = d.standardMagicConstant.toString();
      if (d.order.isEven && _method != ConstructionMethod.advanced) {
        _method = ConstructionMethod.advanced;
      }
    });
  }

  void _refreshPreview() {
    final text = _arabicController.text;
    setState(() {
      _preview = text.trim().isEmpty
          ? null
          : AbjadCalculator.calculate(text, system: _abjadSystem);
    });
  }

  void _generate() {
    int? pm;
    if (_useManualInput) {
      final err = Validators.validateManualPm(_pmController.text, _dimension);
      if (err != null) {
        _showError(err);
        return;
      }
      pm = int.parse(_pmController.text.trim());
    } else {
      final err = Validators.validateArabicText(_arabicController.text);
      if (err != null) {
        _showError(err);
        return;
      }
      final result =
          AbjadCalculator.calculate(_arabicController.text, system: _abjadSystem);
      if (!result.isSuccess) {
        _showError(result.error ?? 'Calcul Abjad impossible.');
        return;
      }
      pm = result.weight;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          dimension: _dimension,
          method: _method,
          pm: pm!,
          sourceText: _useManualInput ? null : _arabicController.text.trim(),
          abjadSystem: _useManualInput ? null : _abjadSystem,
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuration du Khatim')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section(
              context,
              '1. Type de Khatim',
              DimensionSelector(
                value: _dimension,
                onChanged: _onDimensionChanged,
              ),
            ),
            const SizedBox(height: 16),
            _section(
              context,
              '2. Méthode de construction',
              MethodSelector(
                value: _method,
                dimension: _dimension,
                onChanged: (m) => setState(() => _method = m),
              ),
            ),
            const SizedBox(height: 16),
            _section(
              context,
              '3. Poids Mystique (PM)',
              Column(
                children: [
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                          value: true,
                          label: Text('Manuel'),
                          icon: Icon(Icons.pin)),
                      ButtonSegment(
                          value: false,
                          label: Text('Abjad'),
                          icon: Icon(Icons.translate)),
                    ],
                    selected: {_useManualInput},
                    onSelectionChanged: (s) =>
                        setState(() => _useManualInput = s.first),
                  ),
                  const SizedBox(height: 16),
                  if (_useManualInput)
                    TextField(
                      controller: _pmController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Poids Mystique',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                    )
                  else
                    InputTextField(
                      controller: _arabicController,
                      abjadSystem: _abjadSystem,
                      onSystemChanged: (s) {
                        setState(() => _abjadSystem = s);
                        _refreshPreview();
                      },
                      preview: _preview,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _generate,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Générer le Khatim'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title, Widget child) {
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
