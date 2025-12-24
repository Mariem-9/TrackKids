import 'package:flutter/material.dart';

class AppMonitorPage extends StatelessWidget {
  final String childId;
  const AppMonitorPage({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Child Monitor')),
      body: Center(
        child: Text('Monitoring GPS for child: $childId'),
      ),
    );
  }
}
