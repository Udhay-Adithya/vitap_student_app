class MessMenuEntry {
  const MessMenuEntry({
    required this.day,
    required this.date,
    required this.breakfast,
    required this.lunch,
    required this.snacks,
    required this.dinner,
    required this.sheet,
  });

  final String day;
  final int date;
  final String breakfast;
  final String lunch;
  final String snacks;
  final String dinner;
  final String sheet;

  factory MessMenuEntry.fromJson(Map<String, dynamic> json) {
    return MessMenuEntry(
      day: (json['Day'] as String?)?.trim() ?? '',
      date: json['Date'] as int? ?? 0,
      breakfast: (json['Breakfast'] as String?)?.trim() ?? '',
      lunch: (json['Lunch'] as String?)?.trim() ?? '',
      snacks: (json['Snacks'] as String?)?.trim() ?? '',
      dinner: (json['Dinner'] as String?)?.trim() ?? '',
      sheet: (json['Sheet'] as String?)?.trim() ?? '',
    );
  }

  bool get isSpecial => sheet.toUpperCase().contains('SPECIAL');

  String menuFor(String meal) => switch (meal) {
    'Breakfast' => breakfast,
    'Lunch' => lunch,
    'Snacks' => snacks,
    'Dinner' => dinner,
    _ => '',
  };
}
