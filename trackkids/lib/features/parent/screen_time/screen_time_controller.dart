import 'package:flutter/material.dart';
import '../../../services/app_usage_service.dart';
import '../../../services/firebase_service.dart';
import '../../../models/child_model.dart';

class ScreenTimeController extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final AppUsageService _appUsageService = AppUsageService();

  Map<String, int> _screenTimeLimits = {};
  Map<String, int> get screenTimeLimits => _screenTimeLimits;

  // Load screen time limits and installed apps for a child
  Future<void> loadScreenTime(ChildModel child) async {
    try {
      // Fetch usage limits from Firestore for this child
      final childData = await _firebaseService.getChildSettings(child.childId);
      _screenTimeLimits = Map<String, int>.from(childData['screen_time_limits'] ?? {});

      // Fetch installed apps on the child's device
      await _appUsageService.fetchInstalledApps();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading screen time: $e');
    }
  }

  // Update the time limit for a specific app
  Future<void> updateScreenTime(ChildModel child, String packageName, int minutes) async {
    _screenTimeLimits[packageName] = minutes;

    // Update the new limit in Firestore
    await _firebaseService.updateScreenTimeLimit(child.childId, packageName, minutes);

    // Immediately check if the app should be blocked
    await _appUsageService.checkChildScreenTime(child);

    notifyListeners();
  }
}
