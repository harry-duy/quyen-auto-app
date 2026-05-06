import 'package:intl/intl.dart';

// TODO: Add more helper functions as features grow

class Helpers {
  Helpers._();

  static String formatCurrency(double amount) =>
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount);

  static String formatDate(DateTime date) =>
      DateFormat('dd/MM/yyyy').format(date);

  static String formatDateTime(DateTime date) =>
      DateFormat('dd/MM/yyyy HH:mm').format(date);

  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1)  return 'Vừa xong';
    if (diff.inHours < 1)    return '${diff.inMinutes} phút trước';
    if (diff.inDays < 1)     return '${diff.inHours} giờ trước';
    if (diff.inDays < 30)    return '${diff.inDays} ngày trước';
    return formatDate(date);
  }
}
