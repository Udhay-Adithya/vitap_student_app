import 'package:flutter/material.dart';

/// A reusable pill-style tab bar used across the app.
///
/// Can be placed in [AppBar.bottom] (implements [PreferredSizeWidget])
/// or anywhere in the widget tree.
class AppTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;
  final List<String> tabs;
  final bool isScrollable;

  const AppTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.isScrollable = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  Widget _buildTab(BuildContext context, String label) {
    return Container(
      height: 60,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.secondaryContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Tab(
        child: Text(
          label,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TabBar(
        controller: controller,
        isScrollable: isScrollable,
        dividerColor: Theme.of(context).colorScheme.surface,
        labelPadding: const EdgeInsets.symmetric(horizontal: 4.0),
        splashBorderRadius: BorderRadius.circular(30),
        labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        unselectedLabelColor: Theme.of(
          context,
        ).colorScheme.onSecondaryContainer,
        labelColor: Theme.of(context).colorScheme.onSecondaryContainer,
        indicator: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(30),
        ),
        splashFactory: InkRipple.splashFactory,
        overlayColor: WidgetStateColor.resolveWith(
          (states) => Theme.of(context).colorScheme.secondaryContainer,
        ),
        tabAlignment: isScrollable ? TabAlignment.start : null,
        tabs: tabs.map((label) => _buildTab(context, label)).toList(),
      ),
    );
  }
}
