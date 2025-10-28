import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/schedule_model.dart';

class ScheduleService {
  // TODO: Thay đổi base URL theo API của bạn
  static const String baseUrl = 'https://your-api.com/api';

  // Lấy lịch học theo ngày
  Future<List<ScheduleItem>> getScheduleByDate(DateTime date) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/schedule?date=${date.toIso8601String()}'),
        headers: {
          'Content-Type': 'application/json',
          // TODO: Thêm token nếu cần
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => ScheduleItem.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load schedule');
      }
    } catch (e) {
      print('Error fetching schedule: $e');
      rethrow;
    }
  }

  // Lấy lịch học cả tuần
  Future<List<ScheduleItem>> getWeekSchedule(DateTime startDate) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/schedule/week?start_date=${startDate.toIso8601String()}',
        ),
        headers: {
          'Content-Type': 'application/json',
          // TODO: Thêm token nếu cần
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => ScheduleItem.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load week schedule');
      }
    } catch (e) {
      print('Error fetching week schedule: $e');
      rethrow;
    }
  }

  // Mock data để test (xóa khi có API thật)
  Future<List<ScheduleItem>> getMockSchedule() async {
    await Future.delayed(const Duration(seconds: 1)); // Giả lập network delay

    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    return [
      // Monday
      ScheduleItem(
        id: '1',
        time: '08:00 - 10:00',
        subject: 'Lập trình di động',
        room: 'Phòng A101',
        date: startOfWeek,
      ),
      ScheduleItem(
        id: '2',
        time: '10:15 - 12:15',
        subject: 'Cơ sở dữ liệu',
        room: 'Phòng B203',
        date: startOfWeek,
      ),
      // Wednesday
      ScheduleItem(
        id: '3',
        time: '14:00 - 16:00',
        subject: 'Mạng máy tính',
        room: 'Phòng C305',
        date: startOfWeek.add(const Duration(days: 2)),
      ),
      // Friday
      ScheduleItem(
        id: '4',
        time: '09:00 - 11:00',
        subject: 'Kiểm thử phần mềm',
        room: 'Phòng D402',
        date: startOfWeek.add(const Duration(days: 4)),
      ),
      ScheduleItem(
        id: '5',
        time: '13:00 - 15:00',
        subject: 'Trí tuệ nhân tạo',
        room: 'Phòng E501',
        date: startOfWeek.add(const Duration(days: 4)),
      ),
    ];
  }
}
