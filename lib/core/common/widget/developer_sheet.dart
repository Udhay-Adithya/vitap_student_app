import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:vit_ap_student_app/core/common/widget/loader.dart';
import 'package:vit_ap_student_app/core/utils/launch_web.dart';

/// Floating card with developer details, opened from a settings tile.

class DeveloperSheet extends StatefulWidget {
  final String name;
  final String githubUsername;
  final String description;
  final String? email;
  final String? linkedInUrl;

  const DeveloperSheet({
    super.key,
    required this.name,
    required this.githubUsername,
    required this.description,
    this.linkedInUrl,
    this.email,
  });

  static Future<void> show(
    BuildContext context, {
    String name = 'Udhay Adithya J',
    String githubUsername = 'Udhay-Adithya',
    String description = 'I build mobile apps',
    String? email,
    String? linkedInUrl,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DeveloperSheet(
        name: name,
        githubUsername: githubUsername,
        description: description,
        email: email,
        linkedInUrl: linkedInUrl,
      ),
    );
  }

  @override
  State<DeveloperSheet> createState() => _DeveloperSheetState();
}

class _DeveloperSheetState extends State<DeveloperSheet> {
  String? _profileImageUrl;
  bool _imageLoadError = false;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  void _loadProfileImage() {
    setState(() {
      _profileImageUrl =
          'https://github.com/${widget.githubUsername}.png?size=200';
    });
  }

  void _onImageError() {
    if (!_imageLoadError) {
      setState(() {
        _imageLoadError = true;
        _profileImageUrl = null;
      });
    }
  }

  Widget _buildProfileImage() {
    if (_imageLoadError || _profileImageUrl == null) {
      return const CircleAvatar(
        radius: 55,
        backgroundImage: AssetImage('assets/images/pfp/masked.png'),
      );
    }

    return CircleAvatar(
      radius: 55,
      backgroundImage: NetworkImage(_profileImageUrl!),
      onBackgroundImageError: (exception, stackTrace) {
        _onImageError();
      },
      child: _profileImageUrl == null ? const Loader() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme tt = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Material(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const SizedBox(width: 200, height: 140),
                            Positioned(bottom: 10, child: _buildProfileImage()),
                            Positioned(
                              top: -15,
                              right: 0,
                              child: Lottie.asset(
                                'assets/lottie/wave.json',
                                frameRate: const FrameRate(60),
                                width: 80,
                                repeat: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        widget.name,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.googleSansCode(
                          textStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0, bottom: 12),
                        child: Container(
                          height: 1,
                          width: 15,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 56,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(textStyle: tt.titleMedium),
                    onPressed: () async {
                      await directToWeb(
                        'https://github.com/${widget.githubUsername}',
                      );
                    },
                    icon: Image.asset(
                      'assets/images/icons/github.png',
                      height: 18,
                      color: Colors.white,
                    ),
                    label: const Text('Check my works'),
                  ),
                ),
                const SizedBox(height: 8),
                if (widget.linkedInUrl != null) ...[
                  SizedBox(
                    height: 56,
                    child: FilledButton.tonalIcon(
                      style: FilledButton.styleFrom(textStyle: tt.titleMedium),
                      onPressed: () async {
                        await directToWeb(widget.linkedInUrl!);
                      },
                      icon: Image.asset(
                        'assets/images/icons/linkedin.png',
                        height: 18,
                        color: Colors.black,
                      ),
                      label: const Text('Connect with me'),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (widget.email != null) ...[
                  SizedBox(
                    height: 56,
                    child: FilledButton.tonalIcon(
                      style: FilledButton.styleFrom(textStyle: tt.titleMedium),
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: widget.email!),
                        );
                      },
                      icon: const Icon(Icons.alternate_email_rounded),
                      label: const Text('Copy my email'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
