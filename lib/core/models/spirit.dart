import 'package:equatable/equatable.dart';

enum SpiritType { celestial, terrestrial }

/// Un esprit-servant (RAWHÂN) extrait d'une valeur caractéristique.
class Spirit extends Equatable {
  const Spirit({
    required this.name,
    required this.transliteration,
    required this.type,
    required this.value,
    this.revolutionsAdded = 0,
  });

  /// Nom de l'esprit en caractères arabes (avec suffixe).
  final String name;

  /// Translittération latine.
  final String transliteration;

  final SpiritType type;

  /// Valeur numérique source (la caractéristique).
  final int value;

  /// Nombre de révolutions (×360) ajoutées avant soustraction de 1019.
  final int revolutionsAdded;

  bool get isCelestial => type == SpiritType.celestial;

  Map<String, dynamic> toJson() => {
        'name': name,
        'transliteration': transliteration,
        'type': type.name,
        'value': value,
        'revolutionsAdded': revolutionsAdded,
      };

  factory Spirit.fromJson(Map<String, dynamic> json) => Spirit(
        name: json['name'] as String,
        transliteration: json['transliteration'] as String,
        type: SpiritType.values.byName(json['type'] as String),
        value: json['value'] as int,
        revolutionsAdded: (json['revolutionsAdded'] as int?) ?? 0,
      );

  @override
  List<Object?> get props => [name, transliteration, type, value, revolutionsAdded];
}

/// Paire d'esprits (céleste + terrestre) attachée à une caractéristique nommée.
class SpiritPair extends Equatable {
  const SpiritPair({
    required this.sourceLabel,
    required this.sourceValue,
    required this.celestial,
    required this.terrestrial,
  });

  final String sourceLabel;
  final int sourceValue;
  final Spirit celestial;
  final Spirit terrestrial;

  Map<String, dynamic> toJson() => {
        'sourceLabel': sourceLabel,
        'sourceValue': sourceValue,
        'celestial': celestial.toJson(),
        'terrestrial': terrestrial.toJson(),
      };

  factory SpiritPair.fromJson(Map<String, dynamic> json) => SpiritPair(
        sourceLabel: json['sourceLabel'] as String,
        sourceValue: json['sourceValue'] as int,
        celestial: Spirit.fromJson(json['celestial'] as Map<String, dynamic>),
        terrestrial: Spirit.fromJson(json['terrestrial'] as Map<String, dynamic>),
      );

  @override
  List<Object?> get props => [sourceLabel, sourceValue, celestial, terrestrial];
}

/// Esprit issu du couplage par colonnes (cas particulier du Mourabba).
class CoupledSpirit extends Equatable {
  const CoupledSpirit({
    required this.label,
    required this.first,
    required this.second,
    required this.name,
    required this.transliteration,
    required this.type,
  });

  final String label;
  final int first;
  final int second;
  final String name;
  final String transliteration;
  final SpiritType type;

  Map<String, dynamic> toJson() => {
        'label': label,
        'first': first,
        'second': second,
        'name': name,
        'transliteration': transliteration,
        'type': type.name,
      };

  factory CoupledSpirit.fromJson(Map<String, dynamic> json) => CoupledSpirit(
        label: json['label'] as String,
        first: json['first'] as int,
        second: json['second'] as int,
        name: json['name'] as String,
        transliteration: json['transliteration'] as String,
        type: SpiritType.values.byName(json['type'] as String),
      );

  @override
  List<Object?> get props => [label, first, second, name, transliteration, type];
}
