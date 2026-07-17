/// Safely parses a `HH:mm` class time (e.g. `"09:00"`) into a [DateTime] anchored
/// to today. Returns `null` for anything that isn't a valid time — including the
/// `"-"` placeholder VTOP emits for empty grid cells — so callers can skip or
/// gracefully degrade instead of throwing during `build()`.
DateTime? parseClassTime(String? timeString) {
  if (timeString == null) return null;

  final parts = timeString.trim().split(':');
  if (parts.length != 2) return null;

  final hour = int.tryParse(parts[0].trim());
  final minute = int.tryParse(parts[1].trim());
  if (hour == null || minute == null) return null;
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day, hour, minute);
}
