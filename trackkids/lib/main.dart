// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// // ignore: unused_import
// import 'core/constants/app_colors.dart';
// import 'providers/theme_provider.dart';
// import 'routes/app_routes.dart';
// import 'features/auth/role_router.dart';
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//
//   // ===== Connect to Firebase Emulators =====
//   // Firestore Emulator
//   FirebaseFirestore.instance.useFirestoreEmulator('10.0.2.2', 8080);
//   // Auth Emulator
//   FirebaseAuth.instance.useAuthEmulator('10.0.2.2', 9099);
//
//   runApp(
//     ChangeNotifierProvider(
//       create: (_) => ThemeProvider(),
//       child: const TrackKidsApp(),
//     ),
//   );
// }
//
// class TrackKidsApp extends StatelessWidget {
//   const TrackKidsApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // Listen to the theme provider to rebuild on change
//     final themeProvider = Provider.of<ThemeProvider>(context);
//
//     return MaterialApp(
//       title: 'TrackKids',
//       debugShowCheckedModeBanner: false,
//       theme: themeProvider.currentTheme, // Uses the dynamic palette
//       home: const RoleRouter(),
//       onGenerateRoute: AppRoutes.generateRoute,
//     );
//   }
// }
//
//
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'providers/theme_provider.dart';
import 'routes/app_routes.dart';
import 'features/auth/role_router.dart';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'services/overlay_service.dart';

/// Empty callback required for ForegroundTaskEventAction
class EmptyEventAction implements ForegroundTaskEventAction {
  @override
  void call() {
  }

  @override
  // TODO: implement interval
  int? get interval => throw UnimplementedError();

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

  @override
  // TODO: implement type
  ForegroundTaskEventType get type => throw UnimplementedError();

}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Connect to Firebase Emulators
  FirebaseFirestore.instance.useFirestoreEmulator('10.0.2.2', 8080);
  FirebaseAuth.instance.useAuthEmulator('10.0.2.2', 9099);

  // Initialize Foreground Task (v9+)
  FlutterForegroundTask.init(
    androidNotificationOptions:  AndroidNotificationOptions(
      channelId: 'trackkids_channel',
      channelName: 'TrackKids Foreground Service',
      channelDescription: 'Overlay and app blocking notifications',
      channelImportance: NotificationChannelImportance.HIGH,
      priority: NotificationPriority.HIGH,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      autoRunOnBoot: false,
      allowWakeLock: true,
      allowWifiLock: true,
      eventAction: EmptyEventAction(), // ✅ type correct
    ),
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const TrackKidsApp(),
    ),
  );
}

class TrackKidsApp extends StatelessWidget {
  const TrackKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'TrackKids',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme,
      home: const RoleRouter(),
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
