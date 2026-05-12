import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

// formats balance with $ sign and 2 decimals, e.g. $1 234.56
String formatBalance(double amount) {
  return '\$${NumberFormat('#,##0.00', 'en_US').format(amount).replaceAll(',', ' ')}';
}

// is price rising or falling? (true = rising, false = falling, null = no data)
Color priceDirectionColor(bool? direction) {
  if (direction == true) return const Color(0xFF00C853); 
  if (direction == false) return const Color(0xFFFF1744); 
  return Colors.grey;
}

// compare value to reference and return color (green if above, red if below, white if equal)
Color compareColor(double value, double reference) {
  if (value > reference) return const Color(0xFF00C853); 
  if (value < reference) return const Color(0xFFFF1744);  
  return Colors.white;
}