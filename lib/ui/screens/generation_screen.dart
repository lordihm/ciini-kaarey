import 'package:flutter/material.dart';

import '../../core/models/khatim_dimension.dart';
import 'result_screen.dart';

/// Écran de génération : point d'entrée alternatif qui lance la génération
/// puis affiche le résultat via [ResultScreen].
///
/// (Dans cette architecture, [ResultScreen] gère à la fois la progression
/// et l'affichage ; [GenerationScreen] est fourni comme façade nommée.)
class GenerationScreen extends StatelessWidget {
  const GenerationScreen({
    super.key,
    required this.dimension,
    required this.method,
    required this.pm,
    this.sourceText,
    this.abjadSystem,
  });

  final KhatimDimension dimension;
  final ConstructionMethod method;
  final int pm;
  final String? sourceText;
  final AbjadSystem? abjadSystem;

  @override
  Widget build(BuildContext context) {
    return ResultScreen(
      dimension: dimension,
      method: method,
      pm: pm,
      sourceText: sourceText,
      abjadSystem: abjadSystem,
    );
  }
}
