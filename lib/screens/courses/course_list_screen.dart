
import 'package:flutter/material.dart';
import 'package:p_learn_app/models/course_model.dart';
import 'package:p_learn_app/screens/assignments/assignment_list_screen.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  // TODO: Replace with API call to fetch courses
  final List<Course> _courses = [
    Course(id: '1', name: 'Lập trình di động', teacherName: 'Mr. A'),
    Course(id: '2', name: 'Phát triển web', teacherName: 'Mr. B'),
    Course(id: '3', name: 'Cơ sở dữ liệu', teacherName: 'Mr. C'),
    Course(id: '4', name: 'Trí tuệ nhân tạo', teacherName: 'Mr. D'),
  ];

  final List<IconData> _courseIcons = [
    Icons.phone_android,
    Icons.web,
    Icons.storage,
    Icons.memory,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Môn học', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.redAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 10,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _courses.length,
        itemBuilder: (context, index) {
          final course = _courses[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AssignmentListScreen(course: course),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.red[100],
                      child: Icon(_courseIcons[index % _courseIcons.length], color: Colors.red),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(course.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                          const SizedBox(height: 8.0),
                          Text(course.teacherName, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.red, size: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
