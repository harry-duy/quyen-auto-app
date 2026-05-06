import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// TODO: Add more domain-specific extensions as needed

extension StringExt on String {
  bool get isValidPhone => RegExp(r'^(0[3|5|7|8|9])+([0-9]{8})$').hasMatch(this);
  bool get isValidEmail => RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  String get capitalize => isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : this;
}

extension DateTimeExt on DateTime {
  String get ddMMYYYY  => DateFormat('dd/MM/yyyy').format(this);
  String get hhMM      => DateFormat('HH:mm').format(this);
  String get fullFormat => DateFormat('dd/MM/yyyy HH:mm').format(this);
}

extension DoubleExt on double {
  String get toCurrency => NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(this);
}

extension ContextExt on BuildContext {
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
    ));
  }
}
