import 'dart:async';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

Future<void> startAntiTheftService(String childId) async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      foregroundServiceNotificationId: 999,
      initialNotificationTitle: 'TrackKids Security',
      initialNotificationContent: 'Monitoring device status...',
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
    ),
  );

  await service.startService();

  // Send the childId to the background isolate right after starting
  // We use a slight delay to ensure the background listener is ready
  Timer(const Duration(seconds: 2), () {
    service.invoke('setData', {'childId': childId});
  });
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  // Initialize Firebase for this background isolate
  await Firebase.initializeApp();
  final firestore = FirebaseFirestore.instance;

  String childId = '';

  // Listen for the childId from the UI
  service.on('setData').listen((event) {
    if (event != null && event['childId'] != null) {
      childId = event['childId'];
      print('✅ Anti-Theft Background: Received ID: $childId');
    }
  });

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  // The main loop that checks Firestore every 5 seconds
  Timer.periodic(const Duration(seconds: 5), (timer) async {
    if (childId.isEmpty) {
      print('⚠️ Anti-Theft: Waiting for Child ID...');
      return;
    }

    try {
      final doc = await firestore.collection('children').doc(childId).get();
      if (!doc.exists) return;

      final data = doc.data();
      final commands = data?['antiTheftCommands'] as Map<String, dynamic>?;

      if (commands == null) return;

      // 🔊 Ring phone
      if (commands['ring'] == true) {
        print('🔔 Ringing starting...');
        FlutterRingtonePlayer().play(
          android: AndroidSounds.ringtone,
          ios: IosSounds.glass,
          looping: true,
        );
        await firestore.collection('children').doc(childId).update({'antiTheftCommands.ring': false});
      }

      // 🔒 Lock phone - Using notification update instead of Toast
      if (commands['lock'] == true) {
        if (service is AndroidServiceInstance) {
          service.setForegroundNotificationInfo(
            title: "DEVICE LOCKED",
            content: "This device has been remotely locked by a parent.",
          );
        }
        // 🔥This sends a message back to UI
        service.invoke('showLockScreen');

        await firestore.collection('children').doc(childId).update({'antiTheftCommands.lock': false});
        print('✅ Lock command completed');
      }

      // 📝 Lost message - Using notification update
      final lostMessage = commands['lostMessage'] as String? ?? '';
      if (lostMessage.isNotEmpty) {
        if (service is AndroidServiceInstance) {
          service.setForegroundNotificationInfo(
            title: "⚠️ URGENT MESSAGE",
            content: lostMessage,
          );
        }
        // 🔥This sends a message back to UI
        service.invoke('showMessage', {'message': lostMessage});

        await firestore.collection('children').doc(childId).update({'antiTheftCommands.lostMessage': ''});
        print('✅ Lost message displayed ');
      }

      // 📍 Locate command
      if (commands['locate'] == true) {
        Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        await firestore.collection('children').doc(childId).update({
          'latitude': pos.latitude,
          'longitude': pos.longitude,
          'lastUpdated': FieldValue.serverTimestamp(),
          'antiTheftCommands.locate': false,
        });
        print('✅ Firestore updated with new coordinates');
      }
    } catch (e) {
      print('❌ Anti-Theft Loop Error: $e');
    }
  });
}
