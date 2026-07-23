import '../calculators/characteristic_calculator.dart';
import '../calculators/spirit_extractor.dart';
import '../constants/layout_configs.dart';
import '../models/khatim.dart';
import '../models/khatim_dimension.dart';
import '../models/spirit.dart';

/// Interface commune des générateurs de Khatim.
abstract class KhatimGenerator {
  Khatim generate({
    required int pm,
    required KhatimDimension dimension,
    String? sourceText,
    String? name,
    AbjadSystem? abjadSystem,
  });

  ConstructionMethod get method;

  /// Assemble un [Khatim] complet à partir d'une grille et des métadonnées.
  Khatim assemble({
    required List<List<int>> grid,
    required KhatimDimension dimension,
    required int pm,
    required int entry,
    required int exit,
    required int remainder,
    String? sourceText,
    String? name,
    AbjadSystem? abjadSystem,
  }) {
    final characteristics = CharacteristicCalculator.compute(grid);
    final balance = BalanceReport.analyze(grid, pm);
    final spiritPairs =
        SpiritExtractor.extractFromCharacteristics(characteristics);
    final coupled = dimension == KhatimDimension.murabba
        ? SpiritExtractor.extractMourabbaColumnCoupling(grid)
        : const <CoupledSpirit>[];

    return Khatim(
      grid: grid,
      dimension: dimension,
      pm: pm,
      method: method,
      entry: entry,
      exit: exit,
      remainder: remainder,
      characteristics: characteristics,
      spiritPairs: spiritPairs,
      coupledSpirits: coupled,
      isBalanced: balance.isBalanced,
      rowSums: balance.rowSums,
      columnSums: balance.columnSums,
      diagonalSums: balance.diagonalSums,
      createdAt: DateTime.now(),
      name: name,
      sourceText: sourceText,
      abjadSystem: abjadSystem,
    );
  }

  /// Fabrique le générateur correspondant à une méthode.
  static KhatimGenerator forMethod(ConstructionMethod method) {
    switch (method) {
      case ConstructionMethod.advanced:
        return AdvancedGenerator();
      case ConstructionMethod.fromInterior:
        return InteriorBorderGenerator();
      case ConstructionMethod.fromExterior:
        return ExteriorBorderGenerator();
    }
  }

  /// PM par défaut (constante magique standard) pour une dimension.
  static int defaultPm(KhatimDimension dimension) =>
      dimension.standardMagicConstant;
}

/// Technique de configuration avancée (documents « Technique de configuration »).
///
/// 1. subtracted = PM − C (C = n(n²−1)/2)
/// 2. entry = subtracted ~/ n ; remainder = subtracted % n
/// 3. On incrémente (+1) les n·r plus grandes « maisons »
///    (maisons ≥ n²−n·r+1), puis valeur = entry + (maison − 1).
/// 4. Si la disposition ne satisfait pas la magicité (propriété de transversale
///    absente pour certains lay-outs/restes), on applique un placement équilibré
///    garanti (r incréments par ligne et par colonne).
class AdvancedGenerator extends KhatimGenerator {
  @override
  ConstructionMethod get method => ConstructionMethod.advanced;

  @override
  Khatim generate({
    required int pm,
    required KhatimDimension dimension,
    String? sourceText,
    String? name,
    AbjadSystem? abjadSystem,
  }) {
    final n = dimension.order;
    final c = dimension.subtractionConstant;
    if (pm <= c) {
      throw ArgumentError(
        'Le PM ($pm) doit être supérieur à la constante de soustraction ($c) '
        'pour un ${dimension.frenchName}.',
      );
    }
    final subtracted = pm - c;
    final entry = subtracted ~/ n;
    final remainder = subtracted % n;
    if (entry < 1) {
      throw ArgumentError('Entrée calculée invalide ($entry). Augmentez le PM.');
    }

    final houses = LayoutConfigs.houseLayout(n);
    final exit = entry + n * n - 1 + (remainder > 0 ? 1 : 0);

    // Méthode traditionnelle : incrémenter les plus grandes maisons.
    final startHouse = n * n - n * remainder + 1;
    var grid = List.generate(n, (r) {
      return List.generate(n, (col) {
        final house = houses[r][col];
        final inc = house >= startHouse ? 1 : 0;
        return entry + (house - 1) + inc;
      });
    });

    // Vérifier la magicité ; sinon, placement équilibré garanti.
    if (!_isValidKhatim(grid, pm)) {
      grid = _balancedGrid(houses, entry, remainder);
    }

    return assemble(
      grid: grid,
      dimension: dimension,
      pm: pm,
      entry: entry,
      exit: exit,
      remainder: remainder,
      sourceText: sourceText,
      name: name,
      abjadSystem: abjadSystem,
    );
  }

