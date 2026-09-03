import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vit_ap_student_app/core/providers/schedule_clock.dart';
import 'package:vit_ap_student_app/core/providers/user_preferences_notifier.dart';
import 'package:vit_ap_student_app/features/home/model/mess_menu_bundle.dart';
import 'package:vit_ap_student_app/features/home/model/mess_menu_cache_result.dart';
import 'package:vit_ap_student_app/features/home/model/mess_menu_entry.dart';
import 'package:vit_ap_student_app/features/home/model/mess_menu_hostel.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/mess_menu/mess_menu_detail_sheet.dart';
import 'package:vit_ap_student_app/features/home/viewmodel/mess_menu_viewmodel.dart';

class MessMenuCard extends ConsumerStatefulWidget {
  const MessMenuCard({super.key});

  @override
  ConsumerState<MessMenuCard> createState() => _MessMenuCardState();
}

class _MessMenuCardState extends ConsumerState<MessMenuCard> {
  static const String _selectedTabKey = 'mess_menu_selected_tab';

  MessMenuTab _selectedTab = MessMenuTab.regular;
  bool _didLoadTab = false;

  @override
  void initState() {
    super.initState();
    _loadSelection();
  }

  Future<void> _loadSelection() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final String? stored = prefs.getString(_selectedTabKey);
    setState(() {
      _selectedTab = stored == MessMenuTab.special.name
          ? MessMenuTab.special
          : MessMenuTab.regular;
      _didLoadTab = true;
    });
  }

  Future<void> _setSelection(MessMenuTab tab) async {
    if (tab == _selectedTab) return;
    setState(() => _selectedTab = tab);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedTabKey, tab.name);
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now =
        ref.watch(scheduleClockProvider).value ?? DateTime.now();
    final DateTime serviceDate = _serviceDateFor(now);
    final MessMenuHostel selectedHostel = messMenuHostelFromCode(
      ref.watch(
        userPreferencesProvider.select((prefs) => prefs.messMenuHostelType),
      ),
    );
    final AsyncValue<MessMenuCacheResult> menu = ref.watch(
      messMenuProvider(serviceDate),
    );

    return menu.when(
      loading: () => const _MessMenuSkeleton(),
      error: (_, _) => const _MessMenuUnavailableCard(
        message: 'Could not read the saved menu. Sync again from Settings.',
      ),
      data: (MessMenuCacheResult state) {
        final MessMenuBundle? bundle = state.bundle;
        if (bundle == null) {
          return _MessMenuUnavailableCard(
            message:
                state.message ??
                'No menu has been saved yet. Sync from Settings to download it.',
            lastSyncedAt: state.lastSyncedAt,
          );
        }

        final MessMenuTab effectiveTab = bundle.hasSpecial
            ? _selectedTab
            : MessMenuTab.regular;
        final MessMenuEntry activeEntry = bundle.entryFor(effectiveTab);
        final _MealWindow mealWindow = _mealWindowFor(now);

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Material(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => showMessMenuDetailSheet(
                context,
                bundle,
                effectiveTab,
                selectedHostel,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _MessMenuContent(
                  bundle: bundle,
                  selectedTab: effectiveTab,
                  hostel: selectedHostel,
                  entry: activeEntry,
                  mealWindow: mealWindow,
                  didLoadTab: _didLoadTab,
                  onTabChanged: _setSelection,
                  lastSyncedAt: state.lastSyncedAt,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  DateTime _serviceDateFor(DateTime now) {
    final DateTime threshold = DateTime(now.year, now.month, now.day, 21);
    if (now.isBefore(threshold)) {
      return DateTime(now.year, now.month, now.day);
    }
    return DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
  }

  _MealWindow _mealWindowFor(DateTime now) {
    final DateTime day = DateTime(now.year, now.month, now.day);
    final DateTime breakfastStart = DateTime(
      day.year,
      day.month,
      day.day,
      7,
      15,
    );
    final DateTime breakfastEnd = DateTime(day.year, day.month, day.day, 9);
    final DateTime lunchStart = DateTime(day.year, day.month, day.day, 12, 30);
    final DateTime lunchEnd = DateTime(day.year, day.month, day.day, 14, 15);
    final DateTime snacksStart = DateTime(day.year, day.month, day.day, 16, 45);
    final DateTime snacksEnd = DateTime(day.year, day.month, day.day, 18, 15);
    final DateTime dinnerStart = DateTime(day.year, day.month, day.day, 19, 15);
    final DateTime dinnerEnd = DateTime(day.year, day.month, day.day, 21);

    if (now.isBefore(breakfastStart)) {
      return _MealWindow(
        meal: MessMeal.breakfast,
        status: 'Next up',
        window: _timeWindowLabel(breakfastStart, breakfastEnd),
      );
    }
    if (!now.isAfter(breakfastEnd)) {
      return _MealWindow(
        meal: MessMeal.breakfast,
        status: 'Now serving',
        window: _timeWindowLabel(breakfastStart, breakfastEnd),
      );
    }
    if (now.isBefore(lunchStart)) {
      return _MealWindow(
        meal: MessMeal.lunch,
        status: 'Next up',
        window: _timeWindowLabel(lunchStart, lunchEnd),
      );
    }
    if (!now.isAfter(lunchEnd)) {
      return _MealWindow(
        meal: MessMeal.lunch,
        status: 'Now serving',
        window: _timeWindowLabel(lunchStart, lunchEnd),
      );
    }
    if (now.isBefore(snacksStart)) {
      return _MealWindow(
        meal: MessMeal.snacks,
        status: 'Next up',
        window: _timeWindowLabel(snacksStart, snacksEnd),
      );
    }
    if (!now.isAfter(snacksEnd)) {
      return _MealWindow(
        meal: MessMeal.snacks,
        status: 'Now serving',
        window: _timeWindowLabel(snacksStart, snacksEnd),
      );
    }
    if (now.isBefore(dinnerStart)) {
      return _MealWindow(
        meal: MessMeal.dinner,
        status: 'Next up',
        window: _timeWindowLabel(dinnerStart, dinnerEnd),
      );
    }
    if (!now.isAfter(dinnerEnd)) {
      return _MealWindow(
        meal: MessMeal.dinner,
        status: 'Now serving',
        window: _timeWindowLabel(dinnerStart, dinnerEnd),
      );
    }

    final DateTime tomorrowBreakfastStart = breakfastStart.add(
      const Duration(days: 1),
    );
    final DateTime tomorrowBreakfastEnd = breakfastEnd.add(
      const Duration(days: 1),
    );
    return _MealWindow(
      meal: MessMeal.breakfast,
      status: 'Tomorrow',
      window: _timeWindowLabel(tomorrowBreakfastStart, tomorrowBreakfastEnd),
    );
  }

  String _timeWindowLabel(DateTime start, DateTime end) {
    final DateFormat fmt = DateFormat('h:mm a');
    return '${fmt.format(start)} to ${fmt.format(end)}';
  }
}

class _MessMenuContent extends StatelessWidget {
  const _MessMenuContent({
    required this.bundle,
    required this.selectedTab,
    required this.hostel,
    required this.entry,
    required this.mealWindow,
    required this.didLoadTab,
    required this.onTabChanged,
    required this.lastSyncedAt,
  });

  final MessMenuBundle bundle;
  final MessMenuTab selectedTab;
  final MessMenuHostel hostel;
  final MessMenuEntry entry;
  final _MealWindow mealWindow;
  final bool didLoadTab;
  final ValueChanged<MessMenuTab> onTabChanged;
  final DateTime? lastSyncedAt;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final String dateLabel = DateFormat('EEE, d MMM').format(bundle.date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.restaurant_rounded,
                color: cs.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Mess Menu',
                          style: tt.titleMedium?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.end,
                        children: <Widget>[
                          _DateChip(label: dateLabel),
                          _HostelChip(label: hostel.label),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _subtitleFor(mealWindow),
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                  if (lastSyncedAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Saved offline • synced ${DateFormat('d MMM, h:mm a').format(lastSyncedAt!)}',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: <Widget>[
            Expanded(
              child: SegmentedButton<MessMenuTab>(
                segments: <ButtonSegment<MessMenuTab>>[
                  ButtonSegment<MessMenuTab>(
                    value: MessMenuTab.regular,
                    label: Text(MessMenuTab.regular.label),
                    icon: const Icon(Icons.restaurant_menu_rounded, size: 18),
                  ),
                  ButtonSegment<MessMenuTab>(
                    value: MessMenuTab.special,
                    label: Text(MessMenuTab.special.label),
                    icon: const Icon(Icons.star_rounded, size: 18),
                  ),
                ],
                selected: <MessMenuTab>{selectedTab},
                onSelectionChanged: didLoadTab
                    ? (Set<MessMenuTab> selection) {
                        if (selection.isEmpty) return;
                        onTabChanged(selection.first);
                      }
                    : null,
                style: SegmentedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: cs.surfaceContainerHighest,
                  foregroundColor: cs.onSurfaceVariant,
                  selectedBackgroundColor: cs.primaryContainer,
                  selectedForegroundColor: cs.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      mealWindow.title,
                      style: tt.labelLarge?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    mealWindow.window,
                    style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _previewItems(entry.menuFor(mealWindow.meal.label)),
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _subtitleFor(_MealWindow mealWindow) {
    if (mealWindow.status == 'Tomorrow') {
      return 'Tomorrow: ${mealWindow.title}';
    }
    return '${mealWindow.status} • ${mealWindow.window}';
  }

  String _previewItems(String value) {
    final List<String> items = value
        .split(',')
        .map((String item) => item.trim())
        .where((String item) => item.isNotEmpty)
        .toList(growable: false);

    if (items.isEmpty) return '—';
    if (items.length <= 2) return items.join(' · ');
    return '${items.take(2).join(' · ')} · +${items.length - 2} more';
  }
}

class _MealWindow {
  const _MealWindow({
    required this.meal,
    required this.status,
    required this.window,
  });

  final MessMeal meal;
  final String status;
  final String window;

  String get title => meal.label;
}

enum MessMeal { breakfast, lunch, snacks, dinner }

extension MessMealX on MessMeal {
  String get label => switch (this) {
    MessMeal.breakfast => 'Breakfast',
    MessMeal.lunch => 'Lunch',
    MessMeal.snacks => 'Snacks',
    MessMeal.dinner => 'Dinner',
  };
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: cs.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _HostelChip extends StatelessWidget {
  const _HostelChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: cs.onSecondaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MessMenuSkeleton extends StatelessWidget {
  const _MessMenuSkeleton();

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 14,
                        width: 110,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 10,
                        width: 180,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 42,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              height: 110,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessMenuUnavailableCard extends StatelessWidget {
  const _MessMenuUnavailableCard({required this.message, this.lastSyncedAt});

  final String message;
  final DateTime? lastSyncedAt;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.restaurant_rounded,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        lastSyncedAt == null
                            ? 'Offline copy unavailable'
                            : 'Saved offline menu',
                        style: tt.titleMedium?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lastSyncedAt == null
                            ? 'Sync from Settings to download a copy'
                            : 'Synced ${DateFormat('d MMM, h:mm a').format(lastSyncedAt!)}',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message,
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
