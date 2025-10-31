import 'package:flutter/material.dart';
import 'package:p_learn_app/models/schedule_model.dart';
import 'package:p_learn_app/screens/notification/notification_screen.dart';
import 'package:p_learn_app/screens/main_navigation/main_tab_screen.dart';
import 'package:p_learn_app/widgets/home_banners.dart';
import 'package:p_learn_app/services/notification_service.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/schedule_service.dart';
import '../../widgets/date_header.dart';
import 'package:intl/date_symbol_data_local.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum ClassStatus { upcoming, ongoing, finished }

class _HomeScreenState extends State<HomeScreen> {
  final ScheduleService _scheduleService = ScheduleService();
  List<ScheduleItem> _scheduleItems = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('vi_VN', null);
    _loadSchedule();
  }

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

  Future<void> _loadSchedule() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final allSchedules = await _scheduleService.getSchedule();

      final now = DateTime.now();
      final todaySchedules = allSchedules.where((item) {
        return item.date.year == now.year &&
            item.date.month == now.month &&
            item.date.day == now.day;
      }).toList();

      await NotificationService().scheduleAllNotifications(todaySchedules);

      setState(() {
        _scheduleItems = todaySchedules;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải lịch học. Vui lòng thử lại.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUsername ?? 'Không có mã SV';
    final uId = userId.substring(userId.length - 3);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(userId, uId),
      body: RefreshIndicator(
        onRefresh: _loadSchedule,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          children: [
            Center(child: DateHeader(date: DateTime.now())),
            const SizedBox(height: 24),
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildContent(),
            const HomeBanners(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(String userId, String uId) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Xin chào, PTITer $uId!',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Mã Sinh Viên: $userId',
            style: const TextStyle(fontSize: 15, color: Colors.white),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          color: Colors.white,
          iconSize: 28,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            );
          },
          tooltip: 'Thông báo',
        ),
        const SizedBox(width: 8),
      ],
      backgroundColor: Colors.red,
      elevation: 0,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Lịch học hôm nay',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red.shade700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadSchedule,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_scheduleItems.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Text('Không có lịch học hôm nay.'),
        ),
      );
    }

    const int itemsToShowLimit = 2;
    final itemsToShow = _scheduleItems.take(itemsToShowLimit).toList();

    return Column(
      children: [
        ...itemsToShow
            .map((item) => _buildScheduleCardWithStatus(item))
            .toList(),
          Column(
            children: [
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const MainTabScreen(initialIndex: 2),
                      ),
                    );
                  },
                  child: const Text(
                    'Xem thêm',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildScheduleCardWithStatus(ScheduleItem item) {
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
