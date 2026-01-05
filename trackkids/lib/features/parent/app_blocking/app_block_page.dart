// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../core/constants/app_colors.dart';
// import 'app_block_controller.dart';
//
// class AppBlockPage extends StatefulWidget {
//   final String childId;
//   const AppBlockPage({super.key, required this.childId});
//
//   @override
//   State<AppBlockPage> createState() => _AppBlockPageState();
// }
//
// class _AppBlockPageState extends State<AppBlockPage> {
//   late AppBlockController _controller;
//   final TextEditingController _ageController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AppBlockController();
//     _controller.loadInstalledApps();
//     _controller.loadBlockedApps(widget.childId);
//     _controller.loadChildAge(widget.childId).then((_) {
//       if (_controller.childAge > 0) {
//         _ageController.text = _controller.childAge.toString();
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context).extension<ProjectColors>();
//
//     return ChangeNotifierProvider.value(
//       value: _controller,
//       child: Consumer<AppBlockController>(
//         builder: (context, controller, _) {
//           final apps = controller.filteredApps;
//
//           return Scaffold(
//             backgroundColor: const Color(0xFFF6F7FB),
//             appBar: AppBar(
//               elevation: 0,
//               centerTitle: true,
//               title: const Text('App Control', style: TextStyle(fontWeight: FontWeight.bold)),
//               flexibleSpace: Container(
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Color(0xFFFF9800), Color(0xFFFFC107)],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                 ),
//               ),
//             ),
//             body: SafeArea(
//               child: Padding(
//                 padding: const EdgeInsets.all(14),
//                 child: Column(
//                   children: [
//                     // ===== Age input =====
//                     Container(
//                       padding: const EdgeInsets.all(14),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(24),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.05),
//                             blurRadius: 10,
//                             offset: const Offset(0, 5),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: TextField(
//                               controller: _ageController,
//                               keyboardType: TextInputType.number,
//                               decoration: const InputDecoration(
//                                 hintText: "Child age",
//                                 prefixIcon: Icon(Icons.cake, color: Colors.orange),
//                                 border: InputBorder.none,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
//                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//                               backgroundColor: Colors.orange,
//                             ),
//                             onPressed: () {
//                               final text = _ageController.text.trim();
//                               if (text.isEmpty) return;
//                               final age = int.tryParse(text);
//                               if (age == null) return;
//
//                               // Update age in controller + Firebase
//                               controller.updateChildAge(widget.childId, age);
//                             },
//                             child: const Text(
//                               "Confirm",
//                               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: 14),
//
//                     // ===== Search bar =====
//                     TextField(
//                       decoration: InputDecoration(
//                         hintText: "Search application",
//                         prefixIcon: const Icon(Icons.search, color: Colors.orange),
//                         filled: true,
//                         fillColor: Colors.white,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(24),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                       onChanged: controller.updateSearch,
//                     ),
//
//                     const SizedBox(height: 14),
//
//                     // ===== Apps list =====
//                     Expanded(
//                       child: apps.isEmpty
//                           ? const Center(child: Text('No applications found', style: TextStyle(fontSize: 16, color: Colors.grey)))
//                           : ListView.builder(
//                         itemCount: apps.length,
//                         itemBuilder: (context, index) {
//                           final app = apps[index];
//                           final package = app['package'];
//                           final installed = controller.isInstalled(package);
//                           final blocked = controller.isBlocked(package);
//                           final allowed = controller.isAllowedByAge(app);
//
//                           return Container(
//                             margin: const EdgeInsets.symmetric(vertical: 8),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(22),
//                               boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 6))],
//                             ),
//                             child: ListTile(
//                               contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
//                               leading: CircleAvatar(
//                                 radius: 26,
//                                 backgroundColor: installed ? Colors.orange : Colors.grey.shade400,
//                                 child: Icon(app['icon'], color: Colors.white, size: 26),
//                               ),
//                               title: Text(app['name'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: installed ? Colors.black87 : Colors.grey)),
//                               subtitle: !allowed
//                                   ? const Text('Not allowed for this age', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600))
//                                   : null,
//                               trailing: Switch.adaptive(
//                                 value: blocked,
//                                 activeColor: Colors.orange,
//                                 inactiveTrackColor: Colors.grey.shade300,
//                                 onChanged: allowed
//                                     ? (value) {
//                                   final newList = List<String>.from(controller.blockedApps);
//                                   value ? newList.add(package) : newList.remove(package);
//                                   controller.updateBlockedApps(widget.childId, newList);
//                                 }
//                                     : null,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import 'app_block_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppBlockPage extends StatefulWidget {
  final String childId;
  const AppBlockPage({super.key, required this.childId});

  @override
  State<AppBlockPage> createState() => _AppBlockPageState();
}

