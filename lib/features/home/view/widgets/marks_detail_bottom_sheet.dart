import 'package:flutter/material.dart';
import 'package:vit_ap_student_app/core/models/mark.dart';

void showMarksDetailBottomSheet(Mark course, BuildContext context) {
  double totalWeightage = 0;
  double lostWeightage = 0;

  for (var detail in course.details) {
    // Convert weightage_mark to double if it's a string
    totalWeightage += double.tryParse(detail.weightageMark) ?? 0;

    final maxMark = double.parse(detail.maxMark);
    final scoredMark = double.parse(detail.scoredMark);
    final weightage = double.parse(detail.weightage);

    final lostMark = maxMark - scoredMark;
    lostWeightage += (lostMark * weightage / maxMark);
  }

  showModalBottomSheet<void>(
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    context: context,
    builder: (context) {
      return SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                children: [
                  Text(
                    course.courseTitle,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(width: MediaQuery.sizeOf(context).width),
              const SizedBox(height: 8),
              Text(
                'Faculty',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Text(
                course.faculty,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Course Code',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Text(
                course.courseCode,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      height: 100,
                      width: MediaQuery.sizeOf(context).width - 231,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.greenAccent.shade200,
                            Colors.greenAccent.shade400,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Text(
                              totalWeightage.toStringAsFixed(1),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 32,
                                color: Theme.of(context).colorScheme.surface,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 8.0,
                              bottom: 4,
                            ),
                            child: Text(
                              'Gained\nWeightage',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.surface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      height: 100,
                      width: MediaQuery.sizeOf(context).width - 231,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.redAccent.shade100,
                            Colors.redAccent.shade200,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Text(
                              lostWeightage.toStringAsFixed(1),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 32,
                                color: Theme.of(context).colorScheme.surface,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 8.0,
                              bottom: 8,
                            ),
                            child: Text(
                              'Lost\nWeightage',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.surface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Details:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: course.details.length,
                itemBuilder: (context, index) {
                  final detail = course.details[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        detail.markTitle,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        '${detail.scoredMark} / ${detail.maxMark}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
