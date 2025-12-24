import 'package:flutter/material.dart';
import 'child_pairing_controller.dart';
import '../../../services/location_service.dart';
import '../../../models/child_model.dart';
import '../../../core/constants/app_colors.dart';

class ChildPairingPage extends StatefulWidget {
  const ChildPairingPage({super.key});

  @override
  State<ChildPairingPage> createState() => _ChildPairingPageState();
}

class _ChildPairingPageState extends State<ChildPairingPage> {
  final TextEditingController _childIdController = TextEditingController();
  final ChildPairingController _controller = ChildPairingController();
  bool _loading = false;

  Future<void> _pair() async {
    setState(() => _loading = true);

    try {
      final childId = _childIdController.text.trim();

      // 1️⃣ Attach device to child
      await _controller.attachThisDeviceToChild(childId);

      // 2️⃣ Fetch full ChildModel from Firestore
      ChildModel? child = await _controller.getChild(childId);
      if (child == null) throw Exception("Failed to fetch child after pairing.");

      // 3️⃣ Start GPS tracking
      LocationService().startTracking(child);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Child paired & GPS started')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
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
          ],
        ),
      ),
    );
  }
}

