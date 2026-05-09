import 'package:intl/intl.dart';

String formatBalance(double amount) {
  return '\$${NumberFormat('#,##0.00', 'en_US').format(amount).replaceAll(',', ' ')}';
}