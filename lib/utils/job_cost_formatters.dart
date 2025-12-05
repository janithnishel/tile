import 'package:intl/intl.dart';

class AppFormatters {
  static final NumberFormat currencyFormat = NumberFormat('#,##0');
  static final DateFormat dateFormat = DateFormat('d MMM yyyy');
  static final DateFormat shortDateFormat = DateFormat('d MMM');

  static String formatCurrency(double value) {
    return 'Rs ${currencyFormat.format(value)}';
  }

  static String formatCurrencyAbs(double value) {
    return 'Rs ${currencyFormat.format(value.abs())}';
  }

  static String formatDate(DateTime date) {
    return dateFormat.format(date);
  }

  static String formatShortDate(DateTime date) {
    return shortDateFormat.format(date);
  }

  static String formatQuantity(double qty) {
    return qty.toStringAsFixed(0);
  }

  static String formatPercentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }
}