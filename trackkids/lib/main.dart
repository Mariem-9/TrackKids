import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'core/constants/app_colors.dart';
import 'providers/theme_provider.dart';
import 'routes/app_routes.dart';
import 'features/auth/role_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // ===== Connect to Firebase Emulators =====
  // Firestore Emulator
  FirebaseFirestore.instance.useFirestoreEmulator('10.0.2.2', 8080);
  // Auth Emulator
  FirebaseAuth.instance.useAuthEmulator('10.0.2.2', 9099);

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
    // Listen to the theme provider to rebuild on change
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'TrackKids',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme, // Uses the dynamic palette
      home: const RoleRouter(),
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}

