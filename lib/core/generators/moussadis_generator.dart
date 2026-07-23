import '../models/khatim.dart';
import '../models/khatim_dimension.dart';
import 'khatim_generator.dart';

/// Générateur de convenance pour le Moussadis 6x6 (délègue à [AdvancedGenerator]).
class MoussadisGenerator {
  MoussadisGenerator({KhatimGenerator? delegate})
      : _delegate = delegate ?? AdvancedGenerator();

  final KhatimGenerator _delegate;

  static const KhatimDimension dimension = KhatimDimension.moussadis;

  Khatim generate({
    required int pm,
    String? sourceText,
    String? name,
    AbjadSystem? abjadSystem,
  }) =>
      _delegate.generate(
        pm: pm,
        dimension: dimension,
        sourceText: sourceText,
        name: name,
        abjadSystem: abjadSystem,
      );
}
