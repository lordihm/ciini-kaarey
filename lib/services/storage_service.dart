import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/models/khatim.dart';

/// Stockage local des Khatim (historique) et des préférences via SharedPreferences.
class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  static const String _historyKey = 'khatim_history';
  static const String _themeKey = 'theme_mode';
  static const int maxHistory = 100;

  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  Future<void> saveKhatim(Khatim khatim) async {
    final history = loadHistory();
    history.insert(0, khatim);
    if (history.length > maxHistory) {
      history.removeRange(maxHistory, history.length);
    }
    await _persist(history);
  }

  List<Khatim> loadHistory() {
    final raw = _prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => Khatim.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> deleteKhatim(DateTime createdAt) async {
    final history = loadHistory()
      ..removeWhere((k) => k.createdAt == createdAt);
    await _persist(history);
  }

  Future<void> clearHistory() async {
    await _prefs.remove(_historyKey);
  }

  Future<void> _persist(List<Khatim> history) async {
    final raw = jsonEncode(history.map((k) => k.toJson()).toList());
    await _prefs.setString(_historyKey, raw);
  }

  String? get themeMode => _prefs.getString(_themeKey);

  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(_themeKey, mode);
  }
}
