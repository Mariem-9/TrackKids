import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// -------------------------
  /// CHILD SETTINGS
  /// -------------------------
  /// Get all child settings (blocked apps + screen time limits)
  Future<Map<String, dynamic>> getChildSettings(String childId) async {
    final doc = await _firestore.collection('children').doc(childId).get();
    if (doc.exists) {
      return {
        'blocked_apps': List<String>.from(doc.data()?['blocked_apps'] ?? []),
        'screen_time_limits': Map<String, int>.from(doc.data()?['screen_time_limits'] ?? {}),
      };
    }
    return {
      'blocked_apps': [],
      'screen_time_limits': {},
    };
  }

  /// -------------------------
  /// BLOCKED APPS
  /// -------------------------
  /// Get list of blocked apps for a child
  Future<List<String>> getBlockedApps(String childId) async {
    final doc = await _firestore.collection('children').doc(childId).get();
    if (doc.exists && doc.data() != null) {
      return List<String>.from(doc.data()?['blocked_apps'] ?? []);
    }
    return [];
  }

  /// Update blocked apps for a child
  Future<void> updateBlockedApps(String childId, List<String> apps) async {
    await _firestore.collection('children').doc(childId).set(
      {'blocked_apps': apps},
      SetOptions(merge: true),
    );
  }

  /// -------------------------
  /// SCREEN TIME
  /// -------------------------
  /// Get screen time limits for a child
  Future<Map<String, int>> getScreenTimeLimits(String childId) async {
    final doc = await _firestore.collection('children').doc(childId).get();
    if (doc.exists && doc.data() != null) {
      return Map<String, int>.from(doc.data()?['screen_time_limits'] ?? {});
    }
    return {};
  }

  /// Update screen time limit for a specific app
  Future<void> updateScreenTimeLimit(String childId, String packageName, int minutes) async {
    await _firestore.collection('children').doc(childId).set(
      {
        'screen_time_limits': {
          packageName: minutes,
        }
      },
      SetOptions(merge: true),
    );
  }

  /// -------------------------
  /// ADDITIONAL HELPERS
  /// -------------------------
  /// Add a new child document
  Future<void> addChild(String childId, String parentId) async {
    await _firestore.collection('children').doc(childId).set({
      'parentId': parentId,
      'blocked_apps': [],
      'screen_time_limits': {},
      'latitude': 0.0,
      'longitude': 0.0,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  /// Update child location (used by GPS service)
  Future<void> updateChildLocation(String childId, double lat, double lng) async {
    await _firestore.collection('children').doc(childId).update({
      'latitude': lat,
      'longitude': lng,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }
}
