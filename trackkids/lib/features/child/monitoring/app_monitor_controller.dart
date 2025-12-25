import 'package:flutter/material.dart';
import '../../../services/app_usage_service.dart';
import '../../../models/child_model.dart';

class AppMonitorController extends ChangeNotifier {
  final AppUsageService _appUsageService = AppUsageService();

  List<String> installedApps = [];
  bool isLoading = false;

  // Load installed apps
  Future<void> loadInstalledApps() async {
    isLoading = true;
    notifyListeners();

    try {
      await _appUsageService.fetchInstalledApps();
      // Use the internal list from the service
      installedApps = _appUsageService.installedApps.map((app) => app.appName).toList();
    } catch (e) {
      debugPrint('Error loading installed apps: $e');
    }

    isLoading = false;
    notifyListeners();
  }


  // Send child screen time & usage to Firestore (optional)
  Future<void> checkScreenTime(ChildModel child) async {
    await _appUsageService.checkChildScreenTime(child);
  }
}
