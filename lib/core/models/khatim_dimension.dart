/// Les 7 dimensions traditionnelles de Khatim (khawâtim).
enum KhatimDimension {
  moussala(3, 'MOUSSALAS', 'مثلث', 'Saturne'),
  murabba(4, "MOURABBA'A", 'مربع', 'Jupiter'),
  mukhamas(5, 'MOUKHAMAS', 'مخمس', 'Mars'),
  moussadis(6, 'MOUSSADIS', 'مسادس', 'Soleil'),
  moussabbia(7, "MOUSSABBI'A", 'مسبع', 'Vénus'),
  mouhamin(8, 'MOUTHAMIN', 'مثمن', 'Mercure'),
  moutassi(9, "MOUTASSI'OU", 'متسع', 'Lune');

  const KhatimDimension(this.order, this.frenchName, this.arabicName, this.planet);

  /// Ordre du carré (3 à 9).
  final int order;
  final String frenchName;
  final String arabicName;
  final String planet;

  int get cellCount => order * order;

  /// Constante à soustraire du PM : n(n²-1)/2.
  int get subtractionConstant => order * (order * order - 1) ~/ 2;

  /// Constante magique standard (carré 1..n²) : n(n²+1)/2.
  int get standardMagicConstant => order * (order * order + 1) ~/ 2;

  String get size => '${order}x$order';

  String get displayLabel => '$frenchName ($size)';

  String get usageSummary {
    switch (this) {
      case KhatimDimension.moussala:
        return 'Associé à SATURNE — Protection, désunion, fructification des affaires, '
            'sortie de prison, faciliter un accouchement, sécurité.';
      case KhatimDimension.murabba:
        return 'Associé à JUPITER — Œuvres de bien, amour et attraction, prestige, '
            'désenvoutement, victoire et estime auprès des autorités.';
      case KhatimDimension.mukhamas:
        return 'Associé à MARS — Guérison des maladies, amour des femmes, '
            'protection, vigueur et invulnérabilité.';
      case KhatimDimension.moussadis:
        return 'Associé au SOLEIL — Richesse, victoire, succès, faveurs et '
            'honneurs auprès des régnants.';
      case KhatimDimension.moussabbia:
        return 'Associé à VÉNUS — Amour, acquisition de la science, protection '
            'des femmes, destruction des mauvais sorts.';
      case KhatimDimension.mouhamin:
        return 'Associé à MERCURE — Richesse, guérison, sciences et entreprises, '
            'éloquence, intuition et dissimulation.';
      case KhatimDimension.moutassi:
        return 'Associé à la LUNE — Amour universel, bonheur, exaucement, '
            'sécurité, songes prophétiques.';
    }
  }

  static KhatimDimension fromOrder(int order) =>
      KhatimDimension.values.firstWhere((d) => d.order == order);
}

/// Méthode de construction du carré.
enum ConstructionMethod {
  advanced('Configuration Avancée', 'Technique de configuration : soustraction du PM, '
      'division, gestion des restes et placement des incréments.'),
  fromInterior('Bordures — Intérieur vers Extérieur', 'Construit un carré à bordures '
      'concentriques depuis le centre (dimensions impaires).'),
  fromExterior('Bordures — Extérieur vers Intérieur', 'Construit un carré à bordures '
      'depuis le pourtour (dimensions impaires).');

  const ConstructionMethod(this.labelFr, this.descriptionFr);

  final String labelFr;
  final String descriptionFr;
}

/// Système de comput Abjad.
enum AbjadSystem {
  occidental('Comput occidental (Maghrébin)'),
  oriental('Comput oriental (Mashriqi)');

  const AbjadSystem(this.labelFr);
  final String labelFr;
}
