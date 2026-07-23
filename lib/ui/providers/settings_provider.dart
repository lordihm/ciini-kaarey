import 'package:flutter/material.dart';

import '../../services/storage_service.dart';

/// Gestion des préférences (thème clair/sombre/système).
class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._storage) {
    final saved = _storage.themeMode;
    if (saved != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (m) => m.name == saved,
        orElse: () => ThemeMode.system,
      );
    }
  }

  final StorageService _storage;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _storage.setThemeMode(mode.name);
    notifyListeners();
  }

  void cycleTheme() {
    final next = switch (_themeMode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    setThemeMode(next);
  }
}
