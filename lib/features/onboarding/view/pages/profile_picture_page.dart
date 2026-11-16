import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/providers/user_preferences_notifier.dart';
import 'package:vit_ap_student_app/core/utils/avatar_image.dart';
import 'package:vit_ap_student_app/core/utils/theme_switch_button.dart';

/// The avatar picker.
///
/// The student's own VTOP photo leads the grid when there is one — it comes
/// from the profile already cached in ObjectBox, so opening this page never
/// fetches and never risks an OTP prompt. Accounts VTOP has no photo for, and
/// demo mode, simply see the illustrated avatars as before.
class ProfilePicturePage extends ConsumerWidget {
  final String instructionText;
  final Widget? nextPage;

  const ProfilePicturePage({
    super.key,
    required this.instructionText,
    this.nextPage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final userPrefs = ref.watch(userPreferencesProvider);
    final String? base64Pfp = ref.watch(
      currentUserProvider.select((user) => user?.profile.target?.base64Pfp),
    );
    final List<String> imagePaths = avatarChoices(base64Pfp);

    final int numRows = (imagePaths.length / 4).ceil();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text(
          'Select an Avatar',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
        ),
        actions: const [ThemeSwitchButton()],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                instructionText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 30),
              CircleAvatar(
                radius: 45,
                backgroundColor: cs.surfaceContainerHighest,
                child: CircleAvatar(
                  radius: 45,
                  backgroundImage: avatarImageProvider(
                    userPrefs.pfpPath,
                    base64Pfp,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Column(
                children: List.generate(numRows, (rowIndex) {
                  final int startIndex = rowIndex * 4;
                  int endIndex = (rowIndex + 1) * 4;
                  if (endIndex > imagePaths.length) {
                    endIndex = imagePaths.length;
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(endIndex - startIndex, (index) {
                      final int imageIndex = startIndex + index;
                      final String path = imagePaths[imageIndex];
                      return GestureDetector(
                        onTap: () {
                          ref
                              .read(userPreferencesProvider.notifier)
                              .updatePreferences(
                                userPrefs.copyWith(pfpPath: path),
                              );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: CircleAvatar(
                            radius: 38,
                            backgroundColor: userPrefs.pfpPath == path
                                ? cs.primary
                                : Colors.transparent,
                            child: CircleAvatar(
                              radius: 34,
                              backgroundImage: avatarImageProvider(
                                path,
                                base64Pfp,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.secondaryContainer,
                  minimumSize: Size(MediaQuery.sizeOf(context).width / 2, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(60.0),
                  ),
                ),
                onPressed: () {
                  if (nextPage == null) {
                    Navigator.pop(context);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(builder: (builder) => nextPage!),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
