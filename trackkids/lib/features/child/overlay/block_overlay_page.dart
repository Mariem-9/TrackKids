import 'package:flutter/material.dart';
import '../../../services/overlay_service.dart';

class BlockOverlayPage extends StatelessWidget {
  final String packageName;

  const BlockOverlayPage({super.key, required this.packageName});

  @override
  Widget build(BuildContext context) {
    // Call the overlay service immediately when this page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OverlayService().showBlockOverlay(packageName);
    });

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
              Text(
                'This app is blocked',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
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
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Optional: Close the overlay page manually
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
