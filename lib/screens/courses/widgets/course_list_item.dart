import 'package:flutter/material.dart';
import 'package:p_learn_app/models/course_model.dart';

class CourseListItem extends StatelessWidget {
  final Course course;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onMorePressed;

  const CourseListItem({
    super.key,
    required this.course,
    required this.icon,
    required this.onTap,
    required this.onLongPress,
    required this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    final String roomDisplay = course.schedule.isNotEmpty 
        ? course.schedule.first.room
        : 'Chưa có phòng';

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
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
                child: Icon(icon, color: Colors.red),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      roomDisplay,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onPressed: onMorePressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}