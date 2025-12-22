import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestFirebasePage extends StatelessWidget {
  const TestFirebasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Test')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Add Test Child'),
          onPressed: () async {
            try {
              final docRef = await FirebaseFirestore.instance
                  .collection('children')
                  .add({
                'parentId': 'testParent',
                'latitude': 36.8,
                'longitude': 10.18,
                'lastUpdated': Timestamp.now(),
              });

              // Show a snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Child added with ID: ${docRef.id}')),
              );

              // Also print to console
              print('Child added: ${docRef.id}');
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error adding child: $e')),
              );
              print('Error adding child: $e');
            }
          },
        ),
      ),
    );
  }
}
