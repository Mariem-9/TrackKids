import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/child_model.dart';
import 'app_monitor_controller.dart';

class AppMonitorPage extends StatelessWidget {
  final String childId;
  const AppMonitorPage({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppMonitorController()..loadInstalledApps(),
      child: Consumer<AppMonitorController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Child Monitor'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display the childId / GPS info
                  Text(
                    'Monitoring GPS for child: $childId',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Loading indicator
                  if (controller.isLoading)
                    const Center(child: CircularProgressIndicator()),

                  // List of installed apps
                  if (!controller.isLoading)
                    Expanded(
                      child: ListView.builder(
                        itemCount: controller.installedApps.length,
                        itemBuilder: (context, index) {
                          final appName = controller.installedApps[index];
                          return ListTile(
                            title: Text(appName),
                            trailing: IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: () async {
                                // Optionally check screen time for this child
                                await controller.checkScreenTime(
                                  ChildModel(
                                    childId: childId,
                                    parentId: '', // Fill parentId if needed
                                  ),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Screen time checked for $appName')),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
