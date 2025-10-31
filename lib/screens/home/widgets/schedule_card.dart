import 'package:flutter/material.dart';
import 'package:p_learn_app/models/schedule_model.dart';

enum ClassStatus { upcoming, ongoing, finished }

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({super.key, required this.item});

  final ScheduleItem item;

  ClassStatus _getClassStatus(ScheduleItem item) {
    final now = DateTime.now();

    try {
      final timeParts = item.time.split(' - ');
      if (timeParts.length < 2) return ClassStatus.upcoming;

      final startTimeString = timeParts[0];
      final endTimeString = timeParts[1];

      final startHourMinute = startTimeString.split(':');
      final endHourMinute = endTimeString.split(':');

      if (startHourMinute.length < 2 || endHourMinute.length < 2) {
        return ClassStatus.upcoming;
      }

      final startTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(startHourMinute[0]),
        int.parse(startHourMinute[1]),
      );

      final endTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(endHourMinute[0]),
        int.parse(endHourMinute[1]),
      );

      if (now.isBefore(startTime)) {
        return ClassStatus.upcoming;
      } else if (now.isAfter(endTime)) {
        return ClassStatus.finished;
      } else {
        return ClassStatus.ongoing;
      }
    } catch (e) {
      return ClassStatus.upcoming;
    }
  }

  Color _getStatusColor(ClassStatus status) {
    switch (status) {
      case ClassStatus.upcoming:
        return Colors.grey.shade600;
      case ClassStatus.ongoing:
        return Colors.green.shade600;
      case ClassStatus.finished:
        return Colors.red.shade600;
    }
  }

  Color _getStatusBackgroundColor(ClassStatus status) {
    switch (status) {
      case ClassStatus.upcoming:
        return Colors.grey.shade50;
      case ClassStatus.ongoing:
        return Colors.green.shade50;
      case ClassStatus.finished:
        return Colors.red.shade50;
    }
  }

  Color _getStatusBorderColor(ClassStatus status) {
    switch (status) {
      case ClassStatus.upcoming:
        return Colors.grey.shade300;
      case ClassStatus.ongoing:
        return Colors.green.shade300;
      case ClassStatus.finished:
        return Colors.red.shade300;
    }
  }

  String _getStatusText(ClassStatus status, ScheduleItem item) {
    final now = DateTime.now();

    switch (status) {
      case ClassStatus.upcoming:
        try {
          final startTimeString = item.time.split(' - ')[0];
          final hourMinute = startTimeString.split(':');
          final startTime = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(hourMinute[0]),
            int.parse(hourMinute[1]),
          );
          final difference = startTime.difference(now);

          if (difference.inMinutes > 60) {
            return "Sắp diễn ra lúc $startTimeString";
          } else if (difference.inMinutes > 0) {
            return "Sắp diễn ra trong ${difference.inMinutes} phút";
          } else {
            return "Sắp diễn ra";
          }
        } catch (e) {
          return "Sắp diễn ra";
        }
      case ClassStatus.ongoing:
        return "Đang diễn ra";
      case ClassStatus.finished:
        return "Đã kết thúc";
    }
  }

  IconData _getStatusIcon(ClassStatus status) {
    switch (status) {
      case ClassStatus.upcoming:
        return Icons.schedule_rounded;
      case ClassStatus.ongoing:
        return Icons.play_circle_filled_rounded;
      case ClassStatus.finished:
        return Icons.check_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _getClassStatus(item);
    final statusColor = _getStatusColor(status);
    final backgroundColor = _getStatusBackgroundColor(status);
    final borderColor = _getStatusBorderColor(status);
    final statusText = _getStatusText(status, item);
    final statusIcon = _getStatusIcon(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.subject,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_filled,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      item.time,
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4.0),
                    Expanded(
                      child: Text(
                        item.room,
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}