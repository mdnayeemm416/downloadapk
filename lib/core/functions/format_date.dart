import 'package:intl/intl.dart';

String formatDate(String? dateString, String formatPattern) {
  if (dateString == null || dateString.isEmpty) {
    return "--";
  }

  try {
    final date = DateTime.parse(dateString);
    return DateFormat(formatPattern).format(date);
  } catch (e) {
    return "--"; // invalid date
  }
}

String getDay(String? dateString) {
  if (dateString == null || dateString.isEmpty) {
    return "--";
  }

  try {
    final date = DateTime.parse(dateString);
    return date.day.toString().padLeft(2, '0'); // returns only 26
  } catch (e) {
    return "--"; // invalid date
  }
}
