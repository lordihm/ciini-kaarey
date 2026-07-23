import 'package:intl/intl.dart';

/// Formatage des nombres et dates.
class Formatters {
  Formatters._();

  static final NumberFormat _number = NumberFormat.decimalPattern('fr');
  static final DateFormat _dateTime = DateFormat('dd/MM/yyyy HH:mm', 'fr');

  static String number(int value) => _number.format(value);

  static String dateTime(DateTime dt) => _dateTime.format(dt);
}
