import 'package:flutter/material.dart';
import 'child_pairing_controller.dart';
import '../../../services/location_service.dart';
import '../../../models/child_model.dart';
import '../../../core/constants/app_colors.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/background_location_service.dart';
import '../../../services/anti_theft_service.dart';

import 'package:flutter_background_service/flutter_background_service.dart';
import '../browser/safe_browse_page.dart';


class ChildPairingPage extends StatefulWidget {
  const ChildPairingPage({super.key});

  @override
  State<ChildPairingPage> createState() => _ChildPairingPageState();
}

class _ChildPairingPageState extends State<ChildPairingPage> {
  final TextEditingController _childIdController = TextEditingController();
  final ChildPairingController _controller = ChildPairingController();
  bool _loading = false;
  bool _showBrowserButton = false;


  /// 🛡️ Listener Anti-Theft
  @override
  void initState() {
    super.initState();

    /// 🛡️ Listener Anti-Theft: show Message Popup
    FlutterBackgroundService().on('showMessage').listen((event) {
      if (event != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Parent Message"),
            content: Text(event['message']),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))],
          ),
        );
      }
    });
    /// 🛡️ Listener Anti-Theft: show lock screen
    FlutterBackgroundService().on('showLockScreen').listen((event) {
      // Access the palette from the top-level context
      final palette = Theme.of(context).extension<ProjectColors>()!;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            // Using a deep red for urgency or your palette's neutral for a "Blackout" look
            backgroundColor: const Color(0xFFB71C1C),
            body: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 1. High-Visibility Security Icon
                  const Icon(
                    Icons.report_problem_rounded,
                    color: Colors.white,
                    size: 100,
                  ),
                  const SizedBox(height: 40),

                  // 2. Clear, Authoritative Message
                  const Text(
                    "DEVICE LOCKED",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    "This device has been remotely locked by a parent for security reasons.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // 3. Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          "Tracking Active",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }


  Future<void> _pair() async {
    setState(() => _loading = true);

    try {
      final childId = _childIdController.text.trim();

      // Attach this phone to child
      await _controller.attachThisDeviceToChild(childId);
      // Get parentId from current user
      final child = await _controller.getChild(childId);
      if (child == null) throw Exception("Child not found in Firestore");

      final parentId = child.parentId;


      ChildModel childModel = ChildModel(
        childId: childId,
        parentId: parentId,
      );
      // 3️⃣ Start background tracking
      LocationService().startTracking(childModel);

      // Ask for location permissions
      bool granted = await requestPermissions();
      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permissions are required")),
        );
        return;
      }
      // 🔥 Start REAL background GPS
      startLocationService(child.childId, child.parentId);

      // 🛡️ Start Anti-Theft Service
      startAntiTheftService(child.childId);


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tracking started in background')),
      );
      setState(() {
        _showBrowserButton = true;
      });


      // ✅ REDIRECTION VERS LE NAVIGATEUR SÉCURISÉ
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (_) => SafeBrowserPage(childId: childId),
      //   ),
      // );


    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<ProjectColors>()!;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: const Text('Device Setup'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(color: palette.neutral, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: palette.neutral),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // 1. Visual Illustration of Pairing
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: palette.primary!.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.phonelink_setup_rounded,
                size: 80,
                color: palette.primary,
              ),
            ),
            const SizedBox(height: 32),

            // 2. Instructional Text
            Text(
              "Link Child Device",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: palette.neutral),
            ),
            const SizedBox(height: 12),
            Text(
              "Enter the unique ID provided by the parent app to start tracking.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: palette.tertiary),
            ),
            const SizedBox(height: 40),

            // 3. Styled Input Field
            TextField(
              controller: _childIdController,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
              decoration: InputDecoration(
                labelText: 'Child ID Code',
                labelStyle: TextStyle(color: palette.tertiary, letterSpacing: 0),
                hintText: 'e.g. TK-8892',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: palette.primary!.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: palette.primary!, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // 4. Action Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: _loading
                  ? Center(child: CircularProgressIndicator(color: palette.primary))
                  : ElevatedButton(
                onPressed: _pair,
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Confirm Connection',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            if (_showBrowserButton) ...[
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    final childId = _childIdController.text.trim();

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SafeBrowserPage(childId: childId),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Open Safe Browser",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ]

          ],
        ),
      ),
    );
  }
}

