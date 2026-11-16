import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vit_ap_student_app/core/providers/theme_mode_notifier.dart';
import 'package:vit_ap_student_app/core/providers/user_preferences_notifier.dart';

class ThemeSwitchButton extends ConsumerWidget {
  const ThemeSwitchButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLight = !(ref.watch(userPreferencesProvider).isDarkModeEnabled);
    final notifier = ref.read(themeModeProvider.notifier);

    return IconButton(
      icon: Icon(
        isLight ? Iconsax.moon : Iconsax.sun_1,
        color: isLight ? Colors.indigo : Colors.yellow,
      ),
      onPressed: notifier.toggleTheme,
    );
  }
}
