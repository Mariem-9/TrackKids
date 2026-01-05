// import 'package:flutter/material.dart';
// import 'package:device_apps/device_apps.dart';
// import '../../../services/app_block_service.dart';
// import '../../../services/firebase_service.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//
// class AppBlockController extends ChangeNotifier {
//   final AppBlockService _service = AppBlockService();
//   final FirebaseService _firebaseService = FirebaseService();
//
//   List<String> _installedApps = [];
//   List<String> _blockedApps = [];
//   List<String> _systemApps = []; // ← pour Default Apps
//   String _searchQuery = '';
//   int _childAge = 0;
//
//   /// Sensitive apps
//   List<Map<String, dynamic>> _sensitiveApps = [
//     {'name': 'TikTok', 'package': 'com.zhiliaoapp.musically', 'icon': Icons.music_note, 'minimumAge': 13},
//     {'name': 'Facebook', 'package': 'com.facebook.katana', 'icon': Icons.facebook, 'minimumAge': 13},
//     {'name': 'Instagram', 'package': 'com.instagram.android', 'icon': Icons.camera_alt, 'minimumAge': 13},
//     {'name': 'Snapchat', 'package': 'com.snapchat.android', 'icon': Icons.chat, 'minimumAge': 13},
//     {'name': 'YouTube', 'package': 'com.google.android.youtube', 'icon': Icons.video_library, 'minimumAge': 6},
//     {'name': 'Discord', 'package': 'com.discord', 'icon': Icons.forum, 'minimumAge': 13},
//     {'name': 'Roblox', 'package': 'com.roblox.client', 'icon': Icons.videogame_asset, 'minimumAge': 10},
//     {'name': 'Fortnite', 'package': 'com.epicgames.fortnite', 'icon': Icons.sports_esports, 'minimumAge': 12},
//     {'name': 'WhatsApp', 'package': 'com.whatsapp', 'icon': FontAwesomeIcons.whatsapp, 'minimumAge': 13},
//     {'name': 'TrackKids', 'package': 'com.example.trackkids', 'icon': Icons.child_care, 'minimumAge': 0},
//   ];
//
//   int get childAge => _childAge;
//   List<String> get blockedApps => _blockedApps;
//   List<String> get installedApps => _installedApps;
//   List<String> get systemApps => _systemApps; // getter pour Default Apps
//   List<Map<String, dynamic>> get sensitiveApps => _sensitiveApps;
//   String get searchQuery => _searchQuery;
//
//   void updateSearch(String query) {
//     _searchQuery = query;
//     notifyListeners();
//   }
//
//   Future<void> loadChildAge(String childId) async {
//     _childAge = await _firebaseService.getChildAge(childId);
//     notifyListeners();
//   }
//
//   Future<void> updateChildAge(String childId, int age) async {
//     _childAge = age;
//     notifyListeners();
//     await _firebaseService.updateChildAge(childId, age);
//   }
//
//   /// Filter sensitive apps
//   List<Map<String, dynamic>> get filteredSensitiveApps {
//     List<Map<String, dynamic>> apps = List.from(_sensitiveApps);
//
//     if (_childAge > 0) {
//       apps.sort((a, b) {
//         bool aTooYoung = _childAge < a['minimumAge'];
//         bool bTooYoung = _childAge < b['minimumAge'];
//         if (aTooYoung && !bTooYoung) return -1;
//         if (!aTooYoung && bTooYoung) return 1;
//         return 0;
//       });
//     }
//
//     if (_searchQuery.isNotEmpty) {
//       apps = apps.where((app) => app['name'].toLowerCase().contains(_searchQuery.toLowerCase())).toList();
//     }
//
//     return apps;
//   }
//
//   Future<void> loadInstalledApps() async {
//     try {
//       final apps = await _service.getInstalledApps();
//       _installedApps = apps.map((app) => app.packageName).toList();
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Error loading installed apps: $e');
//     }
//   }
//
//   /// === Nouvelle fonction pour charger les Default / System Apps ===
//   Future<void> loadSystemApps() async {
//     try {
//       final apps = await DeviceApps.getInstalledApplications(
//         includeSystemApps: true,
//         includeAppIcons: false,
//       );
//       _systemApps = apps
//           .where((app) => !app.systemApp) // si tu veux exclure certaines apps système sensibles
//           .map((app) => app.packageName)
//           .toList();
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Error loading system apps: $e');
//     }
//   }
//
//   Future<void> loadBlockedApps(String childId) async {
//     try {
//       _blockedApps = await _firebaseService.getBlockedApps(childId);
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Error loading blocked apps: $e');
//     }
//   }
//
//   Future<void> updateBlockedApps(String childId, List<String> newBlockedList) async {
//     _blockedApps = newBlockedList;
//     notifyListeners();
//     try {
//       await _firebaseService.updateBlockedApps(childId, _blockedApps);
//     } catch (e) {
//       debugPrint('Error updating blocked apps: $e');
//     }
//   }
//
//   bool isBlocked(String packageName) => _blockedApps.contains(packageName);
//   bool isInstalled(String packageName) => _installedApps.contains(packageName);
//   bool isAllowedByAge(Map<String, dynamic> app) => _childAge >= app['minimumAge'];
//
//   Future<void> blockAppNow(String packageName) async {
//     try {
//       await _service.blockApp(packageName);
//     } catch (e) {
//       debugPrint('Error blocking app $packageName: $e');
//     }
//   }
//
//   /// Add / Remove Sensitive Apps
//   void addSensitiveApp(Map<String, dynamic> app) {
//     _sensitiveApps.add(app);
//     notifyListeners();
//   }
//
//   void removeSensitiveApp(String packageName) {
//     _sensitiveApps.removeWhere((app) => app['package'] == packageName);
//     notifyListeners();
//   }
// }
import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';
import '../../../services/app_block_service.dart';
import '../../../services/firebase_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Controller to manage installed apps, sensitive apps, default/system apps,
/// blocked apps, child age, and search functionality.
class AppBlockController extends ChangeNotifier {
  final AppBlockService _service = AppBlockService();
  final FirebaseService _firebaseService = FirebaseService();

