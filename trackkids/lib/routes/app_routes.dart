import 'package:flutter/material.dart';
import '../features/test/test_firebase_page.dart';
import '../features/test/test_location_page.dart';
import '../features/test/test_pairing_page.dart';
import '../features/child/pairing/child_pairing_page.dart';

class AppRoutes {
  static const String testFirebase = '/testFirebase';
  static const String testLocation = '/testLocation';
  static const String testPairing = '/testPairing';
  static const String childPairing = '/childPairing';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case testFirebase:
        return MaterialPageRoute(builder: (_) => const TestFirebasePage());
      case testLocation:
        return MaterialPageRoute(builder: (_) => TestLocationPage());
      case testPairing:
        return MaterialPageRoute(builder: (_) => TestPairingPage());
      case childPairing:
        return MaterialPageRoute(builder: (_) => const ChildPairingPage());
      default:
        return MaterialPageRoute(builder: (_) => const ChildPairingPage());
    }
  }
}
