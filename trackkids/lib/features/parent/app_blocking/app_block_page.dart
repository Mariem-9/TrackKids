import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/theme_provider.dart';
import 'app_block_controller.dart';

class AppBlockPage extends StatelessWidget {
  final String childId;

  const AppBlockPage({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<ProjectColors>()!;
    return ChangeNotifierProvider(
      create: (_) => AppBlockController()
        ..loadInstalledApps()
        ..loadBlockedApps(childId),
      child: Consumer<AppBlockController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('App Blocking'),
              backgroundColor: theme.primary,
            ),
            body: controller.installedApps.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: controller.installedApps.length,
              itemBuilder: (context, index) {
                final app = controller.installedApps[index];
                final blocked = controller.isBlocked(app);
                return ListTile(
                  title: Text(app),
                  trailing: Switch(
                    value: blocked,
                    activeColor: theme.accent,
                    onChanged: (value) {
                      final newList = List<String>.from(controller.blockedApps);
                      if (value) {
                        newList.add(app);
                      } else {
                        newList.remove(app);
                      }
                      controller.updateBlockedApps(childId, newList);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
