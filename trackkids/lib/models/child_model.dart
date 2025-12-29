import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:trackkids/models/antitheftcommands_model.dart';
import 'package:trackkids/models/locationlog_model.dart';

class ChildModel {
  final String childId;
  final String parentId;
  final double? latitude;
  final double? longitude;
  final Timestamp? lastUpdated;

  final AntiTheftCommandsModel? antiTheftCommands;
  final List<LocationLog>? locationLogs;

  ChildModel({
    required this.childId,
    required this.parentId,
    this.latitude,
    this.longitude,
    this.lastUpdated,
    this.antiTheftCommands,
    this.locationLogs,
  });

  // Convert Firestore document to ChildModel
  factory ChildModel.fromMap(Map<String, dynamic> map) {
    return ChildModel(
      childId: map['childId'] ?? '',
      parentId: map['parentId'] ?? '',
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      lastUpdated: map['lastUpdated'],
      antiTheftCommands: map['antiTheftCommands'] != null
          ? AntiTheftCommandsModel.fromMap(map['antiTheftCommands'])
          : null,
      locationLogs: map['locationLogs'] != null
          ? List<LocationLog>.from(
          map['locationLogs'].map((log) => LocationLog.fromMap(log))
      )
          : null,

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
      'antiTheftCommands': antiTheftCommands?.toMap(),
      'locationLogs': locationLogs?.map((log) => log.toMap()).toList(),
    };
  }
}
