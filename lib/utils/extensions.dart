/// Extensions utiles.
extension IntWordX on int {
  /// Retourne le jour de la semaine mystique associé à une somme (÷7).
  /// 0=Samedi, 1=Dimanche, … 6=Vendredi.
  String get mysticalWeekday {
    const days = [
      'Samedi',
      'Dimanche',
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
    ];
    return days[this % 7];
  }
}

extension GridX on List<List<int>> {
  int get total => expand((r) => r).fold(0, (a, b) => a + b);
}
