import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_ap_student_app/core/common/widget/section_header.dart';
import 'package:vit_ap_student_app/core/models/mark.dart';
import 'package:vit_ap_student_app/features/grade_view/model/grade_view_detail.dart';
import 'package:vit_ap_student_app/features/home/viewmodel/mark_detail_viewmodel.dart';

/// Full-screen detail for one course's marks — and, once a semester ends, its
/// grade and class statistics. Replaces the old marks bottom sheet.
class MarkDetailPage extends ConsumerStatefulWidget {
  final Mark course;

  const MarkDetailPage({super.key, required this.course});

  @override
  ConsumerState<MarkDetailPage> createState() => _MarkDetailPageState();
}

class _MarkDetailPageState extends ConsumerState<MarkDetailPage> {
  @override
  void initState() {
    super.initState();
    // Lazily load the class statistics (a no-op if the course is not graded or
    // the stats are already cached on the Mark).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(markDetailViewModelProvider.notifier).loadStats(widget.course);
    });
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;

    return Scaffold(
      appBar: AppBar(title: Text(course.courseCode)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _HeaderCard(course: course),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _WeightageRow(course: course),
          ),
          const SectionHeader(
            label: 'Assessment breakdown',
            padding: EdgeInsets.fromLTRB(
              16,
              SectionHeader.gapAbove,
              16,
              SectionHeader.gapBelow,
            ),
          ),
          ...course.details.map((detail) => _BreakdownTile(detail: detail)),
          if (course.grade != null) ...[
            const SectionHeader(
              label: 'Grades',
              padding: EdgeInsets.fromLTRB(
                16,
                SectionHeader.gapAbove,
                16,
                SectionHeader.gapBelow,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _GradesSection(course: course),
            ),
          ],
        ],
      ),
    );
  }
}

/// Course identity, with the grade badge as the screen's one saturated element.
class _HeaderCard extends StatelessWidget {
  final Mark course;
  const _HeaderCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final bool graded = course.grade != null;

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
                  course.courseTitle,
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '${course.courseCode} · ${course.courseType}',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                Text(
                  course.faculty,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                ),
              ],
            ),
          ),
          if (graded) ...[
            const SizedBox(width: 16),
            _GradeBadge(grade: course.grade!, grandTotal: course.grandTotal),
          ],
        ],
      ),
    );
  }
}

/// The final letter grade + grand total — the one loud element on the page.
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

/// Gained vs lost weightage — muted container fills, on the seeded palette.
class _WeightageRow extends StatelessWidget {
  final Mark course;
  const _WeightageRow({required this.course});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    double gained = 0;
    double lost = 0;
    for (final detail in course.details) {
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

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    return ListTile(
      title: Text(
        detail.markTitle,
        style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('Weightage ${detail.weightage}%'),
      trailing: Text(
        '${detail.scoredMark} / ${detail.maxMark}',
        style: tt.titleMedium?.copyWith(color: cs.onSurface),
      ),
    );
  }
}

/// The grade section: class mean + SD, and the cutoff list with the student's
/// own bracket highlighted. Stats load lazily on first open.
class _GradesSection extends ConsumerWidget {
  final Mark course;
  const _GradesSection({required this.course});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final AsyncValue<GradeStatisticsModel?>? statsState = ref.watch(
      markDetailViewModelProvider,
    );

    return switch (statsState) {
      AsyncData(:final value?) => _StatsBody(course: course, stats: value),
      // The course is graded but has no statistics payload.
      AsyncData() => const SizedBox.shrink(),
      AsyncError() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          "Couldn't load class statistics.",
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
      ),
      // null (not started) or loading.
      _ => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      ),
    };
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
            Expanded(
              child: _MetricTile(label: 'Class mean', value: stats.mean),
            ),
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
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...stats.gradeRanges.map(
            (range) =>
                _CutoffRow(range: range, isMine: range.grade == course.grade),
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
    // VTOP hands back long float artifacts (e.g. 60.400001525878906); trim.
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
          Text(
            label,
            style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  String _trimNumber(String raw) {
    final parsed = double.tryParse(raw);
    if (parsed == null) return raw;
    return parsed.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
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

  // VTOP writes ranges as ">=81#", ">=67 and <81". Tidy for display.
  String _prettyRange(String raw) => raw
      .replaceAll('#', '')
      .replaceAll('>=', '≥ ')
      .replaceAll('<', '< ')
      .replaceAll(' and ', ', ')
      .trim();
}
