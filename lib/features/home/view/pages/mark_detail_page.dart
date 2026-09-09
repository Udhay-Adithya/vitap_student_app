import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_ap_student_app/core/common/widget/section_header.dart';
import 'package:vit_ap_student_app/core/models/mark.dart';
import 'package:vit_ap_student_app/features/grade_view/model/grade_view_detail.dart';
import 'package:vit_ap_student_app/features/home/viewmodel/mark_detail_viewmodel.dart';

class MarkDetailPage extends ConsumerStatefulWidget {
  final List<Mark> components;

  const MarkDetailPage({super.key, required this.components});

  @override
  ConsumerState<MarkDetailPage> createState() => _MarkDetailPageState();
}

class _MarkDetailPageState extends ConsumerState<MarkDetailPage> {
  late Mark primaryComponent;
  late List<Mark> sortedComponents;

  @override
  void initState() {
    super.initState();

    sortedComponents = List.from(widget.components);
    sortedComponents.sort((a, b) {
      int weight(String type) {
        final t = type.toLowerCase();
        if (t.contains('theory')) return 1;
        if (t.contains('lab')) return 2;
        if (t.contains('project')) return 3;
        return 4;
      }
      return weight(a.courseType).compareTo(weight(b.courseType));
    });

    primaryComponent = sortedComponents.firstWhere(
          (c) => c.gradeStatsJson != null && c.gradeStatsJson!.isNotEmpty,
      orElse: () => sortedComponents.firstWhere(
            (c) => c.gradeCourseId != null && c.gradeCourseId!.isNotEmpty,
        orElse: () => sortedComponents.firstWhere(
              (c) => c.grade != null && c.grade!.isNotEmpty,
          orElse: () => sortedComponents.first,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(primaryComponent.courseCode)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _HeaderCard(components: sortedComponents, primary: primaryComponent),
          ),
          const SizedBox(height: 12),

          for (final comp in sortedComponents)
            _BreakdownSection(course: comp),

          if (primaryComponent.grade != null) ...[
            const SectionHeader(
              label: 'Grades',
              padding: EdgeInsets.fromLTRB(16, SectionHeader.gapAbove, 16, SectionHeader.gapBelow),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _GradesSection(course: primaryComponent),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final List<Mark> components;
  final Mark primary;

  const _HeaderCard({required this.components, required this.primary});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final bool graded = primary.grade != null;

    final combinedType = components
        .map((c) => c.courseType.replaceAll('Embedded ', '').replaceAll('Regular ', ''))
        .join(' + ');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  primary.courseTitle,
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '${primary.courseCode} · $combinedType',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          if (graded) ...[
            const SizedBox(width: 16),
            _GradeBadge(grade: primary.grade!, grandTotal: primary.grandTotal),
          ],
        ],
      ),
    );
  }
}

class _GradeBadge extends StatelessWidget {
  final String grade;
  final String? grandTotal;
  const _GradeBadge({required this.grade, this.grandTotal});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    return Container(
      width: 84,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            grade,
            style: tt.displaySmall?.copyWith(
              color: cs.onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (grandTotal != null)
            Text(
              '$grandTotal / 100',
              style: tt.labelSmall?.copyWith(
                color: cs.onPrimary.withValues(alpha: 0.85),
              ),
            ),
        ],
      ),
    );
  }
}

class _BreakdownSection extends StatefulWidget {
  final Mark course;
  const _BreakdownSection({required this.course});

  @override
  State<_BreakdownSection> createState() => _BreakdownSectionState();
}

class _BreakdownSectionState extends State<_BreakdownSection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final title = '${widget.course.courseType.replaceAll('Embedded ', '').replaceAll('Regular ', '')} Breakdown';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: cs.primary,
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _WeightageRow(course: widget.course),
          ),
          ...widget.course.details.map((detail) => _BreakdownTile(detail: detail)),
        ],
      ],
    );
  }
}

class _WeightageRow extends StatelessWidget {
  final Mark course;
  const _WeightageRow({required this.course});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    double gained = 0;
    double lost = 0;

    final hasReEval = course.details.any(
          (d) => d.markTitle.trim().toLowerCase().contains('re evaluation fat'),
    );

