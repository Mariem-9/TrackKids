import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';

class BlockedSitesPage extends StatefulWidget {
  final String childId;

  const BlockedSitesPage({super.key, required this.childId});

  @override
  State<BlockedSitesPage> createState() => _BlockedSitesPageState();
}

class _BlockedSitesPageState extends State<BlockedSitesPage> {
  final TextEditingController _urlController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<ProjectColors>()!;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: const Text("Blocked Sites"),
        backgroundColor: palette.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      hintText: "Enter URL to block",
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addBlockedSite,
                  child: const Text("Add"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: _firestore.collection('children').doc(widget.childId).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.data() == null) {
                    return const Center(child: Text("No blocked sites yet"));
                  }
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final List blockedSites = data['blockedSites'] ?? [];

                  return ListView.builder(
                    itemCount: blockedSites.length,
                    itemBuilder: (context, index) {
                      final site = blockedSites[index];
                      return ListTile(
                        title: Text(site),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeBlockedSite(site),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addBlockedSite() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    final docRef = _firestore.collection('children').doc(widget.childId);

    await docRef.set({
      'blockedSites': FieldValue.arrayUnion([url])
    }, SetOptions(merge: true));

    _urlController.clear();
  }

  Future<void> _removeBlockedSite(String url) async {
    final docRef = _firestore.collection('children').doc(widget.childId);

    await docRef.update({
      'blockedSites': FieldValue.arrayRemove([url])
    });
  }
}