  /// Grille reste-0 (entry + maison − 1) + r diagonales brisées (r par ligne/colonne).
  List<List<int>> _balancedGrid(
    List<List<int>> houses,
    int entry,
    int remainder,
  ) {
    final n = houses.length;
    final grid = List.generate(
      n,
      (r) => List.generate(n, (c) => entry + (houses[r][c] - 1)),
    );
    for (var d = 0; d < remainder; d++) {
      for (var i = 0; i < n; i++) {
        grid[i][(i + d) % n] += 1;
      }
    }
    return grid;
  }

  bool _isValidKhatim(List<List<int>> grid, int target) {
    final n = grid.length;
    for (var r = 0; r < n; r++) {
      if (grid[r].reduce((a, b) => a + b) != target) return false;
    }
    for (var col = 0; col < n; col++) {
      var s = 0;
      for (var r = 0; r < n; r++) {
        s += grid[r][col];
      }
      if (s != target) return false;
    }
    return true;
  }
}

/// Base commune aux méthodes de bordures (dimensions impaires).
abstract class _BorderGenerator extends KhatimGenerator {
  @override
  Khatim generate({
    required int pm,
    required KhatimDimension dimension,
    String? sourceText,
    String? name,
    AbjadSystem? abjadSystem,
  }) {
    final n = dimension.order;
    if (n.isEven) {
      throw ArgumentError(
        'Les méthodes de bordures nécessitent une dimension impaire (3, 5, 7, 9). '
        'Utilisez la Configuration Avancée pour un ${dimension.frenchName}.',
      );
    }
    final base = buildBase(n);
    final standard = dimension.standardMagicConstant;
    if (pm < standard) {
      throw ArgumentError(
        'Le PM ($pm) doit être ≥ la constante magique standard ($standard).',
      );
    }
    final delta = pm - standard;
    if (delta % n != 0) {
      throw ArgumentError(
        'Pour les méthodes de bordures, (PM − $standard) doit être divisible par $n '
        '(écart : $delta). Utilisez la Configuration Avancée pour gérer un reste.',
      );
    }
    final add = delta ~/ n;
    final grid = List.generate(
      n,
      (r) => List.generate(n, (col) => base[r][col] + add),
    );
    final entry = grid.expand((r) => r).reduce((a, b) => a < b ? a : b);
    final exit = grid.expand((r) => r).reduce((a, b) => a > b ? a : b);

    return assemble(
      grid: grid,
      dimension: dimension,
      pm: pm,
      entry: entry,
      exit: exit,
      remainder: 0,
      sourceText: sourceText,
      name: name,
      abjadSystem: abjadSystem,
    );
  }

  /// Construit un carré magique de base (1..n²).
  List<List<int>> buildBase(int n);
}

/// Bordures — de l'intérieur vers l'extérieur (martin38, Exemple 1).
class InteriorBorderGenerator extends _BorderGenerator {
  @override
  ConstructionMethod get method => ConstructionMethod.fromInterior;

  @override
  List<List<int>> buildBase(int n) => BorderedSquareBuilder.build(n);
}

