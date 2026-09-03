import 'package:vit_ap_student_app/features/home/model/mess_menu_bundle.dart';

class MessMenuCacheResult {
  const MessMenuCacheResult({
    required this.bundle,
    required this.lastSyncedAt,
    required this.isStale,
    this.message,
  });

  final MessMenuBundle? bundle;
  final DateTime? lastSyncedAt;
  final bool isStale;
  final String? message;

  bool get hasData => bundle != null;
}
