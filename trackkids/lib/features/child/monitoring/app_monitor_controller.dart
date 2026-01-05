import 'package:flutter/material.dart';
import '../../../services/app_usage_service.dart';
import '../../../services/firebase_service.dart';
import '../../../models/child_model.dart';

/// Controller to manage installed apps and screen time on child device
class AppMonitorController extends ChangeNotifier {
  final AppUsageService _appUsageService = AppUsageService();
  final FirebaseService _firebaseService = FirebaseService();

  List<String> installedApps = [];
  bool isLoading = false;

  Map<String, int> screenTimeLimits = {}; // allowed minutes per app
  Map<String, int> screenTimeUsed = {};   // minutes used per app

  /// Load installed apps on device
  Future<void> loadInstalledApps() async {
    isLoading = true;
    notifyListeners();

    try {
      await _appUsageService.fetchInstalledApps();
      installedApps = _appUsageService.installedApps.map((app) => app.appName).toList();
    } catch (e) {
      debugPrint('Error loading installed apps: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  /// Load screen time limits from Firestore
  Future<void> loadScreenTimeLimits(ChildModel child) async {
    try {
      final childData = await _firebaseService.getChildSettings(child.childId);
      screenTimeLimits = Map<String, int>.from(childData['screen_time_limits'] ?? {});
      screenTimeUsed = {}; // reset usage
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading screen time limits: $e');
    }
  }

  /// Check usage of an app. Returns true if the time limit is exceeded.
  Future<bool> checkAppUsage(String appName) async {
    final used = await _appUsageService.getAppUsageMinutes(appName);
    screenTimeUsed[appName] = used;

    final limit = screenTimeLimits[appName] ?? 0;
    return limit > 0 && used >= limit;
  }
}
