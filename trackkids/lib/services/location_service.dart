import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../core/constants/firestore_paths.dart';
import '../models/child_model.dart';

class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send location and update child document using ChildModel
  Future<void> sendLocation(ChildModel child) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Update child object
    ChildModel updatedChild = ChildModel(
      childId: child.childId,
      parentId: child.parentId,
      latitude: position.latitude,
      longitude: position.longitude,
      lastUpdated: Timestamp.now(),
    );

    await _firestore
        .collection(FirestorePaths.children)
        .doc(child.childId)
        .set(updatedChild.toMap(), SetOptions(merge: true));
  }

  // Fetch child data from Firestore
  Future<ChildModel?> getChild(String childId) async {
    DocumentSnapshot doc = await _firestore
        .collection(FirestorePaths.children)
        .doc(childId)
        .get();

    if (!doc.exists) return null;
    return ChildModel.fromMap(doc.data() as Map<String, dynamic>);
  }
}