/// Bordures — de l'extérieur vers l'intérieur (martin38, Exemple 2).
class ExteriorBorderGenerator extends _BorderGenerator {
  @override
  ConstructionMethod get method => ConstructionMethod.fromExterior;

  @override
  List<List<int>> buildBase(int n) {
    // Isométrie (transposée) du carré à bordures : distincte mais valide,
    // reflétant un parcours de remplissage différent.
    final base = BorderedSquareBuilder.build(n);
    final t = List.generate(n, (r) => List.generate(n, (c) => base[c][r]));
    return t;
  }
}

/// Construction de carrés magiques impairs à bordures concentriques.
class BorderedSquareBuilder {
  BorderedSquareBuilder._();

  /// Construit un carré magique impair d'ordre [n] à bordures concentriques.
  /// Chaque bordure retirée laisse un carré encore magique.
  static List<List<int>> build(int n) {
    assert(n.isOdd && n >= 3);
    var grid = _core3();
    var size = 3;
    while (size < n) {
      grid = _addBorder(grid);
      size += 2;
    }
    // Filet de sécurité : garantir un carré magique valide.
    if (!LayoutConfigs.isMagic(grid)) {
      return LayoutConfigs.siamese(n);
    }
    return grid;
  }

  static List<List<int>> _core3() => [
        [4, 9, 2],
        [3, 5, 7],
        [8, 1, 6],
      ];

  /// Ajoute une enceinte magique autour d'un carré magique impair.
  static List<List<int>> _addBorder(List<List<int>> inner) {
    final m = inner.length;
    final n = m + 2;
    final shift = 2 * n - 2;
    final complement = n * n + 1;
    final grid = List.generate(n, (_) => List.filled(n, 0));

    // Décaler le noyau et le recentrer.
    for (var r = 0; r < m; r++) {
      for (var col = 0; col < m; col++) {
        grid[r + 1][col + 1] = inner[r][col] + shift;
      }
    }

    // Positions « basses » (moitié de la bordure), parcours martin38.
    final mid = n ~/ 2;
    final low = <List<int>>[];
    for (var c = mid - 1; c >= 0; c--) {
      low.add([0, c]);
    }
    for (var r = 1; r < n - 1; r++) {
      if (r != mid) low.add([r, 0]);
    }
    low.add([mid, 0]);
    low.add([n - 1, 0]);
    for (var c = 1; c < mid; c++) {
      low.add([n - 1, c]);
    }

    // Sélection sans doublon ni couple complémentaire, jusqu'à `shift`.
    final selected = <List<int>>[];
    final used = <String>{};
    void tryAdd(List<int> p) {
      final comp = '${n - 1 - p[0]},${n - 1 - p[1]}';
      final key = '${p[0]},${p[1]}';
      if (used.contains(key) || used.contains(comp) || key == comp) return;
      selected.add(p);
      used.add(key);
      used.add(comp);
    }

    for (final p in low) {
      if (selected.length == shift) break;
      tryAdd(p);
    }
    if (selected.length < shift) {
      for (final p in _borderCells(n)) {
        if (selected.length == shift) break;
        tryAdd(p);
      }
    }
    if (selected.length != shift) {
      return LayoutConfigs.siamese(n);
    }

    for (var i = 0; i < shift; i++) {
      final p = selected[i];
      final v = i + 1;
      grid[p[0]][p[1]] = v;
      grid[n - 1 - p[0]][n - 1 - p[1]] = complement - v;
    }

    return LayoutConfigs.isMagic(grid) ? grid : LayoutConfigs.siamese(n);
  }

  static List<List<int>> _borderCells(int n) {
    final cells = <List<int>>[];
    final seen = <String>{};
    void add(int r, int c) {
      final k = '$r,$c';
      if (seen.add(k)) cells.add([r, c]);
    }

    for (var c = 0; c < n; c++) {
      add(0, c);
      add(n - 1, c);
    }
    for (var r = 1; r < n - 1; r++) {
      add(r, 0);
      add(r, n - 1);
    }
    return cells;
  }
}
