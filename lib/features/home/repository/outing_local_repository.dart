import 'package:flutter/foundation.dart';
import 'package:objectbox/objectbox.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/features/home/model/general_outing_report.dart';
import 'package:vit_ap_student_app/features/home/model/weekend_outing_report.dart';
import 'package:vit_ap_student_app/init_dependencies.dart';

part 'outing_local_repository.g.dart';

@riverpod
OutingLocalRepository outingLocalRepository(Ref ref) {
  final store = serviceLocator<Store>();
  return OutingLocalRepository(
    generalOutingBox: store.box<GeneralOutingReport>(),
    weekendOutingBox: store.box<WeekendOutingReport>(),
  );
}

class OutingLocalRepository {
  final Box<GeneralOutingReport> generalOutingBox;
  final Box<WeekendOutingReport> weekendOutingBox;

  OutingLocalRepository({
    required this.generalOutingBox,
    required this.weekendOutingBox,
  });

  // General Outing Methods
  List<GeneralOutingReport> getGeneralOutingReports() {
    try {
      return generalOutingBox.getAll();
    } catch (e) {
      debugPrint('Error getting general outing reports from cache: $e');
      return [];
    }
  }

  Future<void> saveGeneralOutingReports(
    List<GeneralOutingReport> reports,
  ) async {
    try {
      // Clear existing data and save new
      generalOutingBox.removeAll();
      generalOutingBox.putMany(reports);
      debugPrint('Saved ${reports.length} general outing reports to cache');
    } catch (e) {
      debugPrint('Error saving general outing reports to cache: $e');
    }
  }

  Future<void> clearGeneralOutingReports() async {
    try {
      generalOutingBox.removeAll();
    } catch (e) {
      debugPrint('Error clearing general outing reports cache: $e');
    }
  }

  // Weekend Outing Methods
  List<WeekendOutingReport> getWeekendOutingReports() {
    try {
      return weekendOutingBox.getAll();
    } catch (e) {
      debugPrint('Error getting weekend outing reports from cache: $e');
      return [];
    }
  }

  Future<void> saveWeekendOutingReports(
    List<WeekendOutingReport> reports,
  ) async {
    try {
      // Clear existing data and save new
      weekendOutingBox.removeAll();
      weekendOutingBox.putMany(reports);
      debugPrint('Saved ${reports.length} weekend outing reports to cache');
    } catch (e) {
      debugPrint('Error saving weekend outing reports to cache: $e');
    }
  }

  Future<void> clearWeekendOutingReports() async {
    try {
      weekendOutingBox.removeAll();
    } catch (e) {
      debugPrint('Error clearing weekend outing reports cache: $e');
    }
  }

  // Clear all outing data
  Future<void> clearAllOutingData() async {
    await clearGeneralOutingReports();
    await clearWeekendOutingReports();
  }

  // Check if cache has data
  bool hasGeneralOutingData() => generalOutingBox.count() > 0;
  bool hasWeekendOutingData() => weekendOutingBox.count() > 0;
}
