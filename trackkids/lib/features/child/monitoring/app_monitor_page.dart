import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/child/monitoring/app_monitor_controller.dart';
import '../../../models/child_model.dart';
import '/../../../features/child/overlay/block_overlay_page.dart';

/// Page to monitor installed apps on the child device
/// Shows usage and triggers overlay if time limit exceeded
class AppMonitorPage extends StatelessWidget {
  final String childId;

  const AppMonitorPage({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    final child = ChildModel(childId: childId, parentId: '');

    return ChangeNotifierProvider<AppMonitorController>(
      create: (_) => AppMonitorController()
        ..loadInstalledApps()
        ..loadScreenTimeLimits(child),
      child: Consumer<AppMonitorController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Child App Monitor'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monitoring apps for child: $childId',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  if (controller.isLoading)
                    const Center(child: CircularProgressIndicator()),

                  if (!controller.isLoading)
                    Expanded(
                      child: ListView.builder(
                        itemCount: controller.installedApps.length,
                        itemBuilder: (context, index) {
                          final appName = controller.installedApps[index];
                          final used = controller.screenTimeUsed[appName] ?? 0;
                          final limit = controller.screenTimeLimits[appName] ?? 0;
                          final exceeded = limit > 0 && used >= limit;

                          return ListTile(
                            title: Text(appName),
                            subtitle: exceeded
                                ? const Text('Time limit exceeded!',
                                style: TextStyle(color: Colors.red))
                                : Text('Used: $used / Limit: $limit mins'),
                            trailing: IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: () async {
                                bool exceeded = await controller.checkAppUsage(appName);

                                if (exceeded) {
                                  // Show overlay if time limit exceeded
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => BlockOverlayPage(
                                        packageName: appName,
                                        countdownSeconds: 300,
                                      ),
                                    ),
                                  );
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Usage checked for $appName')),
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
