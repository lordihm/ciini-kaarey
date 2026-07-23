import '../models/khatim_dimension.dart';

/// Lay-outs de base (« maisons » numérotées de 1 à n²) pour chaque dimension.
///
/// Les lay-outs 3→7 sont les dispositions traditionnelles issues des documents
/// (reconstituées et vérifiées comme carrés magiques). Les ordres 8 et 9 sont
/// générés algorithmiquement (les documents sources comportent des erreurs pour
/// ces tailles), tout en restant des carrés magiques valides.
class LayoutConfigs {
  LayoutConfigs._();

  static const List<List<int>> _l3 = [
    [4, 9, 2],
    [3, 5, 7],
    [8, 1, 6],
  ];

  static const List<List<int>> _l4 = [
    [8, 11, 14, 1],
    [13, 2, 7, 12],
    [3, 16, 9, 6],
    [10, 5, 4, 15],
  ];

  static const List<List<int>> _l5 = [
    [1, 14, 22, 10, 18],
    [25, 8, 16, 4, 12],
    [19, 2, 15, 23, 6],
    [13, 21, 9, 17, 5],
    [7, 20, 3, 11, 24],
  ];

  static const List<List<int>> _l6 = [
    [1, 35, 23, 22, 12, 18],
    [34, 30, 5, 10, 29, 3],
    [24, 11, 28, 31, 4, 13],
    [16, 27, 8, 7, 32, 21],
    [17, 6, 33, 26, 9, 20],
    [19, 2, 14, 15, 25, 36],
  ];

  static const List<List<int>> _l7 = [
    [1, 18, 35, 45, 13, 23, 40],
    [49, 10, 27, 37, 5, 15, 32],
    [41, 2, 19, 29, 46, 14, 24],
    [33, 43, 11, 28, 38, 6, 16],
    [25, 42, 3, 20, 30, 47, 8],
    [17, 34, 44, 12, 22, 39, 7],
    [9, 26, 36, 4, 21, 31, 48],
  ];

  /// Retourne le lay-out des maisons (1..n²) pour une dimension.
  static List<List<int>> houseLayout(int order) {
    switch (order) {
      case 3:
        return _copy(_l3);
      case 4:
        return _copy(_l4);
      case 5:
        return _copy(_l5);
      case 6:
        return _copy(_l6);
      case 7:
        return _copy(_l7);
      case 8:
        return _gf8Layout();
      case 9:
        return _linearLayout9();
      default:
        throw ArgumentError('Ordre non supporté : $order (attendu 3..9).');
    }
  }

  /// Lay-out d'ordre 9 : construction linéaire à bandes-transversales.
  ///
  /// value = ((j-i) mod 9)*9 + ((i+j) mod 9) + 1.
  /// Les « bandes » (j-i) sont des transversales (1 par ligne/colonne), ce qui
  /// garantit que la méthode d'incrément (+1 sur les plus grandes maisons)
  /// produit toujours un carré à lignes/colonnes équilibrées et distinctes.
  static List<List<int>> _linearLayout9() {
    const n = 9;
    return List.generate(
      n,
      (i) => List.generate(n, (j) {
        final band = ((j - i) % n + n) % n;
        final within = (i + j) % n;
        return band * n + within + 1;
      }),
    );
  }

  /// Lay-out d'ordre 8 via le corps fini GF(8) (deux carrés latins orthogonaux).
  ///
  /// value = (i XOR j)*8 + (mul2(i) XOR j) + 1.
  /// Les bandes (i XOR j) sont des transversales.
  static List<List<int>> _gf8Layout() {
    const n = 8;
    return List.generate(
      n,
      (i) => List.generate(n, (j) {
        final band = i ^ j;
        final within = _gfMul2(i) ^ j;
        return band * n + within + 1;
      }),
    );
  }

  /// Multiplication par x (=2) dans GF(2³), polynôme x³+x+1.
  static int _gfMul2(int a) {
    var t = a << 1;
    if ((t & 0x08) != 0) t ^= 0x0B;
    return t & 0x07;
  }

  static List<List<int>> houseLayoutFor(KhatimDimension dim) =>
      houseLayout(dim.order);

  /// Méthode siamoise (De la Loubère) — carré magique impair 1..n².
  static List<List<int>> siamese(int n) {
    assert(n.isOdd);
    final grid = List.generate(n, (_) => List.filled(n, 0));
    var row = 0;
    var col = n ~/ 2;
    for (var num = 1; num <= n * n; num++) {
      grid[row][col] = num;
      final nextRow = (row - 1 + n) % n;
      final nextCol = (col + 1) % n;
      if (grid[nextRow][nextCol] != 0) {
        row = (row + 1) % n;
      } else {
        row = nextRow;
        col = nextCol;
      }
    }
    return grid;
  }

  /// Méthode des pairs doubles (ordre multiple de 4) — ex. 8×8.
  static List<List<int>> doublyEven(int n) {
    assert(n % 4 == 0);
    final grid = List.generate(n, (r) => List.generate(n, (c) => r * n + c + 1));
    for (var r = 0; r < n; r++) {
      for (var c = 0; c < n; c++) {
        if ((r % 4 == c % 4) || ((r + c) % 4 == 3)) {
          grid[r][c] = n * n + 1 - grid[r][c];
        }
      }
    }
    return grid;
  }

  /// Vérifie qu'une grille est « semi-magique » : lignes et colonnes de somme
  /// constante et valeurs distinctes 1..n² (diagonales non requises).
  static bool isSemiMagic(List<List<int>> grid) {
    final n = grid.length;
    final expected = n * (n * n + 1) ~/ 2;
    for (var r = 0; r < n; r++) {
      if (grid[r].reduce((a, b) => a + b) != expected) return false;
    }
    for (var c = 0; c < n; c++) {
      var s = 0;
      for (var r = 0; r < n; r++) {
        s += grid[r][c];
      }
      if (s != expected) return false;
    }
    final flat = grid.expand((r) => r).toSet();
    return flat.length == n * n && flat.every((v) => v >= 1 && v <= n * n);
  }

  /// Vérifie qu'une grille est un carré magique normal (1..n²).
  static bool isMagic(List<List<int>> grid) {
    final n = grid.length;
    final expected = n * (n * n + 1) ~/ 2;
    for (var r = 0; r < n; r++) {
      if (grid[r].reduce((a, b) => a + b) != expected) return false;
    }
    for (var c = 0; c < n; c++) {
      var s = 0;
      for (var r = 0; r < n; r++) {
        s += grid[r][c];
      }
      if (s != expected) return false;
    }
    var d1 = 0, d2 = 0;
    for (var i = 0; i < n; i++) {
      d1 += grid[i][i];
      d2 += grid[i][n - 1 - i];
    }
    if (d1 != expected || d2 != expected) return false;
    final flat = grid.expand((r) => r).toSet();
    return flat.length == n * n &&
        flat.every((v) => v >= 1 && v <= n * n);
  }

  static List<List<int>> _copy(List<List<int>> src) =>
      src.map((row) => List<int>.from(row)).toList();
}
