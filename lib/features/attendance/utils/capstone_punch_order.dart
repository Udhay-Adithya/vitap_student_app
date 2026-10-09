import 'package:vit_ap_student_app/core/models/capstone_attendance.dart';

/// The capstone punch calendar with the most recent day first.
///
/// VTOP lists the calendar oldest first, so the day someone opens the sheet
/// to check was always at the bottom of a long list. Sorted by the date
/// itself rather than by reversing: the punches come back out of an ObjectBox
/// relation, whose order is not something to rely on.
///
/// A date that cannot be read sorts after every dated punch instead of
/// throwing, and punches on the same day fall back to VTOP's serial.
List<CapstonePunch> newestPunchesFirst(Iterable<CapstonePunch> punches) {
  final dated = [
    for (final punch in punches)
      (
        punch: punch,
        day: _parseDay(punch.date),
        serial: int.tryParse(punch.serial),
      ),
  ];

  dated.sort((a, b) {
    final aDay = a.day;
    final bDay = b.day;
    if (aDay == null || bDay == null) {
      if (aDay == bDay) return 0;
      return aDay == null ? 1 : -1;
    }
    final byDay = bDay.compareTo(aDay);
    if (byDay != 0) return byDay;
    return (b.serial ?? 0).compareTo(a.serial ?? 0);
  });

  return [for (final entry in dated) entry.punch];
}

/// Reads VTOP's `dd-MM-yyyy`, e.g. `17-07-2026`.
DateTime? _parseDay(String value) {
  final parts = value.trim().split('-');
  if (parts.length != 3) return null;
  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) return null;
  return DateTime(year, month, day);
}
