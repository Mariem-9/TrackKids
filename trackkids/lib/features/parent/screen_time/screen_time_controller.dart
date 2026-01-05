import 'package:flutter/material.dart';
import '../../../services/app_usage_service.dart';
import '../../../services/firebase_service.dart';
import '../../../models/child_model.dart';

/// Controller to manage screen time per app
class ScreenTimeController extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final AppUsageService _appUsageService = AppUsageService();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Map<String, int> _screenTimeLimits = {}; // stored in minutes
  Map<String, int> get screenTimeLimits => _screenTimeLimits;

  List<Map<String, dynamic>> _apps = [];
  List<Map<String, dynamic>> get apps => _apps;

  /// Load installed apps and screen time limits from Firestore
  Future<void> loadAppsAndScreenTime(ChildModel child) async {
    _isLoading = true;
    notifyListeners();

    try {
      final childData = await _firebaseService.getChildSettings(child.childId);
      _screenTimeLimits =
      Map<String, int>.from(childData['screen_time_limits'] ?? {});

      await _appUsageService.fetchInstalledApps();
      _apps = _appUsageService.getCombinedApps();
    } catch (e) {
      debugPrint('Error loading apps: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Update screen time limit (minutes)
  Future<void> updateScreenTimeLimit(
      ChildModel child, String packageName, int minutes) async {
    _screenTimeLimits[packageName] = minutes;
    notifyListeners();
    await _firebaseService.updateScreenTimeLimit(child.childId, packageName, minutes);

    // Optionally check usage immediately
    await _appUsageService.checkChildScreenTime(child, _screenTimeLimits);
  }

  /// Remove screen time limit
  Future<void> removeScreenTimeLimit(ChildModel child, String packageName) async {
    _screenTimeLimits.remove(packageName);
    notifyListeners();
    await _firebaseService.updateScreenTimeLimit(child.childId, packageName, null);
  }

  /// Format minutes into hh:mm
  String formatMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  /// Parse hh:mm string into minutes
  int? parseTime(String input) {
    try {
      final parts = input.split(':');
      if (parts.length != 2) return null;
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      return h * 60 + m;
    } catch (e) {
      return null;
    }
  }
}
