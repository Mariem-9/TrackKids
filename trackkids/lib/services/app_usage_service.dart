import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';
import '../models/child_model.dart';
import 'app_block_service.dart';
import '../widgets/show_logger.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Service to fetch installed apps and manage screen time
class AppUsageService {
  List<ApplicationWithIcon> _installedApps = [];
  List<ApplicationWithIcon> get installedApps => _installedApps;

  /// List of sensitive apps predefined
  final List<Map<String, dynamic>> availableApps = [
    {'name': 'TikTok', 'package': 'com.zhiliaoapp.musically', 'icon': Icons.music_note, 'minimumAge': 13},
    {'name': 'Facebook', 'package': 'com.facebook.katana', 'icon': Icons.facebook, 'minimumAge': 13},
    {'name': 'Instagram', 'package': 'com.instagram.android', 'icon': Icons.camera_alt, 'minimumAge': 13},
    {'name': 'Snapchat', 'package': 'com.snapchat.android', 'icon': Icons.chat, 'minimumAge': 13},
    {'name': 'YouTube', 'package': 'com.google.android.youtube', 'icon': Icons.video_library, 'minimumAge': 6},
    {'name': 'Discord', 'package': 'com.discord', 'icon': Icons.forum, 'minimumAge': 13},
    {'name': 'Roblox', 'package': 'com.roblox.client', 'icon': Icons.videogame_asset, 'minimumAge': 10},
    {'name': 'Fortnite', 'package': 'com.epicgames.fortnite', 'icon': Icons.sports_esports, 'minimumAge': 12},
    {'name': 'WhatsApp', 'package': 'com.whatsapp', 'icon': FontAwesomeIcons.whatsapp, 'minimumAge': 13},
    {'name': 'TrackKids', 'package': 'com.example.trackkids', 'icon': Icons.child_care, 'minimumAge': 0},
  ];

  /// Fetch installed apps on device, including icons
  Future<void> fetchInstalledApps() async {
    try {
      final apps = await DeviceApps.getInstalledApplications(
        includeSystemApps: false,
        includeAppIcons: true, // fetch real colored icons
      );
      _installedApps = apps.whereType<ApplicationWithIcon>().toList();
      ShowLogger.log('Installed apps fetched: ${_installedApps.length}');
    } catch (e) {
      ShowLogger.log('Error fetching installed apps: $e');
    }
  }

  /// Check screen time for each installed app and block if exceeded
  Future<void> checkChildScreenTime(ChildModel child, Map<String, int> screenTimeLimits) async {
    if (_installedApps.isEmpty) await fetchInstalledApps();

    for (var app in _installedApps) {
      if (screenTimeLimits.containsKey(app.packageName)) {
        int maxMinutes = screenTimeLimits[app.packageName] ?? 0;
        int usageMinutes = await getAppUsageMinutes(app.packageName);

        if (usageMinutes >= maxMinutes) {
          ShowLogger.log('${app.appName} exceeded limit ($usageMinutes/$maxMinutes min)');
          await AppBlockService().blockApp(app.packageName);
        }
      }
    }
  }

  /// Return usage minutes for a given app (currently stub)
  Future<int> getAppUsageMinutes(String packageName) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return 0;
  }

  /// Combine installed apps + sensitive apps even if not installed
  List<Map<String, dynamic>> getCombinedApps() {
    final installedMap = { for (var a in _installedApps) a.packageName: a };
    List<Map<String, dynamic>> combined = [];

    // Add installed apps
    for (var app in _installedApps) {
      combined.add({
        'name': app.appName,
        'package': app.packageName,
        'iconBytes': app.icon,
        'installed': true,
        'minimumAge': 0,
        'sensitive': availableApps.any((a) => a['package'] == app.packageName)
      });
    }

    // Add sensitive apps that are not installed
    for (var sensitiveApp in availableApps) {
      if (!installedMap.containsKey(sensitiveApp['package'])) {
        combined.add({
          'name': sensitiveApp['name'],
          'package': sensitiveApp['package'],
          'iconBytes': null, // optional default icon
          'installed': false,
          'minimumAge': sensitiveApp['minimumAge'],
          'sensitive': true,
        });
      }
    }

    return combined;
  }
}
