// screens/schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:p_learn_app/models/schedule_model.dart';
import 'package:p_learn_app/services/schedule_service.dart';
import 'package:p_learn_app/widgets/app_colors.dart';
import 'package:p_learn_app/screens/notification/notification_screen.dart';
import 'package:p_learn_app/services/notification_service.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late Future<List<ScheduleItem>> _scheduleFuture;
  final ScheduleService _scheduleService = ScheduleService();
  DateTime _selectedDate = DateTime.now();
  final ScrollController _scrollController = ScrollController();
  final Map<DateTime, GlobalKey> _dateKeys = {};

  @override
  void initState() {
    super.initState();
    _scheduleFuture = _scheduleService.getSchedule();
  }

  Map<DateTime, List<ScheduleItem>> _groupScheduleByDate(
      List<ScheduleItem> schedule) {
    Map<DateTime, List<ScheduleItem>> grouped = {};
    for (var item in schedule) {
      DateTime date = DateTime(item.date.year, item.date.month, item.date.day);
      if (grouped[date] == null) {
        grouped[date] = [];
      }
      grouped[date]!.add(item);
    }
    return grouped;
  }

  void _scrollToDate(DateTime date) {
    final key = _dateKeys[date];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(key.currentContext!,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (Phần còn lại của file build() giữ nguyên y hệt)
    // ...
    // Toàn bộ phần còn lại của file này không cần thay đổi gì
    // ...
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Lịch học', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationScreen()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<ScheduleItem>>(
        future: _scheduleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có lịch học.'));
          }

          final groupedSchedule = _groupScheduleByDate(snapshot.data!);
          final sortedDates = groupedSchedule.keys.toList()..sort();

          // Schedule notifications
          NotificationService().scheduleAllNotifications(snapshot.data!);

          // Generate keys for each date
          _dateKeys.clear(); // Xóa key cũ đi mỗi lần build lại
          for (var date in sortedDates) {
            _dateKeys.putIfAbsent(date, () => GlobalKey());
          }

          return Column(
            children: [
              _buildWeekView(groupedSchedule),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: sortedDates.length,
                  itemBuilder: (context, index) {
                    final date = sortedDates[index];
                    final items = groupedSchedule[date]!;
                    return Column(
                      key: _dateKeys[date], // Gán key
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0, left: 4.0, top: 16.0),
                          child: Text(
                            DateFormat('EEEE, dd MMMM yyyy', 'vi_VN').format(date),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        ...items.map((item) => _buildScheduleCard(item, index)),
                        const SizedBox(height: 16.0),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWeekView(Map<DateTime, List<ScheduleItem>> groupedSchedule) {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1)); // Giả sử tuần bắt đầu T2 (weekday = 1)

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final day = startOfWeek.add(Duration(days: index));
          final dateOnly = DateTime(day.year, day.month, day.day);
          final hasSchedule = groupedSchedule.keys.any((d) => d.isAtSameMomentAs(dateOnly));
          final isSelected = _selectedDate.day == day.day && _selectedDate.month == day.month && _selectedDate.year == day.year;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = day;
              });
              if (hasSchedule) {
                _scrollToDate(dateOnly);
              }
            },
            child: Column(
              children: [
                Text(
                  DateFormat('E', 'vi_VN').format(day).substring(0, 2), // "T2", "T3", ...
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.red : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  DateFormat('d').format(day),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isSelected ? Colors.red : Colors.black,
                  ),
                ),
                const SizedBox(height: 4.0),
                if (hasSchedule)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const SizedBox(height: 6), // Thêm để giữ layout ổn định
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildScheduleCard(ScheduleItem item, int index) {
    final cardColor = AppColors.scheduleCardColors[index % AppColors.scheduleCardColors.length];
    final accentColor = AppColors.scheduleAccentColors[index % AppColors.scheduleAccentColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border(left: BorderSide(color: accentColor, width: 5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.time,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: accentColor,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.subject,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4.0),
                      Text(
                        item.room,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}