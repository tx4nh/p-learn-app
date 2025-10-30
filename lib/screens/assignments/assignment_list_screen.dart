
import 'package:flutter/material.dart';
import 'package:p_learn_app/models/assignment_model.dart';
import 'package:p_learn_app/models/course_model.dart';
import 'package:intl/intl.dart';

class AssignmentListScreen extends StatefulWidget {
  final Course course;

  const AssignmentListScreen({super.key, required this.course});

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  // TODO: Replace with API call to fetch assignments for the course
  final List<Assignment> _assignments = [
    Assignment(id: '1', title: 'Bài tập 1', courseId: '1', dueDate: DateTime.now().add(const Duration(days: 2))),
    Assignment(id: '2', title: 'Bài tập 2', courseId: '1', dueDate: DateTime.now().add(const Duration(days: 7))),
    Assignment(id: '3', title: 'Project cuối kỳ', courseId: '1', dueDate: DateTime.now().add(const Duration(days: 25))),
    Assignment(id: '4', title: 'Bài tập về nhà 1', courseId: '2', dueDate: DateTime.now().add(const Duration(days: 4))),
    Assignment(id: '5', title: 'Báo cáo tiến độ', courseId: '3', dueDate: DateTime.now().subtract(const Duration(days: 1))),
  ];

  late List<Assignment> _filteredAssignments;

  @override
  void initState() {
    super.initState();
    _filteredAssignments = _assignments.where((a) => a.courseId == widget.course.id).toList();
  }

  String _getDueDateInfo(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;

    if (difference < 0) {
      return 'Đã quá hạn';
    } else if (difference == 0) {
      return 'Hạn hôm nay';
    } else if (difference == 1) {
      return 'Còn 1 ngày';
    } else {
      return 'Còn $difference ngày';
    }
  }

  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;

    if (difference < 0) {
      return Colors.red;
    } else if (difference <= 3) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.course.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
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
      body: _filteredAssignments.isEmpty
          ? const Center(child: Text('Không có bài tập nào cho môn học này.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _filteredAssignments.length,
              itemBuilder: (context, index) {
                final assignment = _filteredAssignments[index];
                final dueDateInfo = _getDueDateInfo(assignment.dueDate);
                final dueDateColor = _getDueDateColor(assignment.dueDate);

                return Container(
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
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: dueDateColor.withOpacity(0.1),
                      child: Icon(Icons.assignment, color: dueDateColor),
                    ),
                    title: Text(assignment.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text(
                      'Hạn nộp: ${DateFormat('dd/MM/yyyy').format(assignment.dueDate)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    trailing: Text(
                      dueDateInfo,
                      style: TextStyle(color: dueDateColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