    for (final detail in course.details) {
      final title = detail.markTitle.trim().toLowerCase();

      if (hasReEval && title == 'fat') continue;

      gained += double.tryParse(detail.weightageMark) ?? 0;
      final maxMark = double.tryParse(detail.maxMark) ?? 0;
      final scoredMark = double.tryParse(detail.scoredMark) ?? 0;
      final weightage = double.tryParse(detail.weightage) ?? 0;
      if (maxMark > 0) {
        lost += (maxMark - scoredMark) * weightage / maxMark;
      }
    }

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: gained.toStringAsFixed(1),
            label: 'Gained weightage',
            fill: cs.tertiaryContainer,
            onFill: cs.onTertiaryContainer,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            value: lost.toStringAsFixed(1),
            label: 'Lost weightage',
            fill: cs.errorContainer,
            onFill: cs.onErrorContainer,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color fill;
  final Color onFill;
  const _StatCard({
    required this.value,
    required this.label,
    required this.fill,
    required this.onFill,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme tt = Theme.of(context).textTheme;
    return Container(
      height: 96,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: tt.headlineMedium?.copyWith(
              color: onFill,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(label, style: tt.labelMedium?.copyWith(color: onFill)),
        ],
      ),
    );
  }
}

class _BreakdownTile extends StatelessWidget {
  final Detail detail;
  const _BreakdownTile({required this.detail});

  String _formatMark(String mark) {
    final trimmed = mark.trim();
    if (trimmed.endsWith('.0')) {
      return trimmed.substring(0, trimmed.length - 2);
    }
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    final scored = _formatMark(detail.scoredMark);
    final max = _formatMark(detail.maxMark);

    return ListTile(
      title: Text(
        detail.markTitle,
        style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('Weightage ${detail.weightage}%'),
      trailing: Text(
        '$scored / $max',
        style: tt.titleMedium?.copyWith(color: cs.onSurface),
      ),
    );
  }
}

class _GradesSection extends ConsumerStatefulWidget {
  final Mark course;
  const _GradesSection({required this.course});

  @override
  ConsumerState<_GradesSection> createState() => _GradesSectionState();
}

class _GradesSectionState extends ConsumerState<_GradesSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(markDetailViewModelProvider.notifier).loadStats(widget.course);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final AsyncValue<GradeStatisticsModel?>? statsState =
    ref.watch(markDetailViewModelProvider);

    if (statsState == null || statsState.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (statsState.hasError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Text(
          "Stats unavailable: ${statsState.error}",
          style: tt.bodyMedium?.copyWith(color: cs.error),
        ),
      );
    }

    final stats = statsState.value;
    if (stats == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Text(
          "No class statistics published for this course yet.",
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
      );
    }

    return _StatsBody(course: widget.course, stats: stats);
  }
}

class _StatsBody extends StatelessWidget {
  final Mark course;
  final GradeStatisticsModel stats;
  const _StatsBody({required this.course, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _MetricTile(label: 'Class mean', value: stats.mean)),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricTile(label: 'Std deviation', value: stats.sd),
            ),
          ],
        ),
        if (stats.gradeRanges.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'Grade cutoffs',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...stats.gradeRanges.map(
                (range) => _CutoffRow(
              range: range,
              isMine: range.grade == course.grade,
            ),
          ),
        ],
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  const _MetricTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final display = _trimNumber(value);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            display,
            style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(label, style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }

  String _trimNumber(String raw) {
    final parsed = double.tryParse(raw);
    if (parsed == null) return raw;
    return parsed
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'\.?0+$'), '');
  }
}

class _CutoffRow extends StatelessWidget {
  final GradeRangeModel range;
  final bool isMine;
  const _CutoffRow({required this.range, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMine ? cs.primaryContainer : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              range.grade,
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: isMine ? cs.onPrimaryContainer : cs.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _prettyRange(range.range),
              style: tt.bodyMedium?.copyWith(
                color: isMine ? cs.onPrimaryContainer : cs.onSurfaceVariant,
              ),
            ),
          ),
          if (isMine)
            Text(
              'You',
              style: tt.labelMedium?.copyWith(
                color: cs.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }

  String _prettyRange(String raw) => raw
      .replaceAll('#', '')
      .replaceAll('>=', '≥ ')
      .replaceAll('<', '< ')
      .replaceAll(' and ', ', ')
      .trim();
}