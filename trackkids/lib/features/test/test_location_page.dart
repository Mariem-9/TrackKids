import 'package:flutter/material.dart';
import '../../models/child_model.dart';
import '../../services/location_service.dart';

class TestLocationPage extends StatelessWidget {
  final LocationService _locationService = LocationService();

  TestLocationPage({super.key});

  final String testChildId = 'testChild001';
  final String testParentId = 'testParent001';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Location Service')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Send Location'),
          onPressed: () async {
            // Create child model
            ChildModel child = ChildModel(
              childId: testChildId,
              parentId: testParentId,
            );

            // Send location
            await _locationService.sendLocation(child);

            // Fetch the child data back
            ChildModel? updatedChild =
            await _locationService.getChild(testChildId);

            // Show result
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Latitude: ${updatedChild?.latitude}, Longitude: ${updatedChild?.longitude}',
                ),
              ),
            );

            // Print to console
            print(updatedChild?.toMap());
          },
        ),
      ),
    );
  }
}
