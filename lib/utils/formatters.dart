import 'package:intl/intl.dart';

class Formatters {
  static final _currencyFormat = NumberFormat('#,##0.00');
  static final _currencyFormatNoDecimal = NumberFormat('#,##0');
  static final _dateFormat = DateFormat('d/M/yyyy');
  static final _dateFormatLong = DateFormat('d MMM yyyy');

  // Format currency with decimals
  static String formatCurrency(double amount, {bool showDecimal = true}) {
    if (showDecimal) {
      return 'Rs ${_currencyFormat.format(amount)}';
    }
    return 'Rs ${_currencyFormatNoDecimal.format(amount)}';
  }

  // Format currency for display (no prefix)
  static String formatAmount(double amount, {bool showDecimal = true}) {
    if (showDecimal) {
      return _currencyFormat.format(amount);
    }
    return _currencyFormatNoDecimal.format(amount);
  }

  // Format date short
  static String formatDateShort(DateTime date) {
    return _dateFormat.format(date);
  }

  // Format date long
  static String formatDateLong(DateTime date) {
    return _dateFormatLong.format(date);
  }
}