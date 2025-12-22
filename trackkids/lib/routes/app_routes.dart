import 'package:flutter/material.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Your routing logic here
    return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text("Home"))));
  }
}