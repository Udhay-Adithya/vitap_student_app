import 'package:flutter/material.dart';
import 'package:vit_ap_student_app/core/theme/app_theme_enum.dart';

class CircularThemeIndicator extends StatelessWidget {
  final AppTheme theme;
  final bool isDarkMode;
  final bool isSelected;
  final VoidCallback onTap;

  const CircularThemeIndicator({
    super.key,
    required this.theme,
    required this.isDarkMode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: theme.seedColor,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
    );

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 3,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 0.5,
                  ),
                ),
                child: ClipOval(
                  child: Column(
                    children: [
                      // Top half - Primary color
                      Expanded(
                        child: Container(color: colorScheme.primaryContainer),
                      ),
                      // Bottom half split vertically
                      Expanded(
                        child: Row(
                          children: [
                            // Bottom left - Secondary color
                            Expanded(
                              child: Container(
                                color: colorScheme.surfaceContainer,
                              ),
                            ),
                            // Bottom right - Tertiary color
                            Expanded(
                              child: Container(color: colorScheme.primary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            theme.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
