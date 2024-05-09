import 'package:intl/intl.dart';

class FormattingUtils {
  static String formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    final aDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    final aTime = DateFormat.jm().format(timestamp); // e.g., 2:34 PM

    if (aDate == today) {
      return 'Today $aTime';
    } else if (aDate == tomorrow) {
      return 'Tomorrow $aTime';
    } else if (aDate == yesterday) {
      return 'Yesterday $aTime';
    } else if (aDate.isAfter(
      DateTime(now.year, now.month, now.day - 7),
    )) {
      return '${DateFormat.EEEE().format(timestamp)} $aTime'; // e.g., Wednesday 2:34 PM
    } else {
      return '${DateFormat('d MMM').format(timestamp)} $aTime'; // e.g., 19 Sep 2:34 PM
    }
  }
}
