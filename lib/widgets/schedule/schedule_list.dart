import 'package:flutter/material.dart';
import 'package:p_learn_app/models/schedule_model.dart';
import '../app_colors.dart';
import 'schedule_card.dart';

class ScheduleList extends StatelessWidget {
  final List<ScheduleItem> scheduleItems;

  const ScheduleList({
    super.key,
    required this.scheduleItems,
  });

  @override
  Widget build(BuildContext context) {
    if (scheduleItems.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0),
          child: Text('Bạn không có lịch học nào hôm nay. 🎉'),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: scheduleItems.length,
      itemBuilder: (context, index) {
        final item = scheduleItems[index];
        final color = AppColors.scheduleCardColors[index % AppColors.scheduleCardColors.length];
        final accentColor = AppColors.scheduleAccentColors[index % AppColors.scheduleAccentColors.length];
        
        return ScheduleCard(
          item: item,
          backgroundColor: color,
          accentColor: accentColor,
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 12),
    );
  }
}