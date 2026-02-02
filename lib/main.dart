import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: StudentList(),
    );
  }
}

class StudentList extends StatelessWidget {
  const StudentList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student List')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Error loading data'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.requireData;

          if (data.size == 0) {
            return const Center(child: Text('No students found in Firestore'));
          }

          return ListView.builder(
            itemCount: data.size,
            itemBuilder: (context, index) {
              var student = data.docs[index];
              // Using try-catch or safe access in case fields are missing in manual entry
              String name = (student.data() as Map<String, dynamic>).containsKey('name') ? student['name'] : 'No Name';
              String course = (student.data() as Map<String, dynamic>).containsKey('course') ? student['course'] : 'No Course';
              var rollNumber = (student.data() as Map<String, dynamic>).containsKey('rollNumber') ? student['rollNumber'] : 0;

              return ListTile(
                leading: CircleAvatar(child: Text(name[0].toUpperCase())),
                title: Text(name),
                subtitle: Text(course),
                trailing: Text('Roll: \'),
              );
            },
          );
        },
      ),
    );
  }
}
