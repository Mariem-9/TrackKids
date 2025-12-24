import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';

class ParentDashboardPage extends StatelessWidget {
  const ParentDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the current active palette
    final palette = Theme.of(context).extension<ProjectColors>()!;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: const Text('Parent Dashboard'),
        backgroundColor: palette.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {}, // Future settings
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Welcome Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: palette.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hello, Parent!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your child is currently being tracked.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 2. Grid of Features
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "Control Center",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: palette.neutral,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                // Location Card
                _buildDashboardCard(
                  context,
                  title: "Live Location",
                  icon: Icons.map_rounded,
                  color: palette.primary!,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.parentLocation),
                ),

                // Placeholder for App Blocking (Next Feature)
                _buildDashboardCard(
                  context,
                  title: "App Limits",
                  icon: Icons.block_flipped,
                  color: palette.secondary!,
                  onTap: () {},
                ),

                // Placeholder for Activity Reports
                _buildDashboardCard(
                  context,
                  title: "Reports",
                  icon: Icons.bar_chart_rounded,
                  color: palette.tertiary!,
                  onTap: () {},
                ),

                // Placeholder for Device Info
                _buildDashboardCard(
                  context,
                  title: "Battery Level",
                  icon: Icons.battery_charging_full_rounded,
                  color: Colors.green,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget for Dashboard Items
  Widget _buildDashboardCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    final palette = Theme.of(context).extension<ProjectColors>()!;

    return GestureDetector(
      onTap: onTap,
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
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