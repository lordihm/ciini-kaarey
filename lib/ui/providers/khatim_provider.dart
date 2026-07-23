import 'package:flutter/foundation.dart';

import '../../core/generators/khatim_generator.dart';
import '../../core/models/khatim.dart';
import '../../core/models/khatim_dimension.dart';
import '../../services/storage_service.dart';

/// Paramètres passés à l'isolate de génération.
class _GenParams {
  const _GenParams({
    required this.pm,
    required this.dimension,
    required this.method,
    this.sourceText,
    this.name,
    this.abjadSystem,
  });

  final int pm;
  final KhatimDimension dimension;
  final ConstructionMethod method;
  final String? sourceText;
  final String? name;
  final AbjadSystem? abjadSystem;
}

/// Fonction exécutée en isolate (via [compute]) pour la génération lourde.
Khatim _generateInIsolate(_GenParams p) {
  final generator = KhatimGenerator.forMethod(p.method);
  return generator.generate(
    pm: p.pm,
    dimension: p.dimension,
    sourceText: p.sourceText,
    name: p.name,
    abjadSystem: p.abjadSystem,
  );
}

/// Gestion d'état de la génération de Khatim (Provider / ChangeNotifier).
class KhatimProvider extends ChangeNotifier {
  KhatimProvider({StorageService? storage}) : _storage = storage;

  final StorageService? _storage;

  Khatim? _current;
  bool _isLoading = false;
  String? _errorMessage;
  String? _infoMessage;

  Khatim? get current => _current;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get infoMessage => _infoMessage;

  void clearMessages() {
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();
  }

  Future<Khatim?> generateKhatim({
    required int pm,
    required KhatimDimension dimension,
    required ConstructionMethod method,
    String? sourceText,
    String? name,
    AbjadSystem? abjadSystem,
    bool saveToHistory = true,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _infoMessage = null;
    notifyListeners();

    try {
      final params = _GenParams(
        pm: pm,
        dimension: dimension,
        method: method,
        sourceText: sourceText,
        name: name,
        abjadSystem: abjadSystem,
      );
      // Génération dans un isolate pour ne pas bloquer l'UI (carrés 9×9…).
      final khatim = await compute(_generateInIsolate, params);

      _current = khatim;
      if (!khatim.isBalanced) {
        _infoMessage = 'Carré généré. Avec un reste non nul, les diagonales '
            'peuvent différer du WAFQ (comportement documenté).';
      }
      if (saveToHistory) {
        await _storage?.saveKhatim(khatim);
      }
      _isLoading = false;
      notifyListeners();
      return khatim;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e is ArgumentError ? e.message.toString() : e.toString();
      notifyListeners();
      return null;
    }
  }
}
