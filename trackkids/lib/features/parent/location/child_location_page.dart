import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../models/child_model.dart';
import 'child_location_controller.dart';

class ChildLocationPage extends StatefulWidget {
  final String childId;

  const ChildLocationPage({super.key, required this.childId});

  @override
  State<ChildLocationPage> createState() => _ChildLocationPageState();
}

class _ChildLocationPageState extends State<ChildLocationPage> {
  final ChildLocationController _controller = ChildLocationController();
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Child Location')),
      body: StreamBuilder<ChildModel?>(
        stream: _controller.childLocationStream(widget.childId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No location data available'));
          }

          final child = snapshot.data!;

          if (child.latitude == null || child.longitude == null) {
            return const Center(child: Text('Location not sent yet'));
          }

          final LatLng position =
          LatLng(child.latitude!, child.longitude!);

          final Marker childMarker = Marker(
            markerId: const MarkerId('child_marker'),
            position: position,
            infoWindow: const InfoWindow(title: 'Child'),
          );

          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: position,
              zoom: 16,
            ),
            markers: {childMarker},
            onMapCreated: (controller) {
              _mapController = controller;
            },
          );
        },
      ),
    );
  }
}
