import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:vit_ap_student_app/features/home/model/weekend_outing_report.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/outing/weekend_outing_detail_bottom_sheet.dart';

import 'utils.dart';

class WeekendOutingCard extends StatelessWidget {
  final WeekendOutingReport outing;

  const WeekendOutingCard({super.key, required this.outing});

  bool _isToday() {
    final now = DateTime.now();
    return outing.date.year == now.year &&
        outing.date.month == now.month &&
        outing.date.day == now.day;
  }

  bool _isUpcoming() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final outingDay = DateTime(
      outing.date.year,
      outing.date.month,
      outing.date.day,
    );
    return outingDay.isAfter(today) && outingDay.difference(today).inDays <= 7;
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase().trim()) {
      case 'leave request accepted':
      case 'outing request accepted':
        return 'Approved';
      case 'waiting for warden\'s approval':
        return 'Pending';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = getStatusColor(outing.status, context);
    final isToday = _isToday();
    final isUpcoming = _isUpcoming();

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
        onTap: () => showWeekendOutingDetailBottomSheet(outing, context),
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
              // Header: Date chip and Status badge
              Row(
                children: [
                  _DateChip(
                    date: outing.date,
                    isToday: isToday,
                    colorScheme: colorScheme,
                  ),
                  const Spacer(),
                  if (isToday)
                    _TimeBadge(label: 'TODAY', color: colorScheme.primary),
                  if (isUpcoming && !isToday)
                    _TimeBadge(label: 'UPCOMING', color: colorScheme.tertiary),
                  const SizedBox(width: 8),
                  _StatusBadge(
                    label: _getStatusLabel(outing.status),
                    color: statusColor,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Place of Visit - Most important info, shown prominently
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

              // Time Detail
              _DetailItem(
                icon: Iconsax.clock,
                label: 'Time',
                value: outing.time,
                colorScheme: colorScheme,
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

class _DateChip extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final ColorScheme colorScheme;

  const _DateChip({
    required this.date,
    required this.isToday,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('EEE, MMM d');
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
            Iconsax.calendar_1,
            size: 14,
            color: isToday ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            formatter.format(date),
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

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme colorScheme;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
