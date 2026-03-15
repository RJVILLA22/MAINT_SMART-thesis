import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // ensure you have firebase_options.dart setup
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore Test Seeder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: SeedTestScreen(),
    );
  }
}

class SeedTestScreen extends StatefulWidget {
  @override
  _SeedTestScreenState createState() => _SeedTestScreenState();
}

class _SeedTestScreenState extends State<SeedTestScreen> {
  final TextEditingController _toolIdController = TextEditingController(
    text: 'Tv9ij5PjP40yOKlhmXYp',
  );
  final TextEditingController _userIdController = TextEditingController(
    text: 'QoQECNZPHshHUb9K1hLitklwEWg1',
  );
  String _selectedAction = 'borrow';
  String _status = '';

  Future<void> seedTestTransaction(
    String toolId,
    String userId,
    String action,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('transactions').add({
        'toolId': toolId,
        'userId': userId,
        'action': action,
        'timestamp': DateTime.now(),
      });
      setState(() {
        _status = '✅ Seeded "$action" for tool $toolId';
      });
      print('🧾 Seeded $action transaction for $toolId');
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
      });
      print('❌ Error seeding transaction: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firestore Seeder')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter test data to add to Firestore:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _toolIdController,
              decoration: const InputDecoration(
                labelText: 'Tool ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: 'User ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedAction,
              decoration: const InputDecoration(
                labelText: 'Action',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'borrow', child: Text('Borrow')),
                DropdownMenuItem(value: 'return', child: Text('Return')),
              ],
              onChanged: (v) => setState(() => _selectedAction = v!),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed:
                  () => seedTestTransaction(
                    _toolIdController.text.trim(),
                    _userIdController.text.trim(),
                    _selectedAction,
                  ),
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Seed to Firestore'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _status,
              style: TextStyle(
                color:
                    _status.startsWith('✅') ? Colors.green : Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
