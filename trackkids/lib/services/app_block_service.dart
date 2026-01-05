// import 'package:device_apps/device_apps.dart';
// import 'overlay_service.dart';
// import '../widgets/show_logger.dart';
// import 'package:flutter/material.dart';
//
// /// Service to fetch installed apps and block apps
// class AppBlockService {
//   /// Block an app using overlay
//   Future<void> blockApp(String packageName) async {
//     try {
//       bool isInstalled = await DeviceApps.isAppInstalled(packageName);
//       if (!isInstalled) {
//         ShowLogger.log('App $packageName is not installed.');
//         return;
//       }
//
//       await OverlayService().showBlockOverlay(packageName);
//       ShowLogger.log('App blocked: $packageName');
//     } catch (e) {
//       ShowLogger.log('Error blocking app $packageName: $e');
//     }
//   }
//
//   /// Get all installed user apps with icons
//   Future<List<Application>> getInstalledApps() async {
//     try {
//       List<Application> apps = await DeviceApps.getInstalledApplications(
//         includeSystemApps: false,
//         includeAppIcons: true, // fetch real colored icons
//       );
//       ShowLogger.log('${apps.length} installed apps found.');
//       return apps;
//     } catch (e) {
//       ShowLogger.log('Error fetching installed apps: $e');
//       return [];
//     }
//   }
// }
import 'package:device_apps/device_apps.dart';
import 'overlay_service.dart';
import '../widgets/show_logger.dart';
import 'package:flutter/material.dart';

/// Service to fetch installed apps, system apps, and block apps
class AppBlockService {
  /// Block an app using overlay
  Future<void> blockApp(String packageName) async {
    try {
      bool isInstalled = await DeviceApps.isAppInstalled(packageName);
      if (!isInstalled) {
        ShowLogger.log('App $packageName is not installed.');
        return;
      }

      await OverlayService().showBlockOverlay(packageName);
      ShowLogger.log('App blocked: $packageName');
    } catch (e) {
      ShowLogger.log('Error blocking app $packageName: $e');
    }
  }

  /// Get all installed user apps with icons
  Future<List<Application>> getInstalledApps() async {
    try {
      List<Application> apps = await DeviceApps.getInstalledApplications(
        includeSystemApps: false,
        includeAppIcons: true,
      );
      ShowLogger.log('${apps.length} installed apps found.');
      return apps;
    } catch (e) {
      ShowLogger.log('Error fetching installed apps: $e');
      return [];
    }
  }

  /// Get all system apps (default apps)
  Future<List<Application>> getSystemApps() async {
    try {
      List<Application> apps = await DeviceApps.getInstalledApplications(
        includeSystemApps: true,
        includeAppIcons: true,
      );
      apps = apps.where((app) => app.systemApp).toList();
      ShowLogger.log('${apps.length} system apps found.');
      return apps;
    } catch (e) {
      ShowLogger.log('Error fetching system apps: $e');
      return [];
    }
  }
}
