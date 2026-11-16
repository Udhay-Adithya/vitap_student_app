import 'dart:convert';
import 'dart:io';
import 'package:vit_ap_student_app/core/constants/analytics_constants.dart';
import 'package:vit_ap_student_app/core/constants/server_constants.dart';
import 'package:vit_ap_student_app/core/models/grade_history.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';

import 'launch_web.dart';

String generateCgpaCalculatorUrl(GradeHistory gradeHistory) {
  final compressed = gzip.encode(
    utf8.encode(jsonEncode(gradeHistory.toJson())),
  );
  final encodedData = base64Url.encode(compressed);

  const baseUrl = ServerConstants.cgpaCalculatorBaseUrl;
  final url = '$baseUrl?data=$encodedData';

  return url;
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
