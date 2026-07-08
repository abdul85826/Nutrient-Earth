import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceIntelligenceState {
  final bool isOffline;
  final bool isLowBattery;
  final bool isLowPowerMode;
  final String deviceType;

  const DeviceIntelligenceState({
    this.isOffline = false,
    this.isLowBattery = false,
    this.isLowPowerMode = false,
    this.deviceType = 'unknown',
  });
}

class DeviceIntelligenceService {
  final Battery _battery = Battery();
  final Connectivity _connectivity = Connectivity();


  Future<DeviceIntelligenceState> analyzeDeviceState() async {
    bool isOffline = false;
    bool isLowBattery = false;
    bool isLowPowerMode = false;
    String deviceType = 'unknown';

    try {
      // 1. Connectivity Check
      final connectivityResult = await _connectivity.checkConnectivity();
      isOffline = connectivityResult.contains(ConnectivityResult.none);

      // 2. Battery & Power Check
      if (!kIsWeb) {
        final batteryLevel = await _battery.batteryLevel;
        isLowBattery = batteryLevel < 20;

        isLowPowerMode = await _battery.isInBatterySaveMode;
      }

      // 3. Device Capability Info
      if (kIsWeb) {
        deviceType = 'web';
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        deviceType = 'android';
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        deviceType = 'ios';
      }
    } catch (e) {
      debugPrint('DeviceIntelligenceService Error: $e');
    }

    return DeviceIntelligenceState(
      isOffline: isOffline,
      isLowBattery: isLowBattery,
      isLowPowerMode: isLowPowerMode,
      deviceType: deviceType,
    );
  }
}
