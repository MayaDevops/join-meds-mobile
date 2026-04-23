import 'package:intl/intl.dart';

class ApiDateFormatter {
  static final DateFormat _formatter = DateFormat('dd-MM-yyyy');

  static String toApiDateString(dynamic value) {
    if (value == null) return '';

    if (value is String) {
      return value; // assume already formatted
    }

    if (value is DateTime) {
      return _formatter.format(value);
    }

    throw Exception('Invalid date value: $value');
  }
}
