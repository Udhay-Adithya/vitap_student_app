import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/models/timetable.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/services/home_widget_service.dart';

part 'schedule_home_widget_notifier.g.dart';

@Riverpod(keepAlive: true)
class ScheduleHomeWidgetNotifier extends _$ScheduleHomeWidgetNotifier {
  @override
  Timetable? build() {
    final user = ref.read(currentUserProvider);
    return user?.timetable.target;
  }

  Future<void> saveTimetable(Timetable timetableData) async {
    try {
      await ref
          .read(homeWidgetServiceProvider)
          .save('timetable', json.encode(timetableData.toJson()));
      state = timetableData;
    } catch (e, stackTrace) {
      debugPrint('Error saving timetable: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  Future<void> updateWidget() async {
    try {
      await ref.read(homeWidgetServiceProvider).refresh();
    } catch (e, stackTrace) {
      debugPrint('Error updating widget: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  Future<void> initializeTimetable() async {
    final user = ref.read(currentUserProvider);
    final timetable = user?.timetable.target;

    if (user == null || timetable == null) return;

    await saveTimetable(timetable);
    await updateWidget();
  }

  Future<void> forceRefresh() async {
    await initializeTimetable();
  }

  /// Clears saved timetable data from the widget storage
  Future<void> clearTimetable() async {
    try {
      await ref.read(homeWidgetServiceProvider).save('timetable', '');
      state = null;
    } catch (e, stackTrace) {
      debugPrint('Error clearing timetable: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// For testing and internal use: reads the saved timetable from widget storage
  Future<Timetable?> readSavedTimetable() async {
    try {
      final jsonString = await ref
          .read(homeWidgetServiceProvider)
          .read('timetable');
      if (jsonString == null || jsonString.isEmpty) return null;
      return Timetable.fromJson(
        json.decode(jsonString) as Map<String, dynamic>,
      );
    } catch (e, stackTrace) {
      debugPrint('Error reading saved timetable: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }
}
