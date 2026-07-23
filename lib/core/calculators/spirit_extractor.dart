import '../models/khatim_characteristics.dart';
import '../models/spirit.dart';
import 'abjad_calculator.dart';

/// Extraction des noms d'esprits-servants (RAWHÂN).
///
/// - Céleste : valeur − 51 → lettres Abjad + suffixe ياءيل (YÂ-ÎL).
/// - Terrestre : valeur (+360×k si besoin) − 1019 → lettres + suffixe طيش (ṪÎSH).
class SpiritExtractor {
  SpiritExtractor._();

  static const int celestialConstant = 51;
  static const int terrestrialConstant = 1019;
  static const int circularCycle = 360;

  static const String celestialSuffixAr = 'ياءيل';
  static const String terrestrialSuffixAr = 'طيش';
  static const String celestialSuffixLatin = 'YÂ-ÎL';
  static const String terrestrialSuffixLatin = 'ṪÎSH';

  static Spirit extractCelestial(int value) {
    // Si la valeur est trop petite pour soustraire 51, on ajoute des
    // révolutions de 360 (même principe que pour l'esprit terrestre).
    var working = value;
    var revolutions = 0;
    while (working <= celestialConstant) {
      working += circularCycle;
      revolutions++;
    }
    final remainder = working - celestialConstant;
    final letters = AbjadCalculator.numberToArabicLetters(remainder);
    return Spirit(
      name: letters + celestialSuffixAr,
      transliteration: _transliterate(letters) + celestialSuffixLatin,
      type: SpiritType.celestial,
      value: value,
      revolutionsAdded: revolutions,
    );
  }

  static Spirit extractTerrestrial(int value) {
    var working = value;
    var revolutions = 0;
    while (working < terrestrialConstant) {
      working += circularCycle;
      revolutions++;
    }
    final remainder = working - terrestrialConstant;
    final letters = AbjadCalculator.numberToArabicLetters(remainder);
    return Spirit(
      name: letters + terrestrialSuffixAr,
      transliteration: _transliterate(letters) + terrestrialSuffixLatin,
      type: SpiritType.terrestrial,
      value: value,
      revolutionsAdded: revolutions,
    );
  }

  static SpiritPair extractPair(String label, int value) => SpiritPair(
        sourceLabel: label,
        sourceValue: value,
        celestial: extractCelestial(value),
        terrestrial: extractTerrestrial(value),
      );

  static List<SpiritPair> extractFromCharacteristics(KhatimCharacteristics c) =>
      c.asList().map((e) => extractPair(e.label, e.value)).toList();

  /// Cas particulier du Mourabba (4×4) : couplage par colonnes,
  /// de la droite vers la gauche (méthode 1 du document).
  static List<CoupledSpirit> extractMourabbaColumnCoupling(List<List<int>> g) {
    if (g.length != 4) {
      throw ArgumentError('Le couplage Mourabba s\'applique au 4×4.');
    }
    final result = <CoupledSpirit>[];

    // Esprits terrestres : couples (3/1) puis (4/2) par colonne, droite→gauche.
    for (var c = 3; c >= 0; c--) {
      result.add(_couple('Col.${c + 1} terrestres (3/1)', g[2][c], g[0][c],
          SpiritType.terrestrial));
      result.add(_couple('Col.${c + 1} terrestres (4/2)', g[3][c], g[1][c],
          SpiritType.terrestrial));
    }
    // Esprits célestes : couples (2/1) puis (4/3) par colonne, droite→gauche.
    for (var c = 3; c >= 0; c--) {
      result.add(_couple('Col.${c + 1} célestes (2/1)', g[1][c], g[0][c],
          SpiritType.celestial));
      result.add(_couple('Col.${c + 1} célestes (4/3)', g[3][c], g[2][c],
          SpiritType.celestial));
    }
    return result;
  }

  static CoupledSpirit _couple(
    String label,
    int first,
    int second,
    SpiritType type,
  ) {
    final a = AbjadCalculator.numberToArabicLetters(first);
    final b = AbjadCalculator.numberToArabicLetters(second);
    final combined = a + b;
    final name = type == SpiritType.celestial ? '$combinedائيل' : combined;
    final latin = _transliterate(combined) +
        (type == SpiritType.celestial ? 'Â-ÎLOU' : 'OUN');
    return CoupledSpirit(
      label: label,
      first: first,
      second: second,
      name: name,
      transliteration: latin,
      type: type,
    );
  }

  static const Map<String, String> _translit = {
    'ا': 'A', 'ب': 'B', 'ج': 'J', 'د': 'D', 'ه': 'H', 'و': 'W', 'ز': 'Z',
    'ح': 'Ḥ', 'ط': 'Ṭ', 'ي': 'Y', 'ك': 'K', 'ل': 'L', 'م': 'M', 'ن': 'N',
    'س': 'S', 'ع': '‘', 'ف': 'F', 'ص': 'Ṣ', 'ق': 'Q', 'ر': 'R', 'ش': 'SH',
    'ت': 'T', 'ث': 'TH', 'خ': 'KH', 'ذ': 'DH', 'ض': 'Ḍ', 'ظ': 'Ẓ', 'غ': 'GH',
  };

  static String _transliterate(String arabic) =>
      arabic.split('').map((c) => _translit[c] ?? c).join();
}
