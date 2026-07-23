import 'package:equatable/equatable.dart';

import 'khatim_characteristics.dart';
import 'khatim_dimension.dart';
import 'spirit.dart';

/// Modèle principal : un Khatim généré, avec sa grille et toutes ses données.
class Khatim extends Equatable {
  const Khatim({
    required this.grid,
    required this.dimension,
    required this.pm,
    required this.method,
    required this.entry,
    required this.exit,
    required this.remainder,
    required this.characteristics,
    required this.spiritPairs,
    required this.isBalanced,
    required this.rowSums,
    required this.columnSums,
    required this.diagonalSums,
    required this.createdAt,
    this.coupledSpirits = const [],
    this.name,
    this.sourceText,
    this.abjadSystem,
  });

  /// Grille du carré magique.
  final List<List<int>> grid;
  final KhatimDimension dimension;

  /// Poids Mystique.
  final int pm;
  final ConstructionMethod method;

  /// Valeur d'entrée (quotient).
  final int entry;

  /// Valeur de sortie.
  final int exit;

  /// Reste de la division.
  final int remainder;

  final KhatimCharacteristics characteristics;
  final List<SpiritPair> spiritPairs;
  final List<CoupledSpirit> coupledSpirits;

  final bool isBalanced;
  final List<int> rowSums;
  final List<int> columnSums;
  final List<int> diagonalSums;

  final DateTime createdAt;
  final String? name;
  final String? sourceText;
  final AbjadSystem? abjadSystem;

  int get order => dimension.order;

  Map<String, dynamic> toJson() => {
        'grid': grid,
        'dimension': dimension.name,
        'pm': pm,
        'method': method.name,
        'entry': entry,
        'exit': exit,
        'remainder': remainder,
        'characteristics': characteristics.toJson(),
        'spiritPairs': spiritPairs.map((e) => e.toJson()).toList(),
        'coupledSpirits': coupledSpirits.map((e) => e.toJson()).toList(),
        'isBalanced': isBalanced,
        'rowSums': rowSums,
        'columnSums': columnSums,
        'diagonalSums': diagonalSums,
        'createdAt': createdAt.toIso8601String(),
        'name': name,
        'sourceText': sourceText,
        'abjadSystem': abjadSystem?.name,
      };

  factory Khatim.fromJson(Map<String, dynamic> json) => Khatim(
        grid: (json['grid'] as List)
            .map((row) => (row as List).map((e) => e as int).toList())
            .toList(),
        dimension: KhatimDimension.values.byName(json['dimension'] as String),
        pm: json['pm'] as int,
        method: ConstructionMethod.values.byName(json['method'] as String),
        entry: json['entry'] as int,
        exit: json['exit'] as int,
        remainder: json['remainder'] as int,
        characteristics:
            KhatimCharacteristics.fromJson(json['characteristics'] as Map<String, dynamic>),
        spiritPairs: (json['spiritPairs'] as List)
            .map((e) => SpiritPair.fromJson(e as Map<String, dynamic>))
            .toList(),
        coupledSpirits: ((json['coupledSpirits'] as List?) ?? [])
            .map((e) => CoupledSpirit.fromJson(e as Map<String, dynamic>))
            .toList(),
        isBalanced: json['isBalanced'] as bool,
        rowSums: (json['rowSums'] as List).map((e) => e as int).toList(),
        columnSums: (json['columnSums'] as List).map((e) => e as int).toList(),
        diagonalSums: (json['diagonalSums'] as List).map((e) => e as int).toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        name: json['name'] as String?,
        sourceText: json['sourceText'] as String?,
        abjadSystem: json['abjadSystem'] != null
            ? AbjadSystem.values.byName(json['abjadSystem'] as String)
            : null,
      );

  @override
  List<Object?> get props => [
        grid,
        dimension,
        pm,
        method,
        entry,
        exit,
        remainder,
        characteristics,
        createdAt,
      ];
}
