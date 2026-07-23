import '../core/models/khatim_dimension.dart';

/// Validateurs d'entrées utilisateur.
class Validators {
  Validators._();

  /// Valide un PM saisi manuellement.
  static String? validateManualPm(String? value, KhatimDimension dimension) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez saisir un Poids Mystique.';
    }
    final pm = int.tryParse(value.trim());
    if (pm == null) return 'Le PM doit être un nombre entier.';
    if (pm <= 0) return 'Le PM doit être strictement positif.';
    if (pm <= dimension.subtractionConstant) {
      return 'Le PM doit être supérieur à ${dimension.subtractionConstant} '
          'pour un ${dimension.frenchName}.';
    }
    return null;
  }

  /// Valide un texte arabe (au moins une lettre arabe).
  static String? validateArabicText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez saisir un texte arabe.';
    }
    final hasArabic = value.runes.any((r) => r >= 0x0600 && r <= 0x06FF);
    if (!hasArabic) return 'Le texte doit contenir des lettres arabes.';
    return null;
  }
}
