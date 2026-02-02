import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase initialization error (Did you add google-services.json?): ');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const StudentScreen(),
    );
  }
}

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rollController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();

  // Access Firestore collection 'students'
  final CollectionReference _studentsCollection =
      FirebaseFirestore.instance.collection('students');

  Future<void> _addStudent() async {
    if (_nameController.text.isNotEmpty &&
        _rollController.text.isNotEmpty &&
        _courseController.text.isNotEmpty) {
      try {
        await _studentsCollection.add({
          'name': _nameController.text,
          'rollNumber': _rollController.text,
          'course': _courseController.text,
        });
        _nameController.clear();
        _rollController.clear();
        _courseController.clear();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Student added successfully')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error adding student: ')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Input Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _rollController,
                  decoration: const InputDecoration(labelText: 'Roll Number'),
                ),
                TextField(
                  controller: _courseController,
                  decoration: const InputDecoration(labelText: 'Course'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _addStudent,
                  child: const Text('Add Student'),
                ),
              ],
            ),
          ),
          const Divider(),
          // List Section
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _studentsCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No students found'));
                }

                return ListView(
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(data['name'] ?? 'No Name'),
                      subtitle: Text(
                          'Roll:  | Course: '),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
