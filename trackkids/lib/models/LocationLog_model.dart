import 'package:cloud_firestore/cloud_firestore.dart';

class LocationLog {
  final double latitude;
  final double longitude;
  final Timestamp timestamp;

  LocationLog({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory LocationLog.fromMap(Map<String, dynamic> map) {
    return LocationLog(
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      timestamp: map['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp,
    };
  }
}
