import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/child_model.dart';
import 'screen_time_controller.dart';
import '../../../core/constants/app_colors.dart';

/// Page to manage screen time for each app
class ScreenTimePage extends StatelessWidget {
  final String childId;

  const ScreenTimePage({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ScreenTimeController>(
      create: (_) => ScreenTimeController()
        ..loadAppsAndScreenTime(ChildModel(childId: childId, parentId: '')),
      child: Consumer<ScreenTimeController>(
        builder: (context, controller, _) {
          final themeColors = Theme.of(context).extension<ProjectColors>()!;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Apps & Screen Time'),
              backgroundColor: themeColors.primary,
            ),
            body: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: controller.apps.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final app = controller.apps[index];
                final package = app['package'];
                final currentLimit = controller.screenTimeLimits[package];

                // App icon
                Widget iconWidget;
                if (app['iconBytes'] != null) {
                  iconWidget = Image.memory(
                    app['iconBytes'],
                    width: 40,
                    height: 40,
                  );
                } else {
                  iconWidget =
                      Icon(Icons.apps, size: 40, color: Colors.grey);
                }

                final TextEditingController textController =
                TextEditingController(
                    text: currentLimit != null
                        ? controller.formatMinutes(currentLimit)
                        : '');

                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: ListTile(
                    leading: Stack(
                      children: [
                        iconWidget,
                        if (app['sensitive'] == true)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'S',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Text(app['name']),
                    subtitle: currentLimit != null
                        ? Text(
                      'Time limit: ${controller.formatMinutes(currentLimit)}',
                      style: const TextStyle(
                          color: Colors.black87, fontSize: 14),
                    )
                        : const Text('No limit set',
                        style: TextStyle(
                            color: Colors.black54, fontSize: 14)),
                    trailing: SizedBox(
                      width: 150,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Edit / Set new limit
                          IconButton(
                            icon: Icon(Icons.edit, color: themeColors.primary),
                            onPressed: () async {
                              String inputValue = '';

                              String? result =
                              await showDialog<String>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text(
                                      'Set screen time for ${app['name']} (hh:mm)'),
                                  content: TextField(
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: currentLimit != null
                                          ? controller.formatMinutes(currentLimit)
                                          : 'hh:mm',
                                    ),
                                    onChanged: (value) {
                                      inputValue = value;
                                    },
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, null),
                                        child: const Text('Cancel')),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, inputValue),
                                        child: const Text('Save')),
                                  ],
                                ),
                              );

                              if (result != null && result.trim().isNotEmpty) {
                                final minutes =
                                controller.parseTime(result.trim());
                                if (minutes != null) {
                                  controller.updateScreenTimeLimit(
                                      ChildModel(
                                          childId: childId, parentId: ''),
                                      package,
                                      minutes);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                      content: Text(
                                          'Time limit updated for ${app['name']}')));
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                      content: Text(
                                          'Invalid format. Use hh:mm')));
                                }
                              }
                            },
                          ),
                          // Remove limit
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              controller.removeScreenTimeLimit(
                                  ChildModel(
                                      childId: childId, parentId: ''),
                                  package);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Time limit removed for ${app['name']}')));
                            },
                          ),
                        ],
                      ),
                    ),
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
