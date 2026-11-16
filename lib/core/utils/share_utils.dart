import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vit_ap_student_app/core/utils/show_snackbar.dart';

class ShareUtils {
  ShareUtils._();

  static final ShareUtils _instance = ShareUtils._();
  static ShareUtils get instance => _instance;

  /// Share text content with success feedback
  Future<void> shareText(
    String text,
    BuildContext context, {
    String? subject,
  }) async {
    try {
      final result = await SharePlus.instance.share(
        ShareParams(text: text, subject: subject),
      );

      if (result.status == ShareResultStatus.success) {
        if (context.mounted) {
          showSnackBar(context, 'Thanks for sharing ❤️', SnackBarType.success);
        }
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, 'Failed to share content', SnackBarType.error);
      }
    }
  }

  /// Share app download link
  Future<void> shareApp(BuildContext context) async {
    const appShareText =
        '🚀🎓 Hey, Your academic life just got easier. Access all your details through the VIT-AP Student App. Download the app now! 📚👩‍🎓 https://vitap.udhay-adithya.me';
    await shareText(appShareText, context);
  }

  /// Share CGPA calculator URL
  Future<void> shareCgpaCalculator(
    String calculatorUrl,
    BuildContext context,
  ) async {
    const shareMessage =
        '📊 Check out my CGPA! Calculate yours using the VIT-AP CGPA Calculator: ';
    await shareText(
      '$shareMessage$calculatorUrl',
      context,
      subject: '📊 Check out my CGPA',
    );
  }
}
