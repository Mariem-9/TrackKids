import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';

class ReportsSelectionPage extends StatelessWidget {
  final String childId;

  const ReportsSelectionPage({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<ProjectColors>()!;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: const Text("Activity Reports"),
        backgroundColor: palette.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select a report type for child: $childId",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: palette.neutral?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),

            // 📍 Location History Option
            _buildReportOption(
              context,
              title: "Location History",
              subtitle: "View paths and past locations",
              icon: Icons.route_rounded,
              color: Colors.blue,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.locationLogs,
                );
              },
            ),

            const SizedBox(height: 16),

            // 📱 App Usage Option
            _buildReportOption(
              context,
              title: "App History",
              subtitle: "See which apps were used and for how long",
              icon: Icons.history_toggle_off_rounded,
              color: Colors.teal,
              onTap: () {
                // Navigate to your App Usage Page
                // Navigator.push(context, MaterialPageRoute(builder: (_) => AppHistoryPage(childId: childId)));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportOption(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    final palette = Theme.of(context).extension<ProjectColors>()!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: palette.neutral!.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              radius: 28,
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: palette.neutral,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}