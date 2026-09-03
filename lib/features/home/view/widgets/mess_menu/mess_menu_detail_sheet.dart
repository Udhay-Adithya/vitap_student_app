import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vit_ap_student_app/features/home/model/mess_menu_bundle.dart';
import 'package:vit_ap_student_app/features/home/model/mess_menu_entry.dart';
import 'package:vit_ap_student_app/features/home/model/mess_menu_hostel.dart';

void showMessMenuDetailSheet(
  BuildContext context,
  MessMenuBundle bundle,
  MessMenuTab selectedTab,
  MessMenuHostel hostel,
) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (BuildContext context) => _MessMenuDetailSheet(
      bundle: bundle,
      selectedTab: selectedTab,
      hostel: hostel,
    ),
  );
}

class _MessMenuDetailSheet extends StatelessWidget {
  const _MessMenuDetailSheet({
    required this.bundle,
    required this.selectedTab,
    required this.hostel,
  });

  final MessMenuBundle bundle;
  final MessMenuTab selectedTab;
  final MessMenuHostel hostel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final MessMenuEntry entry = bundle.entryFor(selectedTab);
    final String dateLabel = DateFormat('EEE, d MMM').format(bundle.date);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              '${selectedTab.label} Menu',
              style: tt.headlineSmall?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              dateLabel,
              style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              hostel.label,
              style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 18),
            _MealInfoCard(
              title: 'Breakfast',
              time: '7:15 AM to 9:00 AM',
              menu: entry.breakfast,
            ),
            const SizedBox(height: 12),
            _MealInfoCard(
              title: 'Lunch',
              time: '12:30 PM to 2:15 PM',
              menu: entry.lunch,
            ),
            const SizedBox(height: 12),
            _MealInfoCard(
              title: 'Snacks',
              time: '4:45 PM to 6:15 PM',
              menu: entry.snacks,
            ),
            const SizedBox(height: 12),
            _MealInfoCard(
              title: 'Dinner',
              time: '7:15 PM to 9:00 PM',
              menu: entry.dinner,
            ),
          ],
        ),
      ),
    );
  }
}

class _MealInfoCard extends StatelessWidget {
  const _MealInfoCard({
    required this.title,
    required this.time,
    required this.menu,
  });

  final String title;
  final String time;
  final String menu;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: tt.titleMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                time,
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            menu.isEmpty ? '—' : menu,
            style: tt.bodyMedium?.copyWith(color: cs.onSurface, height: 1.45),
          ),
        ],
      ),
    );
  }
}
