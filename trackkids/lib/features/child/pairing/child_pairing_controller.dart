import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../models/child_model.dart';

class ChildPairingController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Creates a child record in Firestore and links it to the logged-in parent.
  Future<void> pairChildWithParent(String childId) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("No parent logged in. Please log in first.");
    }

    final parentId = user.uid;

    // Create a ChildModel instance
    ChildModel child = ChildModel(
      childId: childId,
      parentId: parentId,
      latitude: null,
      longitude: null,
      lastUpdated: null,
    );

    // Write to Firestore using ChildModel
    await _firestore
        .collection(FirestorePaths.children)
        .doc(childId)
        .set(child.toMap(), SetOptions(merge: true));
  }

  /// Marks this phone as the physical device assigned to that child.
  Future<void> attachThisDeviceToChild(String childId) async {
    final doc = await _firestore
        .collection(FirestorePaths.children)
        .doc(childId)
        .get();

    if (!doc.exists) {
      throw Exception("Invalid Child ID. Ask your parent to create one.");
    }

    await _firestore
        .collection(FirestorePaths.children)
        .doc(childId)
        .set({
      'deviceLinked': true,
    }, SetOptions(merge: true));
  }


  /// Fetch a child document as a ChildModel
  Future<ChildModel?> getChild(String childId) async {
    DocumentSnapshot doc =
    await _firestore.collection(FirestorePaths.children).doc(childId).get();

    if (!doc.exists) return null;
    return ChildModel.fromMap(doc.data() as Map<String, dynamic>);
  }
}
