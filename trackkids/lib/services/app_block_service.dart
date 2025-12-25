import 'package:device_apps/device_apps.dart';
import 'overlay_service.dart';
import '../widgets/show_logger.dart';

/// Service to block apps and fetch installed apps on the child device
class AppBlockService {
  /// Block an app by package name
  Future<void> blockApp(String packageName) async {
    try {
      // Check if the app is installed
      bool isInstalled = await DeviceApps.isAppInstalled(packageName);
      if (!isInstalled) {
        ShowLogger.log('App $packageName not installed.');
        return;
      }

      // Trigger overlay to prevent child from using the app
      await OverlayService().showBlockOverlay(packageName);

      ShowLogger.log('App blocked: $packageName');
    } catch (e) {
      ShowLogger.log('Error blocking app $packageName: $e');
    }
  }

  /// Get all installed apps on the device (non-system apps only)
  Future<List<Application>> getInstalledApps() async {
    try {
      List<Application> apps = await DeviceApps.getInstalledApplications(
        includeSystemApps: false,
        includeAppIcons: false,
      );
      ShowLogger.log('${apps.length} apps found on device.');
      return apps;
    } catch (e) {
      ShowLogger.log('Error fetching installed apps: $e');
      return [];
    }
  }
}
