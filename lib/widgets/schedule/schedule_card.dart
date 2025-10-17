import 'package:flutter/material.dart';
import '../../models/schedule_model.dart';

class ScheduleCard extends StatelessWidget {
  final ScheduleItem item;
  final Color backgroundColor;
  final Color accentColor;

  const ScheduleCard({
    super.key,
    required this.item,
    required this.backgroundColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            left: BorderSide(color: accentColor, width: 6),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimeChip(),
              const SizedBox(height: 12),
              _buildSubjectText(context),
              const SizedBox(height: 12),
              _buildRoomInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time, size: 16, color: accentColor),
          const SizedBox(width: 6),
          Text(
            item.time,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: accentColor,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectText(BuildContext context) {
    return Text(
      item.subject,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildRoomInfo() {
    return Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          size: 18,
          color: Colors.grey.shade700,
        ),
        const SizedBox(width: 6),
        Text(
          item.room,
          style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
        ),
      ],
    );
  }
}