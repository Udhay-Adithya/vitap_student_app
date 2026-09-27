/// Maps a weekday name to the date it falls on in the week being shown.
///
/// The timetable is a tab per weekday, not a date, so nothing on that screen
/// knows which Monday it is looking at. The calendar is keyed by date, so the
/// two have to be joined somewhere.
///
/// "This week" runs Monday to Sunday and contains [from]. That matches what the
/// timetable shows: tabs for the current week, not the next seven days — so on
/// a Thursday, the Monday tab is the Monday just gone, and its holiday, if it
/// had one, is the one already past.
library;

const _weekdayNumbers = <String, int>{
  'monday': DateTime.monday,
  'tuesday': DateTime.tuesday,
  'wednesday': DateTime.wednesday,
  'thursday': DateTime.thursday,
  'friday': DateTime.friday,
  'saturday': DateTime.saturday,
  'sunday': DateTime.sunday,
};

/// The date [weekdayName] falls on in the week containing [from].
///
/// Returns null for anything that is not a weekday name, rather than guessing —
/// a wrong date here would show a holiday notice on the wrong day.
DateTime? dateForWeekdayInWeekOf(String weekdayName, DateTime from) {
  final weekday = _weekdayNumbers[weekdayName.trim().toLowerCase()];
  if (weekday == null) return null;

  // DateTime normalises overflow, so no clamping to month lengths is needed.
  return DateTime(from.year, from.month, from.day - from.weekday + weekday);
}
