import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import '../child/pairing/child_pairing_page.dart';
import '../child/pairing/child_pairing_controller.dart';
import '../parent/dashboard/parent_dashboard_page.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/theme_provider.dart';


class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Access your custom palette
    final palette = Theme.of(context).extension<ProjectColors>()!;
    final themeProvider = Provider.of<ThemeProvider>(context);

    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final ChildPairingController _pairingController = ChildPairingController();


    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: const Text('TrackKids'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(color: palette.neutral, fontSize: 22, fontWeight: FontWeight.bold),
        actions: [
          // 2. The Theme Switcher Button
          IconButton(
            icon: Icon(Icons.palette_outlined, color: palette.primary),
            tooltip: "Switch Palette",
            onPressed: () {
              // Simple logic to cycle through your 3 palettes
              if (palette == ProjectColors.paletteOne) {
                themeProvider.updatePalette(ProjectColors.paletteTwo);
              } else if (palette == ProjectColors.paletteTwo) {
                themeProvider.updatePalette(ProjectColors.paletteThree);
              } else {
                themeProvider.updatePalette(ProjectColors.paletteOne);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Friendly Illustration/Icon
              Icon(
                Icons.family_restroom_rounded,
                size: 100,
                color: palette.primary,
              ),
              const SizedBox(height: 20),

              // 2. Catchy Heading
              Text(
                'TrackKids',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: palette.neutral,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Safety is just a tap away.\nWho is using the device today?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: palette.tertiary),
              ),
              const SizedBox(height: 48),

              // 3. Parent Selection Card
              _buildRoleCard(
                context,
                title: "I am a Parent",
                subtitle: "Monitor location & app usage",
                icon: Icons.shield_rounded,
                color: palette.primary!,
                onTap: () async {
                  try {

                    // 1️⃣ Sign in anonymously if not signed in
                    if (_auth.currentUser == null) {
                      await _auth.signInAnonymously();
                    }

                    final user = _auth.currentUser!;

                    // Ask parent to enter child ID
                    String? childId = await showDialog<String>(
                      context: context,
                      builder: (context) {
                        final _childController = TextEditingController();
                        return AlertDialog(
                          title: const Text('Enter Child ID'),
                          content: TextField(controller: _childController),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, _childController.text.trim()),
                              child: const Text('Pair'),
                            ),
                          ],
                        );
                      },
                    );

                    if (childId == null || childId.isEmpty) return;

                    // Pair the child
                    await _pairingController.pairChildWithParent(childId);

                    // Write a parent document in Firestore for RoleRouter
                    await _firestore.collection('parents').doc(user.uid).set(
                      {'role': 'parent'},
                      SetOptions(merge: true),
                    );

                    // Show confirmation
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Child paired successfully!')),
                    );

                    // Navigate to ParentDashboardPage
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const ParentDashboardPage()),
                    );

                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
              ),

              const SizedBox(height: 20),

              // 4. Child Selection Card
              _buildRoleCard(
                context,
                title: "I am a Child",
                subtitle: "Connect your device safely",
                icon: Icons.child_care_rounded,
                color: palette.secondary!,
                onTap: () async {
                  try {
                    // Navigate to Child Pairing Page
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChildPairingPage()),
                    );

                    // Optionally, you can check if pairing was successful
                    if (result == true) {
                      // Child is now paired, store role in Firestore
                      final FirebaseAuth _auth = FirebaseAuth.instance;
                      final FirebaseFirestore _firestore = FirebaseFirestore.instance;

                      final user = _auth.currentUser;
                      if (user != null) {
                        await _firestore.collection('children').doc(user.uid).set(
                          {'role': 'child'},
                          SetOptions(merge: true),
                        );
                      }
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    final palette = Theme.of(context).extension<ProjectColors>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: palette.neutral,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: palette.tertiary),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: palette.tertiary),
          ],
        ),
      ),
    );
  }
}
