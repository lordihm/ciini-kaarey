import 'package:flutter/foundation.dart';

import '../../core/models/khatim.dart';
import '../../services/storage_service.dart';

/// Historique des Khatim générés (persisté via [StorageService]).
class HistoryProvider extends ChangeNotifier {
  HistoryProvider(this._storage) {
    _history = _storage.loadHistory();
  }

  final StorageService _storage;
  List<Khatim> _history = [];

  List<Khatim> get history => List.unmodifiable(_history);

  Future<void> refresh() async {
    _history = _storage.loadHistory();
    notifyListeners();
  }

  Future<void> add(Khatim khatim) async {
    await _storage.saveKhatim(khatim);
    await refresh();
  }

  Future<void> remove(Khatim khatim) async {
    await _storage.deleteKhatim(khatim.createdAt);
    await refresh();
  }

  Future<void> clear() async {
    await _storage.clearHistory();
    await refresh();
  }
}