  // ====== State ======
  int _childAge = 0;                   // Child age
  String _searchQuery = '';            // Search input
  List<String> _installedApps = [];    // Installed apps on device
  List<String> _blockedApps = [];      // Apps blocked for the child
  List<String> _systemApps = [];       // System/default apps for the child
  List<Map<String, dynamic>> _sensitiveApps = [   // Sensitive apps managed manually
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

  // ====== Getters ======
  int get childAge => _childAge;
  String get searchQuery => _searchQuery;
  List<String> get installedApps => _installedApps;
  List<String> get blockedApps => _blockedApps;
  List<String> get systemApps => _systemApps; // Default apps
  List<Map<String, dynamic>> get sensitiveApps => _sensitiveApps;

  // ====== Search functionality ======
  void updateSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // ====== Child age management ======
  Future<void> loadChildAge(String childId) async {
    _childAge = await _firebaseService.getChildAge(childId);
    notifyListeners();
  }

  Future<void> updateChildAge(String childId, int age) async {
    _childAge = age;
    notifyListeners();
    await _firebaseService.updateChildAge(childId, age);
  }

  // ====== Filter sensitive apps by age and search ======
  List<Map<String, dynamic>> get filteredSensitiveApps {
    List<Map<String, dynamic>> apps = List.from(_sensitiveApps);

    // Sort by age restrictions
    if (_childAge > 0) {
      apps.sort((a, b) {
        bool aTooYoung = _childAge < a['minimumAge'];
        bool bTooYoung = _childAge < b['minimumAge'];
        if (aTooYoung && !bTooYoung) return -1;
        if (!aTooYoung && bTooYoung) return 1;
        return 0;
      });
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      apps = apps.where((app) => app['name'].toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return apps;
  }

  // ====== Load installed apps from device ======
  Future<void> loadInstalledApps() async {
    try {
      final apps = await _service.getInstalledApps();
      _installedApps = apps.map((app) => app.packageName).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading installed apps: $e');
    }
  }

  // ====== Load system/default apps dynamically ======
  /// This function fetches all system apps installed on the device and
  /// filters them to include only apps useful for the child (e.g., Camera, Messages, Google)
  Future<void> loadSystemApps() async {
    try {
      final apps = await DeviceApps.getInstalledApplications(
        includeSystemApps: true,
        includeAppIcons: false,
      );

      // Keep only system apps and remove unnecessary internal/system packages
      _systemApps = apps
          .where((app) {
        final package = app.packageName.toLowerCase();
        // Keep only system apps
        if (!app.systemApp) return false;
        // Exclude some internal/system packages
        if (package.contains('launcher') || package.contains('android') && package.length < 10) return false;
        return true;
      })
          .map((app) => app.packageName)
          .toList();

      debugPrint('System apps loaded: ${_systemApps.length}');
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading system apps: $e');
    }
  }

  // ====== Blocked apps management ======
  Future<void> loadBlockedApps(String childId) async {
    try {
      _blockedApps = await _firebaseService.getBlockedApps(childId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading blocked apps: $e');
    }
  }

  Future<void> updateBlockedApps(String childId, List<String> newBlockedList) async {
    _blockedApps = newBlockedList;
    notifyListeners();
    try {
      await _firebaseService.updateBlockedApps(childId, _blockedApps);
    } catch (e) {
      debugPrint('Error updating blocked apps: $e');
    }
  }

  bool isBlocked(String packageName) => _blockedApps.contains(packageName);
  bool isInstalled(String packageName) => _installedApps.contains(packageName);
  bool isAllowedByAge(Map<String, dynamic> app) => _childAge >= app['minimumAge'];

  // Block an app immediately
  Future<void> blockAppNow(String packageName) async {
    try {
      await _service.blockApp(packageName);
    } catch (e) {
      debugPrint('Error blocking app $packageName: $e');
    }
  }

  // ====== Manage Sensitive Apps dynamically ======
  void addSensitiveApp(Map<String, dynamic> app) {
    _sensitiveApps.add(app);
    notifyListeners();
  }

  void removeSensitiveApp(String packageName) {
    _sensitiveApps.removeWhere((app) => app['package'] == packageName);
    notifyListeners();
  }

  // ====== Manage Default Apps blocking ======
  bool isDefaultAppBlocked(String packageName) => _blockedApps.contains(packageName);

  Future<void> blockDefaultApp(String childId, String packageName) async {
    if (!_blockedApps.contains(packageName)) _blockedApps.add(packageName);
    await _firebaseService.updateBlockedApps(childId, _blockedApps);
    notifyListeners();
  }

  Future<void> unblockDefaultApp(String childId, String packageName) async {
    _blockedApps.remove(packageName);
    await _firebaseService.updateBlockedApps(childId, _blockedApps);
    notifyListeners();
  }
}
