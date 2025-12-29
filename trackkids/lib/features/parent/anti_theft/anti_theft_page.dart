import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../location/child_location_page.dart';

class AntiTheftPage extends StatelessWidget {
  final String childId;

  const AntiTheftPage({super.key, required this.childId});

  Future<void> sendCommand(String childId, String command, dynamic value) async {
    final firestore = FirebaseFirestore.instance;

    await firestore.collection('children').doc(childId).set({
      'antiTheftCommands': {
        command: value,
      }
    }, SetOptions(merge: true));

    print('✅ Command sent: $command -> $value for childId=$childId');
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<ProjectColors>()!;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: const Text('Device Security'),
        backgroundColor: palette.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('children').doc(childId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final double? lat = data?['latitude'];
          final double? lng = data?['longitude'];
          final Timestamp? lastSeen = data?['lastUpdated'];

          return Column(
            children: [
              // 1. Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: palette.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.smartphone_rounded, size: 35, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Child Device: $childId",
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      lastSeen != null
                          ? "Last updated: ${DateFormat('HH:mm:ss').format(lastSeen.toDate())}"
                          : "Waiting for signal...",
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Location Info Card
              if (lat != null && lng != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: InkWell( // 👈 Added InkWell for clickability
                    onTap: () {
                      // Option A: Navigate using your existing PageRoute logic
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChildLocationPage(childId: childId),
                        ),
                      );

                      // Option B: If you want to use the named route exactly as in your switch case:
                      // Navigator.pushNamed(context, '/parentLocation', arguments: childId);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.my_location, color: Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Current Coordinates", style: TextStyle(fontWeight: FontWeight.bold)),
                                Text("$lat, $lng", style: const TextStyle(fontSize: 14)),
                                const SizedBox(height: 4),
                                const Text(
                                    "Tap to view on map",
                                    style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w600)
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue), // 👈 Added arrow icon
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Security Commands",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: palette.neutral),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 3. Command Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildCommandCard(
                        context,
                        label: "Locate",
                        icon: Icons.location_on_rounded,
                        color: Colors.blue,
                        onTap: () => sendCommand(childId, 'locate', true),
                      ),
                      _buildCommandCard(
                        context,
                        label: "Play Sound",
                        icon: Icons.volume_up_rounded,
                        color: Colors.orange,
                        onTap: () => sendCommand(childId, 'ring', true),
                      ),
                      _buildCommandCard(
                        context,
                        label: "Lock Device",
                        icon: Icons.lock_rounded,
                        color: Colors.redAccent,
                        onTap: () => sendCommand(childId, 'lock', true),
                      ),
                      _buildCommandCard(
                        context,
                        label: "Send Message",
                        icon: Icons.message_rounded,
                        color: Colors.teal,
                        onTap: () async {
                          String? message = await showDialog<String>(
                            context: context,
                            builder: (context) {
                              final controller = TextEditingController();
                              return AlertDialog(
                                title: const Text('Enter lost message'),
                                content: TextField(controller: controller),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, null),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, controller.text),
                                    child: const Text('Send'),
                                  ),
                                ],
                              );
                            },
                          );
                          if (message != null && message.isNotEmpty) {
                            sendCommand(childId, 'lostMessage', message);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCommandCard(
      BuildContext context, {
        required String label,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    final palette = Theme.of(context).extension<ProjectColors>()!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: palette.neutral!.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: palette.neutral,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
