import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../core/constants/firestore_paths.dart';
import '../models/child_model.dart';
class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<Position>? _sub;

  void startTracking(ChildModel child) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission != LocationPermission.always) {
      permission = await Geolocator.requestPermission();
    }

    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
        //Only send a new GPS update if the child moved at least 10 meters.
        // distanceFilter: 10,
      ),
    ).listen((position) async {
      // 1. Prepare the log entry
      final newLogEntry = {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': Timestamp.now(),
      };

      // 2. Update current position AND history log
      await FirebaseFirestore.instance
          .collection(FirestorePaths.children)
          .doc(child.childId)
          .set({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'lastUpdated': FieldValue.serverTimestamp(),
        // Adds the new point to the history list
        'locationLogs': FieldValue.arrayUnion([newLogEntry]),
      }, SetOptions(merge: true));

      print("📍 Logged Movement: ${position.latitude}");
    });
  }


  void stopTracking() {
    _sub?.cancel();
  }

  Future<void> sendLocation(ChildModel child) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

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

      print("📍 GPS sent: ${position.latitude}, ${position.longitude}");
    } catch (e) {
      print("⚠️ Error sending GPS: $e");
    }
  }
  Future<ChildModel?> getChild(String childId) async {
    DocumentSnapshot doc = await _firestore
        .collection(FirestorePaths.children)
        .doc(childId)
        .get();

    if (!doc.exists) return null;
    return ChildModel.fromMap(doc.data() as Map<String, dynamic>);
  }
}
