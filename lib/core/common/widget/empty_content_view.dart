import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmptyContentView extends StatelessWidget {
  final String primaryText;
  final String secondaryText;
  const EmptyContentView({
    super.key,
    required this.primaryText,
    required this.secondaryText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Lottie.asset(
              'assets/lottie/empty.json',
              frameRate: const FrameRate(60),
              width: 275,
            ),
          ),
          Text(
            primaryText,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            secondaryText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
