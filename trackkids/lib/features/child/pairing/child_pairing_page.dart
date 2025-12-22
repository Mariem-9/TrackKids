import 'package:flutter/material.dart';
import 'child_pairing_controller.dart';

class ChildPairingPage extends StatefulWidget {
  const ChildPairingPage({super.key});

  @override
  State<ChildPairingPage> createState() => _ChildPairingPageState();
}

class _ChildPairingPageState extends State<ChildPairingPage> {
  final TextEditingController _childIdController = TextEditingController();
  final ChildPairingController _controller = ChildPairingController();

  bool _loading = false;

  Future<void> _pair() async {
    setState(() => _loading = true);
    try {
      await _controller.pairChildWithParent(_childIdController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Child paired successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pair Child Device')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _childIdController,
              decoration: const InputDecoration(
                labelText: 'Enter Child ID',
              ),
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _pair,
              child: const Text('Pair'),
            ),
          ],
        ),
      ),
    );
  }
}
