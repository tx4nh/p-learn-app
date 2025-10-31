import 'package:flutter/material.dart';

class ScheduleLoadingView extends StatelessWidget {
  const ScheduleLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40.0),
        child: CircularProgressIndicator(),
      ),
    );
  }
}