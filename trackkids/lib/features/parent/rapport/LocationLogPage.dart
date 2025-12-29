import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/locationlog_model.dart';
import '../../../core/constants/app_colors.dart';
import 'package:intl/intl.dart';

class LocationLogPage extends StatelessWidget {
  final String childId;

  const LocationLogPage({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<ProjectColors>()!;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: const Text("Location History"),
        backgroundColor: palette.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('children').doc(childId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return const Center(child: Text("No data found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final logsData = data?['locationLogs'] as List<dynamic>? ?? [];
          final logs = logsData.map((e) => LocationLog.fromMap(e)).toList();

          // Sort logs: Most recent at the top
          logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          if (logs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off_rounded, size: 64, color: palette.tertiary?.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text("No history yet", style: TextStyle(color: palette.tertiary, fontSize: 18)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              final dateStr = DateFormat('MMM dd, hh:mm a').format(log.timestamp.toDate());
              final isLast = index == logs.length - 1;

              return IntrinsicHeight(
                child: Row(
                  children: [
                    // 1. Timeline Visual Element
                    Column(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: palette.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: palette.primary?.withOpacity(0.3),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 20),

                    // 2. Log Data Card
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: palette.neutral!.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  dateStr,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: palette.neutral,
                                  ),
                                ),
                                Icon(Icons.map_outlined, size: 18, color: palette.tertiary),
                              ],
                            ),
                            const Divider(height: 20),
                            Text(
                              "Latitude: ${log.latitude}",
                              style: TextStyle(color: palette.tertiary, fontSize: 13),
                            ),
                            Text(
                              "Longitude: ${log.longitude}",
                              style: TextStyle(color: palette.tertiary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
