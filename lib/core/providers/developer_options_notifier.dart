import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vit_ap_student_app/core/providers/store.dart';
import 'package:vit_ap_student_app/core/services/vtop_service.dart';

part 'developer_options_notifier.g.dart';

class DeveloperOptionsState {
  final String appVersion;
  final String buildNumber;
  final String deviceInfo;
  final String flutterVersion;
  final String objectBoxVersion;
  final String vtopSessionStatus;
  final String objectBoxSize;
  final String secureStorageKeys;

  const DeveloperOptionsState({
    this.appVersion = 'Loading...',
    this.buildNumber = 'Loading...',
    this.deviceInfo = 'Loading...',
    this.flutterVersion = 'Loading...',
    this.objectBoxVersion = 'Loading...',
    this.vtopSessionStatus = 'Loading...',
    this.objectBoxSize = 'Loading...',
    this.secureStorageKeys = 'Loading...',
  });

  DeveloperOptionsState copyWith({
    String? appVersion,
    String? buildNumber,
    String? deviceInfo,
    String? flutterVersion,
    String? objectBoxVersion,
    String? vtopSessionStatus,
    String? objectBoxSize,
    String? secureStorageKeys,
  }) {
    return DeveloperOptionsState(
      appVersion: appVersion ?? this.appVersion,
      buildNumber: buildNumber ?? this.buildNumber,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      flutterVersion: flutterVersion ?? this.flutterVersion,
      objectBoxVersion: objectBoxVersion ?? this.objectBoxVersion,
      vtopSessionStatus: vtopSessionStatus ?? this.vtopSessionStatus,
      objectBoxSize: objectBoxSize ?? this.objectBoxSize,
      secureStorageKeys: secureStorageKeys ?? this.secureStorageKeys,
    );
  }
}

@riverpod
class DeveloperOptionsNotifier extends _$DeveloperOptionsNotifier {
  @override
  Future<DeveloperOptionsState> build() async {
    return _loadAllDebugInfo();
  }

  Future<DeveloperOptionsState> _loadAllDebugInfo() async {
    final results = await Future.wait([
      _loadPackageInfo(),
      _loadDeviceInfo(),
      _loadVtopSessionInfo(),
      _loadStorageInfo(),
    ]);

    final packageInfo = results[0] as Map<String, String>;
    final deviceInfo = results[1] as String;
    final vtopSession = results[2] as String;
    final storageInfo = results[3] as Map<String, String>;

    return DeveloperOptionsState(
      appVersion: packageInfo['version'] ?? 'Unknown',
      buildNumber: packageInfo['buildNumber'] ?? 'Unknown',
      flutterVersion: packageInfo['flutterVersion'] ?? 'Unknown',
      deviceInfo: deviceInfo,
      vtopSessionStatus: vtopSession,
      objectBoxSize: storageInfo['objectBoxSize'] ?? 'Unknown',
      objectBoxVersion: storageInfo['objectBoxVersion'] ?? 'Unknown',
      secureStorageKeys: storageInfo['secureStorageKeys'] ?? 'Unknown',
    );
  }

  Future<Map<String, String>> _loadPackageInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return {
        'version': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
        'flutterVersion': '3.x (Compiled)',
      };
    } catch (e) {
      debugPrint('Failed to load package info: $e');
      return {
        'version': 'Error',
        'buildNumber': 'Error',
        'flutterVersion': 'Error',
      };
    }
  }

  Future<String> _loadDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return '${androidInfo.manufacturer} ${androidInfo.model} (Android ${androidInfo.version.release})';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return '${iosInfo.name} (iOS ${iosInfo.systemVersion})';
      } else {
        return 'Unknown Platform';
      }
    } catch (e) {
      debugPrint('Failed to load device info: $e');
      return 'Error loading';
    }
  }

  Future<String> _loadVtopSessionInfo() async {
    try {
      final vtopService = ref.read(vtopClientServiceProvider);
      final sessionInfo = vtopService.getSessionInfo();

      if (sessionInfo['isInitialized'] == true) {
        final timeRemaining = vtopService.getTimeUntilExpiry();
        if (timeRemaining != null && timeRemaining.inSeconds > 0) {
          final minutes = timeRemaining.inMinutes;
          final seconds = timeRemaining.inSeconds % 60;
          return 'Active (${minutes}m ${seconds}s remaining)';
        } else {
          return 'Expired';
        }
      } else {
        return 'Not initialized';
      }
    } catch (e) {
      debugPrint('Failed to load VTOP session info: $e');
      return 'Error loading';
    }
  }

  Future<Map<String, String>> _loadStorageInfo() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final objectBoxDir = Directory('${appDir.path}/objectbox');
      int totalSize = 0;

      if (await objectBoxDir.exists()) {
        await for (final entity in objectBoxDir.list(recursive: true)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }

      String formattedSize;
      if (totalSize < 1024) {
        formattedSize = '$totalSize B';
      } else if (totalSize < 1024 * 1024) {
        formattedSize = '${(totalSize / 1024).toStringAsFixed(2)} KB';
      } else {
        formattedSize = '${(totalSize / (1024 * 1024)).toStringAsFixed(2)} MB';
      }

      return {
        'objectBoxSize': formattedSize,
        'objectBoxVersion': '4.0.3',
        'secureStorageKeys': '1 (credentials)',
      };
    } catch (e) {
      debugPrint('Failed to load storage info: $e');
      return {
        'objectBoxSize': 'Error',
        'objectBoxVersion': 'Error',
        'secureStorageKeys': 'Error',
      };
    }
  }

  Future<void> refreshVtopSession() async {
    final currentState = state.value;
    if (currentState == null) return;

    final vtopSession = await _loadVtopSessionInfo();
    state = AsyncValue.data(
      currentState.copyWith(vtopSessionStatus: vtopSession),
    );
  }

  Future<void> forceSessionReset() async {
    try {
      final vtopService = ref.read(vtopClientServiceProvider);
      vtopService.resetClient();
      await refreshVtopSession();
    } catch (e) {
      debugPrint('Session refresh failed: $e');
      rethrow;
    }
  }

  Future<void> clearAllLocalData() async {
    try {
      final store = ref.read(storeProvider);
      store.close();

      final vtopService = ref.read(vtopClientServiceProvider);
      vtopService.resetClient();

      // Refresh storage info after clearing
      final storageInfo = await _loadStorageInfo();
      final currentState = state.value;
      if (currentState != null) {
        state = AsyncValue.data(
          currentState.copyWith(
            objectBoxSize: storageInfo['objectBoxSize'],
            vtopSessionStatus: 'Not initialized',
          ),
        );
      }
    } catch (e) {
      debugPrint('Clear data failed: $e');
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _loadAllDebugInfo());
  }
}
