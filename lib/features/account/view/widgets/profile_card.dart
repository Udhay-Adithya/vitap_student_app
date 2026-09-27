import 'package:flutter/material.dart';
import 'package:flutter_m3shapes_extended/flutter_m3shapes_extended.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vit_ap_student_app/core/common/widget/loader.dart';
import 'package:vit_ap_student_app/core/constants/analytics_constants.dart';
import 'package:vit_ap_student_app/core/models/grade_history.dart';
import 'package:vit_ap_student_app/core/models/user.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/providers/user_preferences_notifier.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/core/utils/avatar_image.dart';
import 'package:vit_ap_student_app/features/auth/view/pages/semester_selection_page.dart';
import 'package:vit_ap_student_app/features/auth/viewmodel/semester_viewmodel.dart';
import 'package:vit_ap_student_app/features/onboarding/view/pages/profile_picture_page.dart';

/// The header of the account page: the avatar with the two numbers worth
/// knowing at a glance pinned to its corners, the student's name, and the
/// semester switcher.
///
/// The badges are only shown once the grade history has been fetched. Nothing
/// takes their place while it hasn't — an empty badge reads as a zero.
///
/// The profile page passes [isProfile], which keeps the plain avatar and the
/// avatar picker instead: the stats already have a home on the account page,
/// and the profile page is a list of details rather than a summary.
class ProfileCard extends ConsumerStatefulWidget {
  const ProfileCard({super.key, this.isProfile = false, required this.user});

  final User? user;
  final bool isProfile;

