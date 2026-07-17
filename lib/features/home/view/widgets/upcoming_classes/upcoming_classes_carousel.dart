import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vit_ap_student_app/core/models/timetable.dart';
import 'package:vit_ap_student_app/core/providers/current_user.dart';
import 'package:vit_ap_student_app/core/utils/get_classes.dart';
import 'package:vit_ap_student_app/core/utils/parse_class_time.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/timetable_empty_state.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/upcoming_classes/carousel_indicator.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/upcoming_classes/upcoming_classes_card.dart';

class UpcomingClassesCarousel extends ConsumerStatefulWidget {
  const UpcomingClassesCarousel({super.key});

  @override
  ConsumerState<UpcomingClassesCarousel> createState() =>
      _UpcomingClassesCarouselState();
}

class _UpcomingClassesCarouselState
    extends ConsumerState<UpcomingClassesCarousel> {
  int currentPageIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  bool _hasInitialized = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final timetable = user?.timetable.target;
    final day = DateFormat('EEEE').format(DateTime.now());

    if (timetable == null) {
      return const TimetableEmptyState();
    }
    final List<Day> classes = getClassesForDay(timetable, day);

    if (classes.isEmpty) {
      return const TimetableEmptyState(
        primaryText: 'No classes found',
        secondaryText: 'Seems like a day off 😪',
      );
    }

    final upcomingClassIndex = _getUpcomingClassIndex(classes, day);

    // Only set the initial page once
    if (!_hasInitialized && upcomingClassIndex != -1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _carouselController.animateToPage(upcomingClassIndex);
        setState(() {
          currentPageIndex = upcomingClassIndex;
          _hasInitialized = true;
        });
      });
    }

    return Column(
      children: [
        CarouselSlider.builder(
          carouselController: _carouselController,
          itemCount: classes.length,
          itemBuilder: (context, index, _) {
            final classInfo = classes[index];

            return UpcomingClassCard(
              classInfo: classInfo,
            );
          },
          options: CarouselOptions(
            scrollPhysics: const BouncingScrollPhysics(),
            autoPlayCurve: Curves.fastOutSlowIn,
            height: 175,
            enlargeCenterPage: false,
            enableInfiniteScroll: false,
            viewportFraction: 1.0,
            autoPlay: false,
            initialPage: upcomingClassIndex,
            onPageChanged: (index, _) =>
                setState(() => currentPageIndex = index),
          ),
        ),
        const SizedBox(height: 10),
        CarouselIndicator(
          itemCount: classes.length,
          currentIndex: currentPageIndex,
          controller: _carouselController,
        ),
      ],
    );
  }

  int _getUpcomingClassIndex(List<Day> classes, String day) {
    final now = DateTime.now();

    for (int i = 0; i < classes.length; i++) {
      // Skip classes whose start time is missing or malformed (e.g. "-") instead
      // of throwing and taking down the whole home screen.
      final classStartDateTime = parseClassTime(classes[i].startTime);
      if (classStartDateTime == null) continue;

      if (classStartDateTime.isAfter(now)) {
        return i;
      }
    }

    return 0;
  }
}
