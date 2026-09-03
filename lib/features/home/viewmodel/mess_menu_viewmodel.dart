import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:vit_ap_student_app/core/providers/user_preferences_notifier.dart';
import 'package:vit_ap_student_app/features/home/model/mess_menu_cache_result.dart';
import 'package:vit_ap_student_app/features/home/model/mess_menu_hostel.dart';
import 'package:vit_ap_student_app/features/home/repository/mess_menu_repository.dart';

final messMenuRepositoryProvider = Provider<MessMenuRepository>(
  (ref) => const MessMenuRepository(),
);

final messMenuCacheRevisionProvider = StateProvider<int>((ref) => 0);

final messMenuProvider = FutureProvider.family<MessMenuCacheResult, DateTime>((
  ref,
  date,
) async {
  ref.watch<int>(messMenuCacheRevisionProvider);
  final String hostelCode = ref.watch(
    userPreferencesProvider.select((prefs) => prefs.messMenuHostelType),
  );
  final MessMenuHostel hostel = messMenuHostelFromCode(hostelCode);
  final MessMenuRepository repository = ref.watch(messMenuRepositoryProvider);
  return repository.loadForDate(date, hostel: hostel);
});
