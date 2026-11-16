import 'package:home_widget/home_widget.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_widget_service.g.dart';

@Riverpod(keepAlive: true)
HomeWidgetService homeWidgetService(Ref ref) => const HomeWidgetService();

/// The home screen widget's shared storage, behind an instance so it can be
/// overridden. The plugin's own API is static.
class HomeWidgetService {
  const HomeWidgetService();

  static const String _appGroupId = 'group.com.udhay.vitapstudentapp';
  static const String _widgetName = 'UpcomingClassWidget';

  Future<void> initialize() => HomeWidget.setAppGroupId(_appGroupId);

  Future<void> save(String key, String value) =>
      HomeWidget.saveWidgetData<String>(key, value);

  Future<String?> read(String key) => HomeWidget.getWidgetData<String>(key);

  Future<void> refresh() => HomeWidget.updateWidget(
    name: _widgetName,
    iOSName: _widgetName,
    androidName: _widgetName,
  );
}
