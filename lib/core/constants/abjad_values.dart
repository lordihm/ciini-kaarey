import '../models/khatim_dimension.dart';

/// Tables Abjad (حساب الجمل) — systèmes occidental (maghrébin) et oriental (mashriqi).
///
/// Différences sur : ص، ض، س، ش، ظ، غ (les six lettres « rawâdif »).
class AbjadValues {
  AbjadValues._();

  /// Valeurs partagées par les deux systèmes (unités, dizaines, centaines de base).
  static const Map<String, int> _shared = {
    'ا': 1, 'ب': 2, 'ج': 3, 'د': 4, 'ه': 5, 'و': 6, 'ز': 7, 'ح': 8, 'ط': 9,
    'ي': 10, 'ك': 20, 'ل': 30, 'م': 40, 'ن': 50, 'ع': 70, 'ف': 80,
    'ق': 100, 'ر': 200, 'ت': 400, 'ث': 500, 'خ': 600, 'ذ': 700,
  };

  /// Comput oriental (mashriqi).
  static const Map<String, int> orientalExtra = {
    'س': 60, 'ص': 90, 'ش': 300, 'ض': 800, 'ظ': 900, 'غ': 1000,
  };

  /// Comput occidental (maghrébin) — utilisé pour les noms d'esprits.
  static const Map<String, int> occidentalExtra = {
    'ص': 60, 'ض': 90, 'س': 300, 'ظ': 800, 'غ': 900, 'ش': 1000,
  };

  static Map<String, int> tableFor(AbjadSystem system) => {
        ..._shared,
        ...(system == AbjadSystem.oriental ? orientalExtra : occidentalExtra),
      };

  /// Valeur d'une lettre normalisée pour un système donné (null si inconnue).
  static int? valueOf(String letter, AbjadSystem system) =>
      tableFor(system)[letter];
}
