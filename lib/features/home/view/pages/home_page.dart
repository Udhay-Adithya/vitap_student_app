import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vit_ap_student_app/core/common/widget/section_header.dart';
import 'package:vit_ap_student_app/core/services/analytics_service.dart';
import 'package:vit_ap_student_app/features/home/view/pages/for_you_view_all_page.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/announcement_container.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/for_you_carousel.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/home_app_bar.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/mess_menu/mess_menu_card.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/quick_access/quick_access.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/support_prompt_card.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/upcoming_classes/today_class_count_badge.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/upcoming_classes/today_schedule_stack.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    ref.read(analyticsServiceProvider).logScreen('HomePage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const HomeAppBar(),
          const SliverToBoxAdapter(child: AnnouncementContainer()),
          // Earned, not ambient: appears only after real use and stays
          // gone for months once dismissed.
          const SliverToBoxAdapter(child: SupportPromptCard()),
          const SliverToBoxAdapter(
            child: SectionHeader(
              label: 'Today',
              variant: SectionHeaderVariant.home,
              padding: SectionHeader.standalone,
              trailing: TodayClassCountBadge(),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: SectionHeader.sectionContent,
              child: TodayScheduleStack(),
            ),
          ),
          const SliverToBoxAdapter(
            child: SectionHeader(
              label: 'Quick Access',
              variant: SectionHeaderVariant.home,
              padding: SectionHeader.standalone,
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: SectionHeader.sectionContent,
              child: QuickAccess(),
            ),
          ),
          const SliverToBoxAdapter(child: MessMenuCard()),

          SliverToBoxAdapter(
            child: SectionHeader(
              label: 'For You',
              variant: SectionHeaderVariant.home,
              // Compact, so a heading with an action is the same height as one
              // without and the rhythm holds across all three sections.
              trailing: TextButton.icon(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const ForYouViewAllPage(),
                    ),
                  );
                },
                label: const Text('View All'),
                icon: const Icon(Iconsax.arrow_right_1_copy, size: 18),
                iconAlignment: IconAlignment.end,
              ),
            ),
          ),
          // No horizontal padding: the carousel scrolls edge to edge and sets
          // its own leading inset, so cards can slide past the screen edge
          // instead of stopping short of it.
          const SliverToBoxAdapter(child: ForYouCarousel()),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
