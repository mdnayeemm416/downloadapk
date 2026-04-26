import 'package:intl/intl.dart';

String formatNumber(String value) {
  try {
    // Clean input
    value = value.trim().replaceAll(',', '.');

    double numValue = double.parse(value);
    return NumberFormat("0.##").format(numValue);
  } catch (e) {
    return value;
  }
}
