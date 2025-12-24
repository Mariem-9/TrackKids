import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../models/child_model.dart';

class ChildLocationController {
  /// Stream child location updates from Firestore
  Stream<ChildModel?> childLocationStream(String childId) {
    return FirebaseFirestore.instance
        .collection(FirestorePaths.children)
        .doc(childId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return ChildModel.fromMap(snapshot.data()!);
    });
  }
}
