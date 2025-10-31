import 'package:flutter/material.dart';

class ScheduleEmptyView extends StatelessWidget {
  const ScheduleEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40.0),
        child: Text('Không có lịch học hôm nay.'),
      ),
    );
  }
}