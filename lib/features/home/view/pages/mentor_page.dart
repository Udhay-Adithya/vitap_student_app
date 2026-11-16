import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vit_ap_student_app/core/common/widget/user_info_tile.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/core/utils/launch_contact.dart';
import 'package:vit_ap_student_app/core/utils/show_snackbar.dart';

class MentorPage extends ConsumerStatefulWidget {
  const MentorPage({super.key});

  @override
  ConsumerState<MentorPage> createState() => _MentorPageState();
}

class _MentorPageState extends ConsumerState<MentorPage> {
  @override
  void initState() {
    super.initState();
    ref.read(analyticsServiceProvider).logScreen('MentorPage');
  }

  /// Runs a launcher and says so when the device has nothing to handle it,
  /// rather than leaving a tap that appears to do nothing.
  Future<void> _open(Future<bool> Function() launcher, String target) async {
    final bool launched = await launcher();
    if (launched || !mounted) return;
    showSnackBar(context, 'No $target on this device', SnackBarType.warning);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final mentor = user?.profile.target?.mentorDetails.target;
    final String email = mentor?.facultyEmail ?? 'N/A';
    final String mobile = mentor?.facultyMobileNumber ?? 'N/A';

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: Text(
          'Mentor',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage(
                        'assets/images/pfp/default.png',
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      user?.profile.target?.mentorDetails.target?.facultyName ??
                          'N/A',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // A label, not a control: this was a TextButton with an
                    // empty onPressed, so it rippled under the finger and did
                    // nothing.
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        user?.profile.target?.mentorDetails.target?.facultyId ??
                            'N/A',
                        style: Theme.of(context).textTheme.labelMedium!
                            .copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            UserInfoTile(
              'Full Name',
              user?.profile.target?.mentorDetails.target?.facultyName ?? 'N/A',
              copyable: true,
            ),
            UserInfoTile(
              'Department',
              user?.profile.target?.mentorDetails.target?.facultyDepartment ??
                  'N/A',
            ),
            UserInfoTile(
              'Designation',
              user?.profile.target?.mentorDetails.target?.facultyDesignation ??
                  'N/A',
            ),
            // Contact rows lead with the thing you actually want: writing to
            // your mentor, or calling them. Copying is still there beside it.
            UserInfoTile(
              'Email',
              email,
              copyable: true,
              action: UserInfoAction(
                icon: Iconsax.sms_copy,
                tooltip: 'Send an email',
                onTap: () => _open(() => launchEmail(email), 'mail app'),
              ),
            ),
            UserInfoTile(
              'Cabin',
              user?.profile.target?.mentorDetails.target?.cabin ?? 'N/A',
              copyable: true,
            ),
            UserInfoTile(
              'Mobile Number',
              mobile,
              copyable: true,
              action: UserInfoAction(
                icon: Iconsax.call_copy,
                tooltip: 'Call',
                onTap: () => _open(() => launchPhone(mobile), 'dialer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
