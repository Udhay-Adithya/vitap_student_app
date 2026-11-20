import 'dart:convert';
import 'dart:io';
import 'package:vit_ap_student_app/core/constants/analytics_constants.dart';
import 'package:vit_ap_student_app/core/constants/server_constants.dart';
import 'package:vit_ap_student_app/core/models/grade_history.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';

import 'launch_web.dart';

String generateCgpaCalculatorUrl(GradeHistory gradeHistory) =>
    cgpaCalculatorUrlFor(gradeHistory.toJson());

/// The calculator link carrying [payload], gzipped and base64url-encoded.
///
/// The payload is the student's whole grade history, so it goes in the URL
/// fragment. Browsers never send the fragment to the server, which keeps it out
/// of the calculator host's request logs; the report page decodes it in the
/// browser. Taking the JSON rather than a [GradeHistory] keeps this testable
/// without an ObjectBox store.
String cgpaCalculatorUrlFor(Map<String, dynamic> payload) {
  final compressed = gzip.encode(utf8.encode(jsonEncode(payload)));
  final encodedData = base64Url.encode(compressed);
  return '${ServerConstants.cgpaCalculatorReportUrl}#data=$encodedData';
}

void openCgpaCalculator(
  GradeHistory gradeHistory,
  AnalyticsService analytics,
) async {
  final url = generateCgpaCalculatorUrl(gradeHistory);

  await directToWeb(url);

  analytics.logEvent(AnalyticsEvents.cgpaCalculatorOpened, {
    AnalyticsParams.sizeBytes: url.length,
  });
}
