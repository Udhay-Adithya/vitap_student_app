import 'package:flutter/material.dart';
import 'package:vit_ap_student_app/features/account/view/widgets/menu_section.dart';

/// A single row in a grouped settings list. Sized to the M3 list-item spec:
/// 56dp min height for one line, 72dp with a supporting line, 24dp leading
/// icon, 16dp horizontal padding. Corner radii are assigned by [MenuSection]
/// based on the tile's position within its group.
class MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? infoText;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? background;
  final Color? foreground;
  final BorderRadius? borderRadius;

  const MenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.infoText,
    this.trailing,
    this.onTap,
    this.background,
    this.foreground,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    final Color titleColor = foreground ?? cs.onSurface;
    final Color accessoryColor = foreground ?? cs.onSurfaceVariant;

    return Material(
      color: background ?? cs.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius:
            borderRadius ?? BorderRadius.circular(MenuSection.innerRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: subtitle == null ? 56 : 72),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(icon, size: 24, color: accessoryColor),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              overflow: TextOverflow.ellipsis,
                              style: tt.bodyLarge?.copyWith(color: titleColor),
                            ),
                          ),
                          if (infoText != null)
                            Tooltip(
                              message: infoText!,
                              triggerMode: TooltipTriggerMode.tap,
                              showDuration: const Duration(seconds: 5),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Icon(
                                  Icons.help_outline_rounded,
                                  color: cs.secondary,
                                  size: 18,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: tt.bodyMedium?.copyWith(
                            color: accessoryColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing!,
                ] else if (onTap != null) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right_rounded, color: accessoryColor),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
