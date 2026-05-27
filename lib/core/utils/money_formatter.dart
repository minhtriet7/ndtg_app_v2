import 'package:intl/intl.dart';

class MoneyFormatter {
  static String formatVnd(dynamic amount) {
    if (amount == null) return '0 ₫';
    try {
      final parsed = double.parse(amount.toString());
      final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
      return formatter.format(parsed).trim();
    } catch (_) {
      return '$amount ₫';
    }
  }

  static String formatCurrencyAmount(dynamic amount, String currencyCode) {
    if (amount == null) return '0 $currencyCode';
    try {
      final parsed = double.parse(amount.toString());
      final formattedNum = NumberFormat.decimalPattern().format(parsed);
      return '$formattedNum $currencyCode';
    } catch (_) {
      return '$amount $currencyCode';
    }
  }

  static String formatToken(dynamic tokens) {
    if (tokens == null) return '0';
    try {
      final parsed = int.parse(tokens.toString());
      return NumberFormat.decimalPattern().format(parsed);
    } catch (_) {
      return tokens.toString();
    }
  }
}