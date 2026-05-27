import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDateTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '--/--/---- --:--';
    try {
      final parsed = DateTime.parse(isoString).toLocal();
      return DateFormat('dd/MM/yyyy HH:mm').format(parsed);
    } catch (_) {
      return isoString;
    }
  }

  static String formatTimeAgo(String? isoString) {
    if (isoString == null || isoString.isEmpty) return 'Vừa xong';
    try {
      final date = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inSeconds < 60) return 'Vừa xong';
      if (difference.inMinutes < 60) return '${difference.inMinutes} phút trước';
      if (difference.inHours < 24) return '${difference.inHours} giờ trước';
      if (difference.inDays < 7) return '${difference.inDays} ngày trước';
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return 'Gần đây';
    }
  }
}