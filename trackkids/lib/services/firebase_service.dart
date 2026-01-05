import 'package:flutter/foundation.dart'; // needed for debugPrint
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// -------------------------
  /// CHILD SETTINGS
  /// -------------------------

  /// Get child settings (blocked apps + screen time limits)
  Future<Map<String, dynamic>> getChildSettings(String childId) async {
    try {
      final doc = await _firestore.collection('children').doc(childId).get();
      if (doc.exists) {
        return {
          'blocked_apps': List<String>.from(doc.data()?['blocked_apps'] ?? []),
          'screen_time_limits': Map<String, int>.from(doc.data()?['screen_time_limits'] ?? {}),
        };
      }
    } catch (e) {
      debugPrint('Error fetching child settings: $e');
    }
    return {
      'blocked_apps': [],
      'screen_time_limits': {},
    };
  }

  /// Get blocked apps for a child
  Future<List<String>> getBlockedApps(String childId) async {
    try {
      final doc = await _firestore.collection('children').doc(childId).get();
      if (doc.exists && doc.data() != null) {
        return List<String>.from(doc.data()?['blocked_apps'] ?? []);
      }
    } catch (e) {
      debugPrint('Error fetching blocked apps: $e');
    }
    return [];
  }

  /// Update blocked apps for a child
  Future<void> updateBlockedApps(String childId, List<String> apps) async {
    try {
      await _firestore.collection('children').doc(childId).set(
        {'blocked_apps': apps},
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('Error updating blocked apps: $e');
    }
  }

  /// -------------------------
  /// CHILD AGE
  /// -------------------------

  /// Get child age
  Future<int> getChildAge(String childId) async {
    try {
      final doc = await _firestore.collection('children').doc(childId).get();
      if (doc.exists && doc.data()?['age'] != null) {
        return (doc.data()?['age'] as int);
      }
    } catch (e) {
      debugPrint('Error fetching child age: $e');
    }
    return 0;
  }

  /// Update child age
  Future<void> updateChildAge(String childId, int age) async {
    try {
      await _firestore.collection('children').doc(childId).set(
        {'age': age},
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('Error updating child age: $e');
    }
  }

  /// Add new child (optional)
  Future<void> addChild(String childId, String parentId) async {
    try {
      await _firestore.collection('children').doc(childId).set({
        'parentId': parentId,
        'blocked_apps': [],
        'screen_time_limits': {},
        'latitude': 0.0,
        'longitude': 0.0,
        'lastUpdated': FieldValue.serverTimestamp(),
        'age': 0,
      });
    } catch (e) {
      debugPrint('Error adding child: $e');
    }
  }

  /// Update screen time limit for a specific app
  Future<void> updateScreenTimeLimit(String childId, String packageName, int? minutes) async {
    try {
      final docRef = _firestore.collection('children').doc(childId);

      if (minutes == null) {
        // Remove the screen time limit for this app
        await docRef.update({
          'screen_time_limits.$packageName': FieldValue.delete(),
        });
      } else {
        // Set or update the screen time limit
        await docRef.set(
          {
            'screen_time_limits': {packageName: minutes},
          },
          SetOptions(merge: true),
        );
      }
    } catch (e) {
      debugPrint('Error updating screen time limit: $e');
    }
  }

}
