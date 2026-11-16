import 'package:flutter/material.dart';
import 'package:vit_ap_student_app/core/theme/app_theme_enum.dart';

class ThemePreviewCard extends StatelessWidget {
  final AppTheme theme;
  final bool isDarkMode;
  final bool isSelected;
  final VoidCallback onTap;

  const ThemePreviewCard({
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
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview UI Container
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(13),
                    topRight: Radius.circular(13),
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // Top row with 3 icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildIconBox(
                          colorScheme.primaryContainer,
                          colorScheme.onPrimaryContainer,
                        ),
                        _buildIconBox(
                          colorScheme.secondaryContainer,
                          colorScheme.onSecondaryContainer,
                        ),
                        _buildIconBox(
                          colorScheme.tertiaryContainer,
                          colorScheme.onTertiaryContainer,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Bottom row with 3 icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildIconBox(
                          colorScheme.primaryContainer,
                          colorScheme.onPrimaryContainer,
                        ),
                        _buildIconBox(
                          colorScheme.secondaryContainer,
                          colorScheme.onSecondaryContainer,
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.arrow_forward,
                            color: colorScheme.onPrimary,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Theme name label
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(13),
                  bottomRight: Radius.circular(13),
                ),
              ),
              child: Text(
                theme.displayName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconBox(Color backgroundColor, Color iconColor) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.circle, color: iconColor, size: 16),
    );
  }
}
