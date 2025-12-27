import 'package:intl/intl.dart';

class AppDateUtils {
  /// Format date as "MMM d" (e.g., "Jan 1")
  static String formatShortDate(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  /// Format time as "h:mm a" (e.g., "3:30 PM")
  static String formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  /// Format date and time (e.g., "Jan 1 • 3:30 PM")
  static String formatDateTime(DateTime dateTime) {
    return '${formatShortDate(dateTime)} • ${formatTime(dateTime)}';
  }

  /// Format full date (e.g., "January 1, 2024")
  static String formatFullDate(DateTime date) {
    return DateFormat('MMMM d, y').format(date);
  }

  /// Format date for display in calendar header (e.g., "Monday, Jan 1")
  static String formatCalendarHeader(DateTime date) {
    return DateFormat('EEEE, MMM d').format(date);
  }

  /// Check if two dates are on the same day
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Get the start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get the end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// Get days until a date
  static int daysUntil(DateTime date) {
    final now = DateTime.now();
    final today = startOfDay(now);
    final target = startOfDay(date);
    return target.difference(today).inDays;
  }

  /// Get relative time description (e.g., "Today", "Tomorrow", "In 3 days")
  static String getRelativeTime(DateTime date) {
    final days = daysUntil(date);
    if (days == 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    if (days == -1) return 'Yesterday';
    if (days < 0) return '${-days} days ago';
    return 'In $days days';
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return isSameDay(date, tomorrow);
  }

  /// Check if date is in the current week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return date.isAfter(
          startOfDay(startOfWeek).subtract(const Duration(seconds: 1)),
        ) &&
        date.isBefore(endOfDay(endOfWeek));
  }
}
