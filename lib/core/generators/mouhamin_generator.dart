import '../models/khatim.dart';
import '../models/khatim_dimension.dart';
import 'khatim_generator.dart';

/// Générateur de convenance pour le Mouhamin 8x8 (délègue à [AdvancedGenerator]).
class MouhaminGenerator {
  MouhaminGenerator({KhatimGenerator? delegate})
      : _delegate = delegate ?? AdvancedGenerator();

  final KhatimGenerator _delegate;

  static const KhatimDimension dimension = KhatimDimension.mouhamin;

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
