import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/schedule_model.dart';
import '../models/course_model.dart';
import '../api/endpoints.dart'; // Giả sử bạn có file này

class ScheduleService {
  Future<List<ScheduleItem>> getSchedule() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');

  // === KIỂM TRA TOKEN ===
  // Kiểm tra xem token có null hoặc rỗng không
  if (token == null || token.isEmpty) {
    print('Error fetching schedule: Token is missing or empty.');
    // Ném (throw) một lỗi cụ thể để tầng UI có thể bắt và xử lý
    // Ví dụ: điều hướng về trang đăng nhập
    throw Exception('Not authenticated. Token is missing.');
  }
  // ======================

  try {
    final response = await http.get(
      Uri.parse(Endpoints.getAllSubjects),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Token đã được xác nhận là tồn tại
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      final List<Course> courses =
          data.map((item) => Course.fromJson(item)).toList();

      return _processCoursesIntoScheduleItems(courses);
    } else {
      // Bắt các lỗi từ server (ví dụ: 401 token hết hạn, 403 không có quyền)
      throw Exception(
          'Failed to load courses. Status code: ${response.statusCode}');
    }
  } catch (e) {
    // In lỗi ra console và ném lại lỗi để UI xử lý
    print('Error fetching schedule: $e');
    rethrow;
  }
}

  List<ScheduleItem> _processCoursesIntoScheduleItems(List<Course> courses) {
    final List<ScheduleItem> items = [];
    final DateFormat timeFormatter = DateFormat('HH:mm');

    final Map<int, int> apiToDartWeekday = {
      0: 7, // API Chủ Nhật (0) -> Dart Chủ Nhật (7)
      1: 1, // API Thứ 2 (1) -> Dart Thứ 2 (1)
      2: 2, 3: 3, 4: 4, 5: 5, 6: 6,
    };

    for (final course in courses) {
      try {
        DateTime courseStartDate = DateTime.parse(course.startDate);
        DateTime courseEndDate = DateTime.parse(course.endDate);

        DateTime currentDate = courseStartDate;
        while (currentDate.isBefore(courseEndDate) ||
            currentDate.isAtSameMomentAs(courseEndDate)) {
          
          for (final rule in course.schedule) {
            int? dartWeekday = apiToDartWeekday[rule.dayOfWeek];

            if (dartWeekday != null && currentDate.weekday == dartWeekday) {
              try {
                final startTime = DateTime.parse(rule.startTime).toLocal();
                final endTime = DateTime.parse(rule.endTime).toLocal();
                final timeString =
                    '${timeFormatter.format(startTime)} - ${timeFormatter.format(endTime)}';

                items.add(ScheduleItem(
                  id: '${course.id}-${currentDate.toIso8601String()}',
                  subject: course.fullName,
                  room: rule.room,
                  date: currentDate,
                  time: timeString,
                ));
              } catch (e) {
                print('Error parsing time: ${rule.startTime} or ${rule.endTime}. Error: $e');
              }
            }
          }
          currentDate = currentDate.add(const Duration(days: 1));
        }
      } catch (e) {
          print('Error parsing date: ${course.startDate} or ${course.endDate}. Error: $e');
      }
    }
    return items;
  }
}