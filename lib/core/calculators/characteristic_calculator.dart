import '../models/khatim.dart';
import '../models/khatim_characteristics.dart';

/// Calcul des 7 caractéristiques communes d'un Khatim.
class CharacteristicCalculator {
  CharacteristicCalculator._();

  /// Plus petit nombre du carré (Clé / مفتاح).
  static int calculateKey(List<List<int>> grid) =>
      grid.expand((r) => r).reduce((a, b) => a < b ? a : b);

  /// Plus grand nombre du carré (Verrou / مغلاق).
  static int calculateLock(List<List<int>> grid) =>
      grid.expand((r) => r).reduce((a, b) => a > b ? a : b);

  static int calculateMedian(int key, int lock) => key + lock;

  /// Somme d'une colonne (WAFQ / وفق). Utilise la 1ère colonne.
  static int calculateWafq(List<List<int>> grid) {
    var s = 0;
    for (var r = 0; r < grid.length; r++) {
      s += grid[r][0];
    }
    return s;
  }

  /// Somme totale (Aire / مساحة).
  static int calculateArea(List<List<int>> grid) =>
      grid.expand((r) => r).reduce((a, b) => a + b);

  static int calculateForce(int wafq, int area) => wafq + area;

  static int calculateGoal(int force) => force * 2;

  static KhatimCharacteristics compute(List<List<int>> grid) {
    final key = calculateKey(grid);
    final lock = calculateLock(grid);
    final wafq = calculateWafq(grid);
    final area = calculateArea(grid);
    final force = calculateForce(wafq, area);
    return KhatimCharacteristics(
      key: key,
      lock: lock,
      median: calculateMedian(key, lock),
      wafq: wafq,
      area: area,
      force: force,
      goal: calculateGoal(force),
    );
  }
}

/// Analyse de l'équilibre (magicité) d'un carré vis-à-vis du PM cible.
class BalanceReport {
  const BalanceReport({
    required this.rowSums,
    required this.columnSums,
    required this.diagonalSums,
    required this.isBalanced,
    required this.target,
  });

  final List<int> rowSums;
  final List<int> columnSums;
  final List<int> diagonalSums;
  final bool isBalanced;
  final int target;

  static BalanceReport analyze(List<List<int>> grid, int target) {
    final n = grid.length;
    final rowSums = grid.map((r) => r.reduce((a, b) => a + b)).toList();
    final columnSums = List.generate(n, (c) {
      var s = 0;
      for (var r = 0; r < n; r++) {
        s += grid[r][c];
      }
      return s;
    });
    var d1 = 0, d2 = 0;
    for (var i = 0; i < n; i++) {
      d1 += grid[i][i];
      d2 += grid[i][n - 1 - i];
    }
    final balanced =
        rowSums.every((s) => s == target) && columnSums.every((s) => s == target);
    return BalanceReport(
      rowSums: rowSums,
      columnSums: columnSums,
      diagonalSums: [d1, d2],
      isBalanced: balanced,
      target: target,
    );
  }
}

/// Extension pour recalculer les caractéristiques d'un Khatim existant.
extension KhatimCharacteristicsX on Khatim {
  KhatimCharacteristics get recomputedCharacteristics =>
      CharacteristicCalculator.compute(grid);
}
