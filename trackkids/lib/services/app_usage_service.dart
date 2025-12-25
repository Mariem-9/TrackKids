import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart'; // To list installed apps
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/child_model.dart';
import 'app_block_service.dart';
import '../widgets/show_logger.dart'; // Optional logger widget

/// Abstract class to define AppService contract
abstract class AppService {
  Future<void> fetchInstalledApps();
  Future<void> checkChildScreenTime(ChildModel child);
  Future<int> getAppUsageMinutes(String packageName);
}

/// AppUsageService: Manages child app usage and enforces screen time limits
class AppUsageService implements AppService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Store installed apps
  List<Application> _installedApps = [];
  List<Application> get installedApps => _installedApps;

  @override
  Future<void> fetchInstalledApps() async {
    try {
      _installedApps = await DeviceApps.getInstalledApplications(
        includeSystemApps: false, // Only user apps
        includeAppIcons: false,
      );
      ShowLogger.log('Installed apps fetched: ${_installedApps.length}');
    } catch (e) {
      ShowLogger.log('Error fetching installed apps: $e');
    }
  }

  /// Check screen time for all apps of a specific child
  @override
  Future<void> checkChildScreenTime(ChildModel child) async {
    try {
      // Fetch screen time limits from Firestore
      DocumentSnapshot doc = await _firestore
          .collection('screen_time_limits')
          .doc(child.childId)
          .get();

      if (!doc.exists) return;

      Map<String, dynamic> limits = doc.data() as Map<String, dynamic>;

      // Make sure installed apps are fetched
      if (_installedApps.isEmpty) await fetchInstalledApps();

      for (var app in _installedApps) {
        if (limits.containsKey(app.packageName)) {
          int maxMinutes = limits[app.packageName];
          int usageMinutes = await getAppUsageMinutes(app.packageName);

          // If child exceeded allowed time, block the app
          if (usageMinutes >= maxMinutes) {
            ShowLogger.log(
                '${app.appName} exceeded limit ($usageMinutes / $maxMinutes min)');
            await AppBlockService().blockApp(app.packageName);
          }
        }
      }
    } catch (e) {
      ShowLogger.log('Error checking screen time: $e');
    }
  }

  /// Example: Returns usage minutes for a given app (pseudo-logic)
  /// In real scenario, integrate Android UsageStats API or a plugin
  @override
  Future<int> getAppUsageMinutes(String packageName) async {
    try {
      // TODO: Implement real usage tracking per app
      // For now, return 0 to simulate
      return 0;
    } catch (e) {
      ShowLogger.log('Error getting usage minutes for $packageName: $e');
      return 0;
    }
  }
}
