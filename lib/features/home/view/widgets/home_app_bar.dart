import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/providers/user_preferences_notifier.dart';
import 'package:vit_ap_student_app/core/utils/avatar_image.dart';
import 'package:vit_ap_student_app/features/account/view/pages/profile_page.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/weather/weather_pill.dart';

/// Avatar on the left, weather on the right.
///
/// This used to be a 100pt expanding bar holding a 60pt avatar and two 60pt
/// circular shortcuts to the course page and faculties — both of which are
/// already Quick Access destinations. Navigation belongs to one system, so the
/// shortcuts are gone and the room they freed now carries the weather, which
/// previously cost a whole section of the home page.
///
/// A plain [SliverAppBar] with a raised [toolbarHeight] rather than a
/// [FlexibleSpaceBar]: the flexible bar's only extra trick is scaling its title
/// as you scroll, and a transform-scaled temperature and Lottie resample badly
/// where a bare avatar did not. Height is set directly instead, which gives the
/// avatar and the weather pill room to be their old size without the artefact.
class HomeAppBar extends ConsumerWidget {
  const HomeAppBar({super.key});

  /// Tall enough for a 56pt avatar with breathing room, and for the weather pill
  /// to carry the feels-like reading beside the temperature.
  static const double _height = 72;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPrefs = ref.watch(userPreferencesProvider);
    final String? base64Pfp = ref.watch(
      currentUserProvider.select((user) => user?.profile.target?.base64Pfp),
    );

    return SliverAppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: _height,
      titleSpacing: 16,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            // Opens the profile itself rather than switching to the Account
            // tab: tapping your own face should show your details, not the
            // settings list that happens to contain them.
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => ProfilePage(ref.read(currentUserProvider)),
              ),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundImage: avatarImageProvider(
                userPrefs.pfpPath,
                base64Pfp,
              ),
            ),
          ),
        ],
      ),
      actions: const <Widget>[WeatherPill(), SizedBox(width: 16)],
    );
  }
}