class _AppBlockPageState extends State<AppBlockPage> {
  late AppBlockController _controller;
  final TextEditingController _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AppBlockController();
    _controller.loadInstalledApps();
    _controller.loadSystemApps();
    _controller.loadBlockedApps(widget.childId);
    _controller.loadChildAge(widget.childId).then((_) {
      if (_controller.childAge > 0) {
        _ageController.text = _controller.childAge.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<AppBlockController>(
        builder: (context, controller, _) {
          final filteredSensitive = controller.filteredSensitiveApps;
          final installedApps = controller.installedApps
              .map((pkg) => {'name': pkg, 'package': pkg, 'icon': Icons.apps, 'minimumAge': 0})
              .toList();
          final systemApps = controller.systemApps
              .map((pkg) => {'name': pkg, 'package': pkg, 'icon': Icons.settings, 'minimumAge': 0})
              .toList();

          return Scaffold(
            backgroundColor: const Color(0xFFF6F7FB),
            appBar: AppBar(
              elevation: 0,
              centerTitle: true,
              title: const Text('App Control', style: TextStyle(fontWeight: FontWeight.bold)),
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF9800), Color(0xFFFFC107)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.orange,
              onPressed: () => _showAddSensitiveDialog(context, controller),
              child: const Icon(Icons.add),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    // ===== Age input =====
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: "Child age",
                                prefixIcon: Icon(Icons.cake, color: Colors.orange),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              backgroundColor: Colors.orange,
                            ),
                            onPressed: () {
                              final text = _ageController.text.trim();
                              if (text.isEmpty) return;
                              final age = int.tryParse(text);
                              if (age == null) return;

                              controller.updateChildAge(widget.childId, age);
                            },
                            child: const Text(
                              "Confirm",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ===== Search bar =====
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Search application",
                        prefixIcon: const Icon(Icons.search, color: Colors.orange),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: controller.updateSearch,
                    ),

                    const SizedBox(height: 14),

                    // ===== Apps list =====
                    Expanded(
                      child: ListView(
                        children: [
                          _buildSection('Sensitive Apps', filteredSensitive, controller, true),
                          _buildSection('Installed Apps', installedApps, controller, false),
                          _buildSection('Default Apps', systemApps, controller, false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build each section
  Widget _buildSection(String title, List<Map<String, dynamic>> apps, AppBlockController controller, bool isSensitive) {
    if (apps.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ...apps.map((app) {
          final package = app['package'];
          final blocked = controller.isBlocked(package);
          final allowed = controller.isAllowedByAge(app);

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 6))],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              leading: CircleAvatar(
                radius: 26,
                backgroundColor: Colors.orange,
                child: Icon(app['icon'], color: Colors.white, size: 26),
              ),
              title: Text(app['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: !allowed
                  ? const Text('Not allowed for this age', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600))
                  : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSensitive)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => controller.removeSensitiveApp(package),
                    ),
                  Switch.adaptive(
                    value: blocked,
                    activeColor: Colors.orange,
                    inactiveTrackColor: Colors.grey.shade300,
                    onChanged: allowed
                        ? (value) {
                      final newList = List<String>.from(controller.blockedApps);
                      value ? newList.add(package) : newList.remove(package);
                      controller.updateBlockedApps(widget.childId, newList);
                    }
                        : null,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 12),
      ],
    );
  }

  /// Dialog to add a new Sensitive App
  void _showAddSensitiveDialog(BuildContext context, AppBlockController controller) {
    final nameController = TextEditingController();
    final packageController = TextEditingController();
    final ageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Sensitive App'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: packageController, decoration: const InputDecoration(labelText: 'Package')),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: 'Minimum Age'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty || packageController.text.isEmpty || ageController.text.isEmpty) return;
              controller.addSensitiveApp({
                'name': nameController.text,
                'package': packageController.text,
                'icon': Icons.apps,
                'minimumAge': int.tryParse(ageController.text) ?? 0,
              });
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
