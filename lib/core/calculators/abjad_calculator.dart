import '../constants/abjad_values.dart';
import '../models/khatim_dimension.dart';

/// Résultat détaillé d'un calcul Abjad.
class AbjadResult {
  const AbjadResult({
    required this.weight,
    required this.system,
    required this.breakdown,
    required this.ignored,
    this.error,
  });

  final int weight;
  final AbjadSystem system;
  final List<({String letter, int value})> breakdown;
  final List<String> ignored;
  final String? error;

  bool get isSuccess => error == null && weight > 0;
}

/// Calcul du Poids Mystique (PM) d'un texte arabe via le système Abjad,
/// et conversion inverse nombre → lettres.
class AbjadCalculator {
  AbjadCalculator._();

  /// Calcule le PM d'un texte arabe pour un système donné.
  static AbjadResult calculate(String text, {required AbjadSystem system}) {
    if (text.trim().isEmpty) {
      return AbjadResult(
        weight: 0,
        system: system,
        breakdown: const [],
        ignored: const [],
        error: 'Le texte arabe ne peut pas être vide.',
      );
    }

    final breakdown = <({String letter, int value})>[];
    final ignored = <String>[];
    var sum = 0;
    var hasArabic = false;

    for (final rune in text.runes) {
      final ch = String.fromCharCode(rune);
      if (_isWhitespace(ch) || _isDiacritic(rune) || _isPunctuation(ch)) {
        continue;
      }
      final normalized = _normalize(ch);
      final value = normalized == null
          ? null
          : AbjadValues.valueOf(normalized, system);
      if (value == null || normalized == null) {
        ignored.add(ch);
      } else {
        hasArabic = true;
        sum += value;
        breakdown.add((letter: normalized, value: value));
      }
    }

    if (!hasArabic) {
      return AbjadResult(
        weight: 0,
        system: system,
        breakdown: const [],
        ignored: ignored,
        error: 'Aucune lettre arabe valide détectée.',
      );
    }

    return AbjadResult(
      weight: sum,
      system: system,
      breakdown: breakdown,
      ignored: ignored,
      error: null,
    );
  }

  /// Convertit un nombre en lettres arabes, ordonnées
  /// unités → dizaines → centaines → milliers (ex. 156 → « ونق »).
  static String numberToArabicLetters(
    int number, {
    AbjadSystem system = AbjadSystem.occidental,
  }) {
    if (number <= 0) return '';
    final table = AbjadValues.tableFor(system);
    final entries = table.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final collected = <({String letter, int value})>[];
    var remaining = number;
    for (final e in entries) {
      while (remaining >= e.value) {
        collected.add((letter: e.key, value: e.value));
        remaining -= e.value;
      }
    }

    collected.sort((a, b) {
      int band(int v) => v < 10
          ? 0
          : v < 100
              ? 1
              : v < 1000
                  ? 2
                  : 3;
      final byBand = band(a.value).compareTo(band(b.value));
      return byBand != 0 ? byBand : a.value.compareTo(b.value);
    });

    return collected.map((e) => e.letter).join();
  }

  static String? _normalize(String ch) {
    switch (ch) {
      case 'أ':
      case 'إ':
      case 'آ':
      case 'ٱ':
        return 'ا';
      case 'ؤ':
        return 'و';
      case 'ئ':
        return 'ي';
      case 'ة':
        return 'ه';
      case 'ى':
        return 'ي';
      default:
        final code = ch.runes.first;
        return (code >= 0x0600 && code <= 0x06FF) ? ch : null;
    }
  }

  static bool _isWhitespace(String ch) => ch.trim().isEmpty;

  static bool _isDiacritic(int code) =>
      (code >= 0x064B && code <= 0x065F) || code == 0x0670 || code == 0x0640;

  static bool _isPunctuation(String ch) =>
      '۔،؛؟!.:;,-_/\\"\'()[]{}«»…'.contains(ch);
}
