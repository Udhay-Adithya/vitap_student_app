import 'package:vit_ap_student_app/features/home/model/mess_menu_entry.dart';

enum MessMenuTab { regular, special }

extension MessMenuTabX on MessMenuTab {
  String get label => switch (this) {
    MessMenuTab.regular => 'Veg / Non-Veg',
    MessMenuTab.special => 'Special',
  };
}

class MessMenuBundle {
  const MessMenuBundle({
    required this.date,
    required this.regular,
    required this.special,
  });

  final DateTime date;
  final MessMenuEntry regular;
  final MessMenuEntry? special;

  bool get hasSpecial => special != null;

  MessMenuEntry entryFor(MessMenuTab tab) => switch (tab) {
    MessMenuTab.regular => regular,
    MessMenuTab.special => special ?? regular,
  };
}
