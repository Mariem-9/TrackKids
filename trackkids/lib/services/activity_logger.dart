import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityLogger {
  static Future<void> log({
    required String childId,
    required String url,
    required String action, // "blocked" | "allowed"
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('activityLogs') // collection globale
          .add({
        'childId': childId,
        'url': url,
        'action': action,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print('Activity log error: $e');
    }
  }
}



/*import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityLogger {
  static Future<void> log({
    required String childId,
    required String url,
    required String action, // "blocked" | "allowed"
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('activityLogs')
          .add({
        'childId': childId,
        'url': url,
        'action': action,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      // Log silencieux (ne pas bloquer l'app enfant)
      print('Activity log error: $e');
    }
  }
}*/
