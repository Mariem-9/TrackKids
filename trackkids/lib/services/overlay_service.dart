import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import '../widgets/show_logger.dart';
import 'dart:isolate';


/// Service to show overlay on top of blocked apps
class OverlayService {
  /// Show a blocking overlay for a specific app
  Future<void> showBlockOverlay(String packageName) async {
    try {
      // Start the foreground service
      await FlutterForegroundTask.startService(
        notificationTitle: 'TrackKids',
        notificationText: 'Blocked app: $packageName',
        callback: startOverlayTask,
      );

      ShowLogger.log('Overlay started for $packageName');
    } catch (e) {
      ShowLogger.log('Error showing overlay: $e');
    }
  }
}

/// Foreground task entry point
void startOverlayTask() {
  FlutterForegroundTask.setTaskHandler(MyOverlayTaskHandler());
}

/// Custom task handler for showing overlay
class MyOverlayTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    ShowLogger.log('Overlay task started');
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    // Called periodically, can update overlay if needed
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    ShowLogger.log('Overlay task destroyed');
  }

  @override
  Future<void> onButtonPressed(String id) async {
    // Handle notification button press if needed
  }

  @override
  Widget getForegroundTaskWidget(BuildContext context) {
    // Full-screen semi-transparent overlay
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.8),
        body: Center(
          child: Text(
            'This app is blocked!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
