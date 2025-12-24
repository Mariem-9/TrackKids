import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../parent/dashboard/parent_dashboard_page.dart';
import '../child/monitoring/app_monitor_page.dart';
import 'welcome_page.dart';

class RoleRouter extends StatefulWidget {
  const RoleRouter({super.key});

  @override
  State<RoleRouter> createState() => _RoleRouterState();
}

class _RoleRouterState extends State<RoleRouter> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _loading = true;
  Widget _homePage = const Scaffold();

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final user = _auth.currentUser;

    if (user == null) {
      // Not logged in
      _homePage = const WelcomePage();
    } else {
      // Check if user is parent
      final parentDoc = await _firestore.collection('parents').doc(user.uid).get();
      if (parentDoc.exists) {
        _homePage = const ParentDashboardPage();
      } else {
        // Check if user is paired as a child
        final childQuery = await _firestore
            .collection('children')
            .where('childId', isEqualTo: user.uid)
            .get();

        if (childQuery.docs.isNotEmpty) {
          _homePage = AppMonitorPage(childId: user.uid); // child GPS sender
        } else {
          // Not paired yet
          _homePage = const WelcomePage();
        }
      }
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _homePage;
  }
}
