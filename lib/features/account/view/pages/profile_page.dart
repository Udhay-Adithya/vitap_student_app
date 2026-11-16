import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_ap_student_app/core/common/widget/user_info_tile.dart';
import 'package:vit_ap_student_app/core/models/user.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/features/account/view/widgets/profile_card.dart';

class ProfilePage extends ConsumerStatefulWidget {
  final User? user;
  const ProfilePage(this.user, {super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    ref.read(analyticsServiceProvider).logScreen('ProfilePage');
  }

  /// Profiles cached before the registration number was scraped store an empty
  /// string, so fall back rather than rendering a blank tile.
  String get _registrationNumber {
    final regNo = widget.user?.profile.target?.registrationNumber;
    return (regNo == null || regNo.isEmpty) ? 'N/A' : regNo;
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ProfileCard(user: widget.user, isProfile: true),
          const SizedBox(height: 48),
          // Copyable where the value is something you end up pasting into a
          // form or a message. Blood group, gender and date of birth are read,
          // not transcribed.
          UserInfoTile(
            'Full Name',
            widget.user?.profile.target?.studentName ?? 'N/A',
            copyable: true,
          ),
          UserInfoTile(
            'Email',
            widget.user?.profile.target?.email ?? 'N/A',
            copyable: true,
          ),
          UserInfoTile(
            'Date of Birth',
            widget.user?.profile.target?.dob ?? 'N/A',
          ),
          UserInfoTile(
            'Registration Number',
            _registrationNumber,
            copyable: true,
          ),
          UserInfoTile(
            'Application Number',
            widget.user?.profile.target?.applicationNumber ?? 'N/A',
            copyable: true,
          ),
          UserInfoTile(
            'Blood Group',
            widget.user?.profile.target?.bloodGroup ?? 'N/A',
          ),
          UserInfoTile('Gender', widget.user?.profile.target?.gender ?? 'N/A'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: Text(
          'Profile',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      body: _buildProfileTab(),
    );
  }
}
