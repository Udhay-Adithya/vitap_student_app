import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:vit_ap_student_app/features/home/model/general_outing_report.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/outing/general_outing_detail_bottom_sheet.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/outing/utils.dart';

class GeneralOutingCard extends StatelessWidget {
  final GeneralOutingReport outing;

  const GeneralOutingCard({super.key, required this.outing});

  bool _isToday() {
    try {
      final fromDate = DateTime.parse(outing.fromDate);
      final toDate = DateTime.parse(outing.toDate);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      return (today.isAtSameMomentAs(
                DateTime(fromDate.year, fromDate.month, fromDate.day),
              ) ||
              today.isAfter(
                DateTime(fromDate.year, fromDate.month, fromDate.day),
              )) &&
          (today.isAtSameMomentAs(
                DateTime(toDate.year, toDate.month, toDate.day),
              ) ||
              today.isBefore(DateTime(toDate.year, toDate.month, toDate.day)));
    } catch (e) {
      return false;
    }
  }

  bool _isUpcoming() {
    try {
      final fromDate = DateTime.parse(outing.fromDate);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final outingDay = DateTime(fromDate.year, fromDate.month, fromDate.day);
      return outingDay.isAfter(today) &&
          outingDay.difference(today).inDays <= 7;
    } catch (e) {
      return false;
    }
  }

  int _getDurationDays() {
    try {
      final fromDate = DateTime.parse(outing.fromDate);
      final toDate = DateTime.parse(outing.toDate);
      return toDate.difference(fromDate).inDays + 1;
    } catch (e) {
      return 1;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase().trim()) {
      case 'leave request accepted':
      case 'outing request accepted':
        return 'Approved';
      case 'waiting for warden\'s approval':
      case 'waiting for mentor\'s approval':
        return 'Pending';
      default:
        return 'Rejected';
    }
  }

  String _formatDateRange() {
    try {
      final fromDate = DateTime.parse(outing.fromDate);
      final toDate = DateTime.parse(outing.toDate);
      final fromFormatter = DateFormat('MMM d');
      final toFormatter = DateFormat('MMM d, yyyy');

      if (fromDate.year == toDate.year && fromDate.month == toDate.month) {
        if (fromDate.day == toDate.day) {
          return toFormatter.format(fromDate);
        }
        return '${fromDate.day} - ${toFormatter.format(toDate)}';
      }
      return '${fromFormatter.format(fromDate)} - ${toFormatter.format(toDate)}';
    } catch (e) {
      return '${outing.fromDate} - ${outing.toDate}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = getStatusColor(outing.status, context);
    final isToday = _isToday();
    final isUpcoming = _isUpcoming();
    final durationDays = _getDurationDays();

    return Card(
      elevation: 2,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isToday
            ? BorderSide(color: colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => showGeneralOutingDetailBottomSheet(outing, context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isToday
                ? LinearGradient(
                    colors: [
                      colorScheme.primaryContainer.withValues(alpha: 0.15),
                      colorScheme.surface,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Status badge (duration moved to date section when upcoming)
              Row(
                children: [
                  if (!isUpcoming || isToday)
                    _DurationBadge(
                      days: durationDays,
                      isToday: isToday,
                      colorScheme: colorScheme,
                    ),
                  if (isUpcoming && !isToday)
                    _TimeBadge(label: 'UPCOMING', color: colorScheme.tertiary),
                  const Spacer(),
                  if (isToday)
                    _TimeBadge(label: 'ACTIVE', color: colorScheme.primary),
                  if (isToday) const SizedBox(width: 8),
                  _StatusBadge(
                    label: _getStatusLabel(outing.status),
                    color: statusColor,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Place of Visit - Most important info
              if (outing.placeOfVisit.isNotEmpty) ...[
                Text(
                  outing.placeOfVisit,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
              ],

              // Purpose
              Text(
                outing.purposeOfVisit,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 16),

              // Date range prominently displayed
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.calendar_1,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _formatDateRange(),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              if (isUpcoming && !isToday) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    durationDays == 1
                                        ? '1 day'
                                        : '$durationDays days',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${outing.fromTime} - ${outing.toTime}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Download indicator if available
              if (outing.canDownload) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Iconsax.document_download,
                        size: 16,
                        color: colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Pass available',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DurationBadge extends StatelessWidget {
  final int days;
  final bool isToday;
  final ColorScheme colorScheme;

  const _DurationBadge({
    required this.days,
    required this.isToday,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isToday
            ? colorScheme.primary.withValues(alpha: 0.1)
            : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Iconsax.timer_1,
            size: 14,
            color: isToday ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            days == 1 ? '1 day' : '$days days',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isToday
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _TimeBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
