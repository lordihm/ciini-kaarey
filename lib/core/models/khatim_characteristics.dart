import 'package:equatable/equatable.dart';

/// Les 7 caractéristiques communes d'un Khatim.
class KhatimCharacteristics extends Equatable {
  const KhatimCharacteristics({
    required this.key,
    required this.lock,
    required this.median,
    required this.wafq,
    required this.area,
    required this.force,
    required this.goal,
  });

  /// Clé (مفتاح) — plus petit nombre / première maison.
  final int key;

  /// Verrou (مغلاق) — plus grand nombre / dernière maison.
  final int lock;

  /// Médiane (عدل) — Clé + Verrou.
  final int median;

  /// WAFQ (وفق) — somme d'une colonne.
  final int wafq;

  /// Aire / Masahat (مساحة) — somme totale.
  final int area;

  /// Force / Dhabit (ضابط) — WAFQ + Aire.
  final int force;

  /// But / Ghayat (غاية) — 2 × Force.
  final int goal;

  List<({String label, String arabic, int value})> asList() => [
        (label: 'Clé', arabic: 'مفتاح', value: key),
        (label: 'Verrou', arabic: 'مغلاق', value: lock),
        (label: 'Médiane', arabic: 'عدل', value: median),
        (label: 'WAFQ', arabic: 'وفق', value: wafq),
        (label: 'Aire / Masahat', arabic: 'مساحة', value: area),
        (label: 'Force / Dhabit', arabic: 'ضابط', value: force),
        (label: 'But / Ghayat', arabic: 'غاية', value: goal),
      ];

  Map<String, dynamic> toJson() => {
        'key': key,
        'lock': lock,
        'median': median,
        'wafq': wafq,
        'area': area,
        'force': force,
        'goal': goal,
      };

  factory KhatimCharacteristics.fromJson(Map<String, dynamic> json) =>
      KhatimCharacteristics(
        key: json['key'] as int,
        lock: json['lock'] as int,
        median: json['median'] as int,
        wafq: json['wafq'] as int,
        area: json['area'] as int,
        force: json['force'] as int,
        goal: json['goal'] as int,
      );

  @override
  List<Object?> get props => [key, lock, median, wafq, area, force, goal];
}
