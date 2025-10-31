import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:p_learn_app/models/assignment_model.dart';

class AssignmentListItem extends StatelessWidget {
  const AssignmentListItem({
    super.key,
    required this.assignment,
    required this.onLongPress,
  });

  final Assignment assignment;
  final VoidCallback onLongPress;

  String _getDueDateInfo(DateTime dueDate) {
    final now = DateTime.now();
    final midnightDueDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final midnightNow = DateTime(now.year, now.month, now.day);
    final difference = midnightDueDate.difference(midnightNow).inDays;

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

    if (dueDate.isBefore(now) && difference < 0) {
      return Colors.red;
    } else if (difference <= 3) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
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
      child: InkWell(
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: dueDateColor.withOpacity(0.1),
            child: Icon(Icons.assignment, color: dueDateColor),
          ),
          title: Text(assignment.title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          subtitle: Text(
            'Hạn nộp: ${DateFormat('dd/MM/yyyy').format(assignment.dueDate)}',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          trailing: Text(
            dueDateInfo,
            style: TextStyle(color: dueDateColor, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}