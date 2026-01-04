import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';

class ActivityReportPage extends StatelessWidget {
  final String childId;

  const ActivityReportPage({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<ProjectColors>()!;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: const Text("Web Activity"),
        backgroundColor: palette.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Collection globale activityLogs filtrée par childId
        stream: FirebaseFirestore.instance
            .collection('activityLogs')
            .where('childId', isEqualTo: childId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final logs = snapshot.data!.docs; // Liste des logs

          if (logs.isEmpty) {
            return const Center(child: Text("No activity logs yet"));
          }

          return Scrollbar(
            thumbVisibility: true, // Affiche le scroll thumb
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index].data() as Map<String, dynamic>;
                final timestamp = (log['timestamp'] as Timestamp).toDate();
                final action = log['action'] ?? 'unknown';
                final url = log['url'] ?? '';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(url),
                    subtitle: Text('Action: $action\nTime: $timestamp'),
                    trailing: Icon(
                      action == 'blocked' ? Icons.block : Icons.check,
                      color: action == 'blocked' ? Colors.red : Colors.green,
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

/*class ActivityReportPage extends StatelessWidget {
  final String childId;

  const ActivityReportPage({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<ProjectColors>()!;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: const Text("Web Activity"),
        backgroundColor: palette.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('children').doc(childId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return const Center(child: Text("No activity logs"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final List activityLogs = data['activityLogs'] ?? [];

          if (activityLogs.isEmpty) {
            return const Center(child: Text("No activity logs yet"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: activityLogs.length,
            itemBuilder: (context, index) {
              final log = activityLogs[index];
              final timestamp = (log['timestamp'] as Timestamp).toDate();

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(log['action']),
                  subtitle: Text('Time: $timestamp'),
                  trailing: Icon(
                    log['blocked'] == true ? Icons.block : Icons.check,
                    color: log['blocked'] == true ? Colors.red : Colors.green,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}*/
