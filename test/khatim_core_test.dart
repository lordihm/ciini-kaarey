import 'package:ciini_kaarey/core/calculators/abjad_calculator.dart';
import 'package:ciini_kaarey/core/calculators/characteristic_calculator.dart';
import 'package:ciini_kaarey/core/calculators/spirit_extractor.dart';
import 'package:ciini_kaarey/core/constants/layout_configs.dart';
import 'package:ciini_kaarey/core/generators/khatim_generator.dart';
import 'package:ciini_kaarey/core/models/khatim_dimension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Technique de configuration avancée', () {
    final gen = AdvancedGenerator();

    test('Moussalas PM 1947 (reste 0) — grille documentée', () {
      final k = gen.generate(pm: 1947, dimension: KhatimDimension.moussala);
      expect(k.entry, 645);
      expect(k.remainder, 0);
      expect(k.exit, 653);
      expect(k.grid, [
        [648, 653, 646],
        [647, 649, 651],
        [652, 645, 650],
      ]);
      expect(k.rowSums.every((s) => s == 1947), isTrue);
      expect(k.columnSums.every((s) => s == 1947), isTrue);
    });

    test('Moussalas PM 1948 (reste 1) — grille documentée', () {
      final k = gen.generate(pm: 1948, dimension: KhatimDimension.moussala);
      expect(k.remainder, 1);
      expect(k.grid, [
        [648, 654, 646],
        [647, 649, 652],
        [653, 645, 650],
      ]);
      expect(k.columnSums.every((s) => s == 1948), isTrue);
    });

    test('Moussalas PM 1949 (reste 2) — grille documentée', () {
      final k = gen.generate(pm: 1949, dimension: KhatimDimension.moussala);
      expect(k.remainder, 2);
      expect(k.grid, [
        [649, 654, 646],
        [647, 650, 652],
        [653, 645, 651],
      ]);
      expect(k.columnSums.every((s) => s == 1949), isTrue);
    });

    test('Moussalas PM 635 (reste 2) — exemple des caractéristiques', () {
      final k = gen.generate(pm: 635, dimension: KhatimDimension.moussala);
      expect(k.entry, 207);
      expect(k.remainder, 2);
      expect(k.grid, [
        [211, 216, 208],
        [209, 212, 214],
        [215, 207, 213],
      ]);
      expect(k.characteristics.key, 207);
      expect(k.characteristics.lock, 216);
      expect(k.characteristics.median, 423);
      expect(k.characteristics.wafq, 635);
      expect(k.characteristics.area, 1905);
      expect(k.characteristics.force, 2540);
      expect(k.characteristics.goal, 5080);
    });

    test('Mourabba PM 1950 (reste 0) — grille documentée', () {
      final k = gen.generate(pm: 1950, dimension: KhatimDimension.murabba);
      expect(k.entry, 480);
      expect(k.remainder, 0);
      expect(k.grid, [
        [487, 490, 493, 480],
        [492, 481, 486, 491],
        [482, 495, 488, 485],
        [489, 484, 483, 494],
      ]);
      expect(k.columnSums.every((s) => s == 1950), isTrue);
    });

    test('Mourabba de LATÎF PM 129 (reste 3)', () {
      final k = gen.generate(pm: 129, dimension: KhatimDimension.murabba);
      expect(k.entry, 24);
      expect(k.remainder, 3);
      expect(k.grid, [
        [32, 35, 38, 24],
        [37, 25, 31, 36],
        [26, 40, 33, 30],
        [34, 29, 27, 39],
      ]);
    });

    test('Moukhamas PM 1950 (reste 0) — grille documentée', () {
      final k = gen.generate(pm: 1950, dimension: KhatimDimension.mukhamas);
      expect(k.entry, 378);
      expect(k.grid, [
        [378, 391, 399, 387, 395],
        [402, 385, 393, 381, 389],
        [396, 379, 392, 400, 383],
        [390, 398, 386, 394, 382],
        [384, 397, 380, 388, 401],
      ]);
    });

    test('Moussabbia PM 1946 (reste 0) — grille documentée', () {
      final k = gen.generate(pm: 1946, dimension: KhatimDimension.moussabbia);
      expect(k.entry, 254);
      expect(k.grid[0], [254, 271, 288, 298, 266, 276, 293]);
      expect(k.columnSums.every((s) => s == 1946), isTrue);
    });

    test('Validité (lignes & colonnes = PM) pour toutes dimensions et restes', () {
      for (final dim in KhatimDimension.values) {
        final n = dim.order;
        for (var r = 0; r < n; r++) {
          final pm = dim.subtractionConstant + n * 400 + r;
          final k = gen.generate(pm: pm, dimension: dim);
          expect(k.remainder, r, reason: '${dim.frenchName} reste attendu $r');
          expect(k.rowSums.every((s) => s == pm), isTrue,
              reason: '${dim.frenchName} reste $r lignes');
          expect(k.columnSums.every((s) => s == pm), isTrue,
              reason: '${dim.frenchName} reste $r colonnes');
          // Distinctesse garantie pour tous sauf l'ordre 6 (aucun carré
          // gréco-latin d'ordre 6 n'existe — limitation mathématique).
          if (n != 6) {
            final flat = k.grid.expand((row) => row).toList();
            expect(flat.toSet().length, n * n,
                reason: '${dim.frenchName} reste $r valeurs distinctes');
          }
        }
      }
    });
  });

  group('Abjad', () {
    test('لطيف = 129 (les deux systèmes)', () {
      expect(AbjadCalculator.calculate('لطيف', system: AbjadSystem.oriental).weight, 129);
      expect(AbjadCalculator.calculate('لطيف', system: AbjadSystem.occidental).weight, 129);
    });

    test('ش diffère selon le système', () {
      expect(AbjadCalculator.calculate('ش', system: AbjadSystem.oriental).weight, 300);
      expect(AbjadCalculator.calculate('ش', system: AbjadSystem.occidental).weight, 1000);
    });

    test('156 → ونق', () {
      expect(AbjadCalculator.numberToArabicLetters(156), 'ونق');
    });

    test('texte vide → erreur', () {
      expect(AbjadCalculator.calculate('', system: AbjadSystem.oriental).isSuccess, isFalse);
    });
  });

  group('Extraction des esprits', () {
    test('Clé 207 → ونقياءيل + terrestre (3 révolutions)', () {
      final pair = SpiritExtractor.extractPair('Clé', 207);
      expect(pair.celestial.name, 'ونقياءيل');
      expect(pair.terrestrial.revolutionsAdded, 3);
      expect(pair.terrestrial.name.startsWith('حصر'), isTrue);
      expect(pair.terrestrial.name.endsWith('طيش'), isTrue);
    });
  });

  group('Lay-outs de base', () {
    test('ordres 3..7 sont pleinement magiques (diagonales incluses)', () {
      for (var n = 3; n <= 7; n++) {
        expect(LayoutConfigs.isMagic(LayoutConfigs.houseLayout(n)), isTrue,
            reason: 'ordre $n');
      }
    });

    test('ordres 8 et 9 sont semi-magiques (lignes/colonnes + distincts)', () {
      expect(LayoutConfigs.isSemiMagic(LayoutConfigs.houseLayout(8)), isTrue);
      expect(LayoutConfigs.isSemiMagic(LayoutConfigs.houseLayout(9)), isTrue);
    });
  });

  group('Méthodes de bordures', () {
    test('carré à bordures impair valide (3,5,7,9)', () {
      final gen = InteriorBorderGenerator();
      for (final dim in [
        KhatimDimension.moussala,
        KhatimDimension.mukhamas,
        KhatimDimension.moussabbia,
        KhatimDimension.moutassi,
      ]) {
        final n = dim.order;
        final pm = dim.standardMagicConstant + n * 10;
        final k = gen.generate(pm: pm, dimension: dim);
        expect(k.rowSums.every((s) => s == pm), isTrue);
        expect(k.columnSums.every((s) => s == pm), isTrue);
      }
    });

    test('rejet des dimensions paires', () {
      expect(
        () => InteriorBorderGenerator()
            .generate(pm: 34, dimension: KhatimDimension.murabba),
        throwsArgumentError,
      );
    });
  });

  group('CharacteristicCalculator', () {
    test('clé/verrou = min/max', () {
      final grid = [
        [211, 216, 208],
        [209, 212, 214],
        [215, 207, 213],
      ];
      expect(CharacteristicCalculator.calculateKey(grid), 207);
      expect(CharacteristicCalculator.calculateLock(grid), 216);
    });
  });
}
