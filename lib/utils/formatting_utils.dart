import 'package:intl/intl.dart';

class FormattingUtils {
  static String getSectionTitle(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    final date = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (date == today) {
      return 'Today';
    } else if (date == yesterday) {
      return 'Yesterday';
    } else if (date == tomorrow) {
      return 'Tomorrow';
    }else if (date.isAfter(
      DateTime(now.year, now.month, now.day - 7),
    )) {
      return DateFormat.EEEE().format(timestamp); // e.g., Wednesday
    } else {
      return DateFormat('d MMM').format(timestamp);
    }
  }
}
