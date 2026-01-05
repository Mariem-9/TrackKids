import 'dart:async';
import 'package:flutter/material.dart';
import '../../../services/overlay_service.dart';

/// Overlay page shown when an app is blocked or time limit is exceeded.
/// Shows a countdown before forcing the app to close.
class BlockOverlayPage extends StatefulWidget {
  final String packageName;
  final int countdownSeconds; // Seconds before app is blocked

  const BlockOverlayPage({
    super.key,
    required this.packageName,
    this.countdownSeconds = 300, // default 5 minutes
  });

  @override
  State<BlockOverlayPage> createState() => _BlockOverlayPageState();
}

class _BlockOverlayPageState extends State<BlockOverlayPage> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.countdownSeconds;
    _startCountdown();
  }

  /// Countdown timer that updates every second
  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        // Stop overlay when countdown reaches zero
        OverlayService().stopOverlay();
        timer.cancel();
        Navigator.of(context).pop();
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    OverlayService().stopOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_remainingSeconds ~/ 60);
    final seconds = (_remainingSeconds % 60);

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.block, size: 80, color: Colors.white),
              const SizedBox(height: 24),
              const Text(
                'This app will be blocked',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'App: ${widget.packageName}',
                style: const TextStyle(color: Colors.white70, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Closing in: $minutes:${seconds.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  // Stop overlay manually
                  _timer?.cancel();
                  await OverlayService().stopOverlay();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                child: const Text('Exit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
