import 'package:flutter/material.dart';
import 'package:provider/provider.dart';import '../../../models/child_model.dart';

import 'screen_time_controller.dart';
import '../../../core/constants/app_colors.dart';

class ScreenTimePage extends StatelessWidget {
  final String childId;

  const ScreenTimePage({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ScreenTimeController>(
      create: (_) => ScreenTimeController()..loadScreenTime(ChildModel(childId: childId, parentId: '')), // dummy parentId if needed
      child: Consumer<ScreenTimeController>(
        builder: (context, controller, _) {
          final themeColors = Theme.of(context).extension<ProjectColors>()!;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Screen Time Limits'),
              backgroundColor: themeColors.primary,
            ),
            body: controller.screenTimeLimits.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: controller.screenTimeLimits.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final entry = controller.screenTimeLimits.entries.elementAt(index);
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: ListTile(
                    title: Text(entry.key, style: TextStyle(color: themeColors.neutral, fontWeight: FontWeight.w600)),
                    subtitle: Text('Limit: ${entry.value} min', style: TextStyle(color: themeColors.secondary)),
                    trailing: IconButton(
                      icon: Icon(Icons.edit, color: themeColors.primary),
                      onPressed: () async {
                        int tempLimit = entry.value;
                        int? newLimit = await showDialog<int>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Set new limit for ${entry.key}'),
                            content: TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(hintText: 'Minutes'),
                              onChanged: (value) => tempLimit = int.tryParse(value) ?? entry.value,
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Cancel')),
                              TextButton(onPressed: () => Navigator.pop(context, tempLimit), child: const Text('Save')),
                            ],
                          ),
                        );

                        if (newLimit != null) {
                          controller.updateScreenTime(ChildModel(childId: childId, parentId: ''), entry.key, newLimit);
                        }
                      },
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
