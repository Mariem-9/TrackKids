import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/child/pairing/child_pairing_controller.dart';
import '../../models/child_model.dart';

class TestPairingPage extends StatelessWidget {
  final ChildPairingController _pairingController = ChildPairingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TestPairingPage({super.key});

  final String testChildId = 'testChild001';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Child Pairing')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Sign in & Pair Child'),
          onPressed: () async {
            try {
              // Sign in a test parent anonymously for testing
              if (_auth.currentUser == null) {
                await _auth.signInAnonymously();
              }

              // Pair the child
              await _pairingController.pairChildWithParent(testChildId);

              // Fetch the paired child
              ChildModel? child =
              await _pairingController.getChild(testChildId);

              // Show result in SnackBar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    child != null
                        ? 'Child paired! ParentID: ${child.parentId}'
                        : 'Failed to fetch child',
                  ),
                ),
              );

              // Print to console
              print(child?.toMap());
            } catch (e) {
              print('Error pairing child: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
