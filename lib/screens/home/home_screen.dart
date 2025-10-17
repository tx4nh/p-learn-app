import 'package:flutter/material.dart';
import 'package:p_learn_app/models/schedule_model.dart';
import 'package:p_learn_app/widgets/schedule/schedule_list.dart';
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
      final schedule = await _scheduleService.getMockSchedule();

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
    final userEmail = authService.currentUserEmail ?? 'Không có email';
    final userName = userEmail.split('@').first;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(userName, userEmail),
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
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(String userName, String userEmail) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Xin chào, $userName!',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            'Mã Sinh Viên: $userEmail',
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          iconSize: 28,
          onPressed: () {
            print('Hiển thị thông báo!');
          },
          tooltip: 'Thông báo',
        ),
        const SizedBox(width: 8),
      ],
      backgroundColor: Colors.white,
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
        TextButton(
          onPressed: () {
            // TODO: Điều hướng đến màn hình lịch học cả tuần
          },
          child: const Text('Xem tất cả'),
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

    return ScheduleList(scheduleItems: _scheduleItems);
  }
}
