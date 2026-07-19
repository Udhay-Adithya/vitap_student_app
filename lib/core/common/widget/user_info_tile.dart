import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserInfoTile extends StatelessWidget {
  final String title;
  final String description;
  final double gap;
  const UserInfoTile(
    this.title,
    this.description, {
    this.gap = 12.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final displayDescription = description == '' ? 'N/A' : description;

    return GestureDetector(
      onLongPress: () async {
        if (displayDescription != 'N/A') {
          await Clipboard.setData(ClipboardData(text: displayDescription));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$title copied to clipboard'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 0),
          Text(
            displayDescription,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(height: gap)
        ],
      ),
    );
  }
}
