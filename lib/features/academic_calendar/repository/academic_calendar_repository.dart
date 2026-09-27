import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/error/failure.dart';
import 'package:vit_ap_student_app/core/error/failure_from.dart';
import 'package:vit_ap_student_app/core/models/academic_calendar.dart';
import 'package:vit_ap_student_app/core/models/credentials.dart';
import 'package:vit_ap_student_app/core/services/vtop_service.dart';
import 'package:vit_ap_student_app/init_dependencies.dart';
import 'package:vit_ap_student_app/objectbox.g.dart';
import 'package:vit_ap_student_app/src/rust/api/vtop_get_client.dart' as vtop;

part 'academic_calendar_repository.g.dart';

/// VTOP's default class group, "All Class Group (Combined)".
///
/// The other option is a single named group. Every student's calendar is in the
/// combined one, so the app does not ask.
const String defaultClassGroup = 'COMB';

@riverpod
AcademicCalendarRepository academicCalendarRepository(Ref ref) {
  final store = serviceLocator<Store>();
  return AcademicCalendarRepository(
    vtopService: serviceLocator<VtopClientService>(),
    store: store,
  );
}

class AcademicCalendarRepository {
  final VtopClientService vtopService;
  final Store store;

  AcademicCalendarRepository({required this.vtopService, required this.store});

  Box<AcademicCalendar> get _calendars => store.box<AcademicCalendar>();

  /// The stored calendar for a semester, or null if it has never been fetched.
  AcademicCalendar? cached({
    required String semSubId,
    String classGroupId = defaultClassGroup,
  }) {
    try {
      final query = _calendars
          .query(
            AcademicCalendar_.semesterId.equals(semSubId) &
                AcademicCalendar_.classGroupId.equals(classGroupId),
          )
          .build();
      final calendar = query.findFirst();
      query.close();
      return calendar;
    } catch (e) {
      debugPrint('Error reading the cached academic calendar: $e');
      return null;
    }
  }

  /// Fetches a semester's calendar from VTOP and replaces the stored copy.
  ///
  /// This is one request per month — seven or so for a semester — so it belongs
  /// behind an explicit refresh, never a page open.
  Future<Either<Failure, AcademicCalendar>> fetchCalendar({
    required String registrationNumber,
    required String password,
    required String semSubId,
    String classGroupId = defaultClassGroup,
  }) async {
    try {
      final credentials = Credentials(
        registrationNumber: registrationNumber,
        password: password,
        semSubId: semSubId,
      );

      final response = await vtopService.executeWithRetry(
        credentials: credentials,
        operation: (client) => vtop.fetchAcademicCalendar(
          client: client,
          semesterId: semSubId,
          classGroupId: classGroupId,
        ),
      );

      final calendar = AcademicCalendar.fromJson(
        json.decode(response) as Map<String, dynamic>,
      );

      if (calendar.days.isEmpty) {
        return Left(
          Failure('VTOP has not published a calendar for this semester yet'),
        );
      }

      calendar.fetchedAt = DateTime.now();
      _save(calendar);
      return Right(calendar);
    } catch (e) {
      return Left(
        failureFrom(
          e,
          unexpected: (error) =>
              'Failed to fetch the academic calendar: $error',
        ),
      );
    }
  }

  /// Replaces the stored calendar for this semester and class group.
  void _save(AcademicCalendar calendar) {
    try {
      saveCalendar(store, calendar);
    } catch (e) {
      debugPrint('Error saving the academic calendar: $e');
    }
  }
}

/// Stores [calendar], replacing any previous one for the same semester and
/// class group.
///
/// Kept out of the repository so it can be tested against a real store.
void saveCalendar(Store store, AcademicCalendar calendar) {
  final query = store
      .box<AcademicCalendar>()
      .query(
        AcademicCalendar_.semesterId.equals(calendar.semesterId) &
            AcademicCalendar_.classGroupId.equals(calendar.classGroupId),
      )
      .build();
  final previous = query.findFirst();
  query.close();

  removeCalendar(store, previous);
  store.box<AcademicCalendar>().put(calendar);
}

/// Deletes a calendar and everything hanging off it.
///
/// ObjectBox does not cascade a delete, so dropping only the calendar row would
/// leave roughly 180 days and as many events behind on every refresh.
void removeCalendar(Store store, AcademicCalendar? calendar) {
  if (calendar == null) return;

  final eventIds = <int>[];
  for (final day in calendar.days) {
    eventIds.addAll(day.events.map((event) => event.id).whereType<int>());
  }
  if (eventIds.isNotEmpty) store.box<CalendarEvent>().removeMany(eventIds);

  final dayIds = calendar.days.map((day) => day.id).whereType<int>().toList();
  if (dayIds.isNotEmpty) store.box<CalendarDay>().removeMany(dayIds);

  final monthIds = calendar.months
      .map((month) => month.id)
      .whereType<int>()
      .toList();
  if (monthIds.isNotEmpty) store.box<CalendarMonthRef>().removeMany(monthIds);

  final id = calendar.id;
  if (id != null) store.box<AcademicCalendar>().remove(id);
}
