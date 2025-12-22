import 'package:cloud_firestore/cloud_firestore.dart';

class ChildModel {
  final String childId;
  final String parentId;
  final double? latitude;
  final double? longitude;
  final Timestamp? lastUpdated;

  ChildModel({
    required this.childId,
    required this.parentId,
    this.latitude,
    this.longitude,
    this.lastUpdated,
  });

  // Convert Firestore document to ChildModel
  factory ChildModel.fromMap(Map<String, dynamic> map) {
    return ChildModel(
      childId: map['childId'] ?? '',
      parentId: map['parentId'] ?? '',
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      lastUpdated: map['lastUpdated'],
    );
  }

  // Convert ChildModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'childId': childId,
      'parentId': parentId,
      'latitude': latitude,
      'longitude': longitude,
      'lastUpdated': lastUpdated,
    };
  }
}
