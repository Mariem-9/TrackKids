import 'dart:async';
import 'dart:ui'; // Essential for DartPluginRegistrant
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Request all location permissions
Future<bool> requestPermissions() async {
  final statuses = await [
    Permission.location,
    Permission.locationWhenInUse,
    Permission.locationAlways,
  ].request();

  return statuses.values.every((status) => status.isGranted);
}

/// Call this from your Child app after pairing
Future<void> startLocationService(String childId, String parentId) async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      foregroundServiceNotificationId: 888,
      initialNotificationTitle: 'TrackKids running',
      initialNotificationContent: 'Live GPS tracking active',
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      onBackground: (_) async => true,
    ),
  );

  await service.startService();

  service.invoke('setData', {
    'childId': childId,
    'parentId': parentId,
  });
}
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  print('🔹 Background service started');

  try {
    // 1️⃣ Initialize plugins & Firebase
    print('🔹 Initializing DartPluginRegistrant...');
    DartPluginRegistrant.ensureInitialized();

    print('🔹 Initializing Firebase...');
    await Firebase.initializeApp();
    final firestore = FirebaseFirestore.instance;
    print('✅ Firebase initialized');

    // 2️⃣ Android: foreground service
    if (service is AndroidServiceInstance) {
      print('🔹 Setting as foreground service');
      service.setAsForegroundService();
    }

    // 3️⃣ Wait for childId & parentId
    String childId = '';
    String parentId = '';

    service.on('setData').listen((event) async {
      print('🔹 Received setData event: $event');

      if (event == null) {
        print('❌ Event is null, cannot start GPS');
        return;
      }

      childId = event['childId'] ?? '';
      parentId = event['parentId'] ?? '';

      if (childId.isEmpty || parentId.isEmpty) {
        print('❌ childId or parentId is empty');
        return;
      }

      print('✅ childId=$childId, parentId=$parentId');

      // 4️⃣ Start periodic GPS only after IDs are received
      Timer.periodic(const Duration(seconds: 15), (timer) async {
        try {
          print('🔹 Getting current position...');
          final pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
          );

          print('✅ Position received: ${pos.latitude}, ${pos.longitude}');

          /// WithOUT log map
          // await firestore.collection('children').doc(childId).set({
          //   'latitude': pos.latitude,
          //   'longitude': pos.longitude,
          //   'lastUpdated': FieldValue.serverTimestamp(),
          //   'parentId': parentId,
          // }, SetOptions(merge: true));
          //
          // print('✅ GPS sent to Firestore');

          /// With log map
          final newLogEntry = {
            'latitude': pos.latitude,
            'longitude': pos.longitude,
            'timestamp': Timestamp.now(),
          };
          await firestore.collection('children').doc(childId).set({
            'latitude': pos.latitude,
            'longitude': pos.longitude,
            'lastUpdated': FieldValue.serverTimestamp(),
            'parentId': parentId,
            'locationLogs': FieldValue.arrayUnion([newLogEntry]),
          }, SetOptions(merge: true));

          print('✅ GPS and History Log updated in Firestore');


          if (service is AndroidServiceInstance) {
            service.setForegroundNotificationInfo(
              title: 'TrackKids running',
              content: 'Lat: ${pos.latitude}, Lng: ${pos.longitude}',
            );
          }
        } catch (e) {
          print('❌ GPS Error: $e');
        }
      });
    });
  } catch (e, stack) {
    print('❌ Background service setup error: $e');
    print(stack);
  }
}
