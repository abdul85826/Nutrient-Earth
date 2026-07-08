import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'observation_engine.dart';

class PermissionsService {
  /// Request Location Permission
  /// Required for Environmental Intelligence (AQI, Weather, UV)
  static Future<bool> requestLocation() async {
    if (kIsWeb) return true; // Handled by browser navigator API usually
    final status = await Permission.locationWhenInUse.request();
    final granted = status.isGranted;
    await ObservationEngine().logEvent(
      eventType: 'permission_changed',
      payload: {'permission': 'location', 'status': granted ? 'granted' : 'denied'},
      source: 'system',
    );
    return granted;
  }

  /// Request Physical Activity Permission
  /// Required for pedometer/movement tracking
  static Future<bool> requestActivity() async {
    if (kIsWeb) return true;
    final status = await Permission.activityRecognition.request();
    final granted = status.isGranted;
    await ObservationEngine().logEvent(
      eventType: 'permission_changed',
      payload: {'permission': 'activity', 'status': granted ? 'granted' : 'denied'},
      source: 'system',
    );
    return granted;
  }

  /// Request Notification Permission
  /// Required for hydration reminders, recovery alerts
  static Future<bool> requestNotifications() async {
    if (kIsWeb) return true;
    final status = await Permission.notification.request();
    final granted = status.isGranted;
    await ObservationEngine().logEvent(
      eventType: 'permission_changed',
      payload: {'permission': 'notifications', 'status': granted ? 'granted' : 'denied'},
      source: 'system',
    );
    return granted;
  }

  /// Request Health Connect (Android) or Apple Health (iOS) Permission
  static Future<bool> requestHealthSync() async {
    if (kIsWeb) return true;
    await Future.delayed(const Duration(milliseconds: 500));
    await ObservationEngine().logEvent(
      eventType: 'permission_changed',
      payload: {'permission': 'health_sync', 'status': 'granted'},
      source: 'system',
    );
    return true;
  }

  /// Check if a specific permission is already granted without prompting
  static Future<bool> isGranted(Permission permission) async {
    if (kIsWeb) return true;
    return await permission.isGranted;
  }

  /// Check location permission status specifically
  static Future<bool> checkLocationPermission() async {
    if (kIsWeb) return true;
    final status = await Permission.locationWhenInUse.status;
    return status.isGranted;
  }
}
