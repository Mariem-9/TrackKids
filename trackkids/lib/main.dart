import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_colors.dart';
import 'providers/theme_provider.dart';
import 'routes/app_routes.dart';

void main() {
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
      onGenerateRoute: AppRoutes.generateRoute,
      // Change this to your initial route (e.g., login or splash)
      initialRoute: '/',
    );
  }
}
