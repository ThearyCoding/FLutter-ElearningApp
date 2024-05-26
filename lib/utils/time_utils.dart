import 'package:intl/intl.dart';

enum TimeUnit {
  days,
  seconds,
}

class TimeUtils {
  static bool isNew(DateTime? addedDate, int timeToCheck, TimeUnit timeUnit) {
    if (addedDate == null) return false;
    DateTime now = DateTime.now();
    DateTime timeAgo;
    if (timeUnit == TimeUnit.days) {
      timeAgo = now.subtract(Duration(days: timeToCheck));
    } else {
      timeAgo = now.subtract(Duration(seconds: timeToCheck));
    }
    return addedDate.isAfter(timeAgo);
  }

  
  static String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp.toUtc());

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      // Check if the timestamp is within the current year
      if (timestamp.year == now.year) {
        // Format the timestamp to only display month and day
        final formatter = DateFormat('MMM dd');
        return formatter.format(timestamp);
      } else {
        // Format the timestamp to display the full date including the year
        final formatter = DateFormat('MMM dd yyyy');
        return formatter.format(timestamp);
      }
    }
  }
}
