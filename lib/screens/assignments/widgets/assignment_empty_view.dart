import 'package:flutter/material.dart';

class AssignmentEmptyView extends StatelessWidget {
  const AssignmentEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined,
              size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('Không có bài tập nào cho môn học này.'),
        ],
      ),
    );
  }
}