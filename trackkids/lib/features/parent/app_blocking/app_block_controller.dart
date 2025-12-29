import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import '../../../services/app_block_service.dart';
import '../../../services/firebase_service.dart';

class AppBlockController extends ChangeNotifier {
  final AppBlockService _service = AppBlockService();
  final FirebaseService _firebaseService = FirebaseService();

  List<String> _blockedApps = [];
  List<String> _installedApps = [];

  List<String> get blockedApps => _blockedApps;
  List<String> get installedApps => _installedApps;

  /// Load installed apps from the device

  Future<void> loadInstalledApps() async {
    List<Application> apps = await _service.getInstalledApps();
    _installedApps = apps.map((app) => app.packageName).toList();
    notifyListeners();
  }

  /// Load blocked apps from Firebase for the given childId
  Future<void> loadBlockedApps(String childId) async {
    _blockedApps = await _firebaseService.getBlockedApps(childId);
    notifyListeners();
  }

  /// Update blocked apps in Firebase
  Future<void> updateBlockedApps(String childId, List<String> apps) async {
    _blockedApps = apps;
    await _firebaseService.updateBlockedApps(childId, apps);
    notifyListeners();
  }

  /// Check if an app is blocked
  bool isBlocked(String packageName) {
    return _blockedApps.contains(packageName);
  }
}
