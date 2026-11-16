import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:vit_ap_student_app/features/home/model/weather.dart';
import 'package:vit_ap_student_app/features/home/view/widgets/weather/weather_snapshot.dart';
import 'package:vit_ap_student_app/features/home/viewmodel/weather_viewmodel.dart';

/// Weather as an app-bar action: the condition icon, the temperature, and what
/// it feels like.
///
/// This started as a 200pt card on the home page and is now the cheapest thing
/// on the screen — it costs no vertical space at all, because it sits in room the
/// app bar was already occupying. The day's range opens in a popover anchored to
/// the pill; a modal sheet was a focus-stealing gesture for something you glance
/// at and dismiss.
class WeatherPill extends ConsumerStatefulWidget {
  const WeatherPill({super.key});

  @override
  ConsumerState<WeatherPill> createState() => _WeatherPillState();
}

class _WeatherPillState extends ConsumerState<WeatherPill> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(weatherViewModelProvider.notifier).fetchWeather();
    });
  }

  void _refetch() => ref.read(weatherViewModelProvider.notifier).fetchWeather();

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Weather>? weather = ref.watch(weatherViewModelProvider);

    return weather?.when(
          // Nothing to say yet, and an app-bar action that appears when it has
          // an answer is calmer than a spinner sitting next to the avatar.
          loading: () => const SizedBox.shrink(),
          error: (Object error, StackTrace _) => _PillShell(
            onTap: _refetch,
            child: Icon(
              Icons.cloud_off_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          data: (Weather data) {
            final WeatherSnapshot? snapshot = WeatherSnapshot.from(data);
            if (snapshot == null) {
              return _PillShell(
                onTap: _refetch,
                child: Icon(
                  Icons.cloud_off_rounded,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              );
            }
            return _WeatherMenu(snapshot: snapshot);
          },
        ) ??
        const SizedBox.shrink();
  }
}

/// The pill plus the popover it opens.
class _WeatherMenu extends StatelessWidget {
  const _WeatherMenu({required this.snapshot});

  final WeatherSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return MenuAnchor(
      alignmentOffset: const Offset(0, 6),
      style: MenuStyle(
        alignment: Alignment.bottomLeft,
        padding: const WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.zero),
        backgroundColor: WidgetStatePropertyAll<Color>(cs.surfaceContainerHigh),
        shape: WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
      ),
      menuChildren: <Widget>[_Details(snapshot: snapshot)],
      builder:
          (BuildContext context, MenuController controller, Widget? child) {
            return _PillShell(
              onTap: () =>
                  controller.isOpen ? controller.close() : controller.open(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Lottie.asset(
                    snapshot.iconAsset,
                    width: 34,
                    height: 34,
                    frameRate: const FrameRate(60),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${snapshot.temperature.round()}°',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'feels ${snapshot.apparentTemperature.round()}°',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          },
    );
  }
}

class _PillShell extends StatelessWidget {
  const _PillShell({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: child,
        ),
      ),
    );
  }
}

/// The popover: the condition art at a size worth looking at, and the three
/// numbers the pill has no room for.
class _Details extends StatelessWidget {
  const _Details({required this.snapshot});

  final WeatherSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    return SizedBox(
      width: 288,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 20, 16),
        child: Row(
          children: <Widget>[
            Lottie.asset(
              snapshot.iconAsset,
              width: 84,
              height: 84,
              frameRate: const FrameRate(60),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    snapshot.description,
                    style: tt.titleMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Feels-like isn't repeated here — the pill is wide enough to
                  // carry it, so the popover is only what the pill left out.
                  Text(
                    'Low ${snapshot.minTemperature.round()}°   ·   '
                    'High ${snapshot.maxTemperature.round()}°',
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Amaravathi',
                    style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
