import 'package:flutter/material.dart';
import 'package:p_learn_app/models/schedule_model.dart';
import 'package:p_learn_app/screens/main_navigation/main_tab_screen.dart';
import 'package:p_learn_app/widgets/home_banners.dart';
import 'package:p_learn_app/services/notification_service.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/schedule_service.dart';
import '../../widgets/date_header.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/schedule_card.dart';
import 'widgets/schedule_empty_view.dart';
import 'widgets/schedule_error_view.dart';
import 'widgets/schedule_loading_view.dart';

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
      appBar: HomeAppBar(userId: userId, uId: uId),
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
      return const ScheduleLoadingView();
    }

    if (_errorMessage != null) {
      return ScheduleErrorView(
        errorMessage: _errorMessage!,
        onRetry: _loadSchedule,
      );
    }

    if (_scheduleItems.isEmpty) {
      return const ScheduleEmptyView();
    }

    const int itemsToShowLimit = 2;
    final itemsToShow = _scheduleItems.take(itemsToShowLimit).toList();

    return Column(
      children: [
        ...itemsToShow.map((item) => ScheduleCard(item: item)).toList(),
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
}