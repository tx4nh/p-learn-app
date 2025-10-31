import 'package:flutter/material.dart';
import 'package:p_learn_app/models/schedule_model.dart';
import 'package:p_learn_app/screens/notification/notification_screen.dart';
import 'package:p_learn_app/screens/main_navigation/main_tab_screen.dart';
import 'package:p_learn_app/widgets/app_colors.dart';
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

  // TODO: Gọi API thật ở đây
  Future<void> _loadSchedule() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Option 1: Gọi API thật
      // final schedule = await _scheduleService.getScheduleByDate(DateTime.now());

      // Option 2: Dùng mock data để test
      final schedule = await _scheduleService.getSchedule();

      // Schedule notifications
      await NotificationService().scheduleAllNotifications(schedule);

      setState(() {
        _scheduleItems = schedule;
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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
            style: TextStyle(fontSize: 15, color: Colors.white),
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
              MaterialPageRoute(builder: (context) => const NotificationScreen()),
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

    // Show only the first 2 items
    final itemsToShow = _scheduleItems.take(2).toList();

    return Column(
      children: [
        ...itemsToShow.asMap().entries.map((entry) {
          int index = entry.key;
          ScheduleItem item = entry.value;
          return _buildScheduleCard(item, index);
        }).toList(),
        if (_scheduleItems.length > 2)
          Column(
            children: [
              // const Text("...", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MainTabScreen(initialIndex: 2)),
                  );
                },
                child: const Text('Xem thêm', style: TextStyle(color: Colors.red) ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildScheduleCard(ScheduleItem item, int index) {
    final accentColor = AppColors.scheduleAccentColors[index % AppColors.scheduleAccentColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border(left: BorderSide(color: accentColor, width: 5)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 5),
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
