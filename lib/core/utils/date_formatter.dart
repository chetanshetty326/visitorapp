import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _displayFormat = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat _shortDateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');

  /// Formats DateTime or ISO string for user-friendly display
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return _displayFormat.format(dateTime.toLocal());
  }

  /// Formats only the time portion
  static String formatTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return _timeFormat.format(dateTime.toLocal());
  }

  /// Formats only the date portion
  static String formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return _shortDateFormat.format(dateTime.toLocal());
  }

  /// Check if a given DateTime falls on today's calendar date in device local timezone
  static bool isToday(DateTime? dateTime) {
    if (dateTime == null) return false;
    final localTarget = dateTime.toLocal();
    final localNow = DateTime.now();
    return localTarget.year == localNow.year &&
        localTarget.month == localNow.month &&
        localTarget.day == localNow.day;
  }

  /// Parse ISO-8601 string or returns null
  static DateTime? parseIso(String? isoString) {
    if (isoString == null || isoString.trim().isEmpty) return null;
    try {
      return DateTime.parse(isoString);
    } catch (_) {
      return null;
    }
  }

  /// Convert DateTime to ISO-8601 string with local timezone offset
  static String toIso(DateTime dateTime) {
    return dateTime.toIso8601String();
  }
}
