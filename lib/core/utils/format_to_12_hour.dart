import 'package:intl/intl.dart';

String formatTo12Hour(String? timeString) {
  if (timeString == null || timeString.trim().isEmpty) {
    return '';
  }

  try {
    final timeParts = timeString.trim().split(':').map(int.parse).toList();
    if (timeParts.length != 2) return timeString;

    final now = DateTime.now();
    final dateTime =
        DateTime(now.year, now.month, now.day, timeParts[0], timeParts[1]);

    return DateFormat('h:mm a').format(dateTime);
  } catch (e) {
    return timeString; // Return original if parsing fails
  }
}

/// Formats a `start – end` time range in 12-hour form, e.g. `"9:00 AM - 9:50 AM"`.
/// Falls back to just the start time when the end is missing/malformed, and to an
/// empty string when both are absent.
String formatTimeRange(String? startTime, String? endTime) {
  final start = formatTo12Hour(startTime);
  final end = formatTo12Hour(endTime);

  if (start.isEmpty) return end;
  if (end.isEmpty) return start;
  return '$start - $end';
}
