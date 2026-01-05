import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import '../widgets/show_logger.dart';

class OverlayService {
  bool _isRunning = false;

  /// Start overlay for a specific app
  Future<void> showBlockOverlay(String packageName) async {
    if (_isRunning) return;
    _isRunning = true;

    try {
      // Set task handler
      FlutterForegroundTask.setTaskHandler(OverlayTaskHandler(packageName));

      // Start the service
      await FlutterForegroundTask.startService(
        notificationTitle: 'TrackKids',
        notificationText: 'Blocked app: $packageName',
      );

      ShowLogger.log('Overlay started for $packageName');
    } catch (e) {
      ShowLogger.log('Error showing overlay: $e');
      _isRunning = false;
    }
  }

  /// Stop overlay
  Future<void> stopOverlay() async {
    if (!_isRunning) return;
    await FlutterForegroundTask.stopService();
    _isRunning = false;
    ShowLogger.log('Overlay stopped');
  }
}

/// Task handler for overlay
class OverlayTaskHandler extends TaskHandler {
  final String packageName;

  OverlayTaskHandler(this.packageName);

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter taskStarter) async {
    ShowLogger.log('Overlay task started for $packageName');
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    ShowLogger.log('Overlay repeat event');
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isCancelled) async {
    ShowLogger.log('Overlay task destroyed');
  }

  @override
  Future<void> onButtonPressed(String id) async {
    ShowLogger.log('Notification button pressed: $id');
  }

  @override
  Widget getForegroundTaskWidget(BuildContext context) {
    // Full-screen overlay
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.block, size: 80, color: Colors.white),
            const SizedBox(height: 24),
            const Text(
              'This app is blocked!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'You cannot use $packageName right now.',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