  @override
  ConsumerState<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends ConsumerState<ProfileCard> {
  String? _selectedSemesterName;

  @override
  void initState() {
    super.initState();
    _loadSelectedSemester();
  }

  Future<void> _loadSelectedSemester() async {
    final semester = await ref
        .read(semesterViewModelProvider.notifier)
        .getSelectedSemester();
    if (mounted && semester != null) {
      setState(() {
        _selectedSemesterName = semester.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final userPrefs = ref.watch(userPreferencesProvider);
    final isLoading = ref.watch(
      semesterViewModelProvider.select((val) => val?.isLoading == true),
    );
    final String studentName =
        widget.user?.profile.target?.studentName ?? 'N/A';
    final String? base64Pfp = widget.user?.profile.target?.base64Pfp;

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: widget.isProfile
              ? <Widget>[
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: avatarImageProvider(
                      userPrefs.pfpPath,
                      base64Pfp,
                    ),
                  ),
                  TextButton(
                    style: const ButtonStyle(),
                    onPressed: () {
                      ref
                          .read(analyticsServiceProvider)
                          .logEvent(
                            AnalyticsEvents.profilePictureChangeStarted,
                          );
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (builder) => const ProfilePicturePage(
                            instructionText:
                                'Choose a profile picture that best represents you',
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Change avatar',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    studentName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                ]
              : <Widget>[
                  _AvatarWithStats(
                    avatar: avatarImageProvider(userPrefs.pfpPath, base64Pfp),
                    gradeHistory:
                        widget.user?.profile.target?.gradeHistory.target,
                    isPrivate: userPrefs.isPrivacyEnabled,
                    onTogglePrivacy: () => ref
                        .read(userPreferencesProvider.notifier)
                        .togglePrivacyMode(!userPrefs.isPrivacyEnabled),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    studentName,
                    textAlign: TextAlign.center,
                    style: tt.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (isLoading)
                    const Loader()
                  else ...[
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: cs.surfaceContainerHigh,
                      ),
                      child: Text(
                        _selectedSemesterName ?? 'Select Semester',
                        style: tt.labelMedium!.copyWith(color: cs.primary),
                      ),
                    ),
                    const SizedBox(height: 2),
                    TextButton(
                      style: const ButtonStyle(),
                      onPressed: () async {
                        final credentials = await ref
                            .read(currentUserProvider.notifier)
                            .getSavedCredentials();
                        if (credentials == null || !context.mounted) return;
                        await Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => SemesterSelectionPage(
                              registrationNumber:
                                  credentials.registrationNumber,
                              password: credentials.password,
                            ),
                          ),
                        );
                        await _loadSelectedSemester();
                      },
                      child: const Text(
                        'Change semster',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ],
        ),
      ),
    );
  }
}

/// The avatar, clipped to a Material shape, with a stat badge tucked into two
/// opposite corners.
class _AvatarWithStats extends StatelessWidget {
  const _AvatarWithStats({
    required this.avatar,
    required this.gradeHistory,
    required this.isPrivate,
    required this.onTogglePrivacy,
  });

  final ImageProvider avatar;
  final GradeHistory? gradeHistory;

  /// Whether Privacy Mode is on. The badges stay — they are half the shape of
  /// this header — but their numbers give way to an icon, so a glance over the
  /// shoulder gets nothing and the layout does not shift.
  final bool isPrivate;

  /// Tapping either badge flips Privacy Mode. The numbers are what the mode is
  /// about, so they are the most obvious place to reach for it — the settings
  /// switch stays as the discoverable copy.
  final VoidCallback onTogglePrivacy;

  /// VTOP reports credits as a decimal string ("128.0"); only the whole
  /// credits are meaningful to show.
  String get _creditsEarned =>
      (int.tryParse(gradeHistory!.creditsEarned.split('.').first) ?? 0)
          .toString();

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: MediaQuery.widthOf(context) / 1.75,
      height: MediaQuery.widthOf(context) / 1.75,
      child: Stack(
        children: [
          Positioned.fill(
            // The colour fills behind the avatar as well as clipping it: the
            // avatar assets are circular artwork on a transparent square, so
            // without it the shape's corners would just be empty. The VTOP
            // photo is an opaque rectangle and covers the shape on its own.
            child: M3EContainer(
              Shapes.pill,
              color: cs.surfaceContainerHighest,
              child: Image(image: avatar, fit: BoxFit.cover),
            ),
          ),
          if (gradeHistory != null) ...[
            Positioned(
              left: 0,
              top: 0,
              child: _StatBadge(
                value: isPrivate ? null : gradeHistory!.cgpa,
                label: 'cgpa',
                shape: Shapes.sunny,
                background: cs.tertiaryContainer,
                foreground: cs.onTertiaryContainer,
                angle: -0.14,
                onTap: onTogglePrivacy,
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: _StatBadge(
                value: isPrivate ? null : _creditsEarned,
                label: 'credits',
                shape: Shapes.c9SidedCookie,
                background: cs.primaryContainer,
                foreground: cs.onPrimaryContainer,
                angle: 0.14,
                onTap: onTogglePrivacy,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A tilted shape badge showing one stat: the number, with its label under it.
///
/// A null [value] is the Privacy Mode state — the badge keeps its shape, size
/// and label and shows a closed eye where the number would be. Tapping the
/// badge calls [onTap], which flips that mode.
class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.value,
    required this.label,
    required this.shape,
    required this.background,
    required this.foreground,
    required this.angle,
    required this.onTap,
  });

  static const double _size = 78;

  final String? value;
  final String label;
  final Shapes shape;
  final Color background;
  final Color foreground;

  /// Rotation in radians. A few degrees off-axis is what keeps the pair from
  /// reading as two buttons stuck to the picture.
  final double angle;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme tt = Theme.of(context).textTheme;

    return Transform.rotate(
      angle: angle,
      child: M3EContainer(
        shape,
        width: _size,
        height: _size,
        color: background,
        // The ink sits inside the shape rather than around it, so the ripple is
        // clipped by M3EContainer's own clipper and paints above its fill
        // instead of behind it on the nearest Material ancestor.
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            child: Tooltip(
              message: value == null
                  ? 'Show CGPA and credits'
                  : 'Hide CGPA and credits',
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (value == null)
                    Icon(
                      Icons.visibility_off_rounded,
                      size: 22,
                      color: foreground,
                      semanticLabel: 'Hidden by Privacy Mode',
                    )
                  else
                    Text(
                      value!,
                      style: GoogleFonts.unbounded(
                        textStyle: tt.titleMedium,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: foreground,
                      ),
                    ),
                  Text(
                    label,
                    style: tt.labelSmall?.copyWith(color: foreground),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
