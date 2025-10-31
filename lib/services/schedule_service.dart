import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/schedule_model.dart';
import '../models/course_model.dart';
import '../api/endpoints.dart'; // Giả sử bạn có file này

class ScheduleService {
  Future<List<ScheduleItem>> getSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      print('Error fetching schedule: Token is missing or empty.');
      throw Exception('Not authenticated. Token is missing.');
    }

    try {
      // 1. Lấy danh sách tất cả các môn học (subjects)
      final subjectsResponse = await http.get(
        Uri.parse(Endpoints.getAllSubjects),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (subjectsResponse.statusCode != 200) {
        throw Exception(
          'Failed to load subjects. Status code: ${subjectsResponse.statusCode}',
        );
      }

      final List<dynamic> subjectsData = json.decode(
        utf8.decode(subjectsResponse.bodyBytes),
      );
      final List<Course> coursesWithSchedules = [];

      // 2. Với mỗi môn học, lấy lịch học chi tiết của nó
      for (var subjectJson in subjectsData) {
        // Đảm bảo subjectJson và id của nó không null
        if (subjectJson == null || subjectJson['id'] == null) continue;
        final String subjectId = subjectJson['id'].toString();

        final scheduleResponse = await http.get(
          Uri.parse(Endpoints.getAllSchedules(subjectId)),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (scheduleResponse.statusCode == 200) {
          final List<dynamic> scheduleData = json.decode(
            utf8.decode(scheduleResponse.bodyBytes),
          );

          // 3. Gắn lịch học (schedules) vào đúng môn học của nó
          final courseJson = Map<String, dynamic>.from(subjectJson);
          courseJson['schedules'] = scheduleData;

          // 4. Parse thành đối tượng Course hoàn chỉnh
          coursesWithSchedules.add(Course.fromJson(courseJson));
        } else {
          print(
            'Warning: Failed to load schedule for subject $subjectId. Status: ${scheduleResponse.statusCode}',
          );
        }
      }

      // 5. Xử lý và chuyển đổi thành các mục lịch học để hiển thị
      return _processCoursesIntoScheduleItems(coursesWithSchedules);
    } catch (e) {
      print('Error fetching schedule: $e');
      rethrow;
    }
  }

  List<ScheduleItem> _processCoursesIntoScheduleItems(List<Course> courses) {
    final List<ScheduleItem> items = [];

    // Xóa dòng này, nó không còn cần thiết
    // final DateFormat timeFormatter = DateFormat('HH:mm');

    final Map<int, int> apiToDartWeekday = {
      0: 7,
      1: 1,
      2: 2,
      3: 3,
      4: 4,
      5: 5,
      6: 6,
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
              // === SỬA LỖI Ở ĐÂY ===
              try {
                // Giả sử API trả về "15:34:00"
                // Lấy 5 ký tự đầu tiên: "15:34"
                final startTime = rule.startTime.substring(0, 5);
                final endTime = rule.endTime.substring(0, 5);
                final timeString = '$startTime - $endTime'; // "15:34 - 17:34"

                items.add(
                  ScheduleItem(
                    id: '${course.id}-${currentDate.toIso8601String()}',
                    subject: course.fullName,
                    room: rule.room,
                    date: currentDate,
                    time: timeString, // Gán chuỗi đã format
                  ),
                );
              } catch (e) {
                print(
                  'Error parsing time string: ${rule.startTime}. Error: $e',
                );
              }
              // ===================
            }
          }
          currentDate = currentDate.add(const Duration(days: 1));
        }
      } catch (e) {
        print(
          'Error parsing date: ${course.startDate} or ${course.endDate}. Error: $e',
        );
      }
    }
    return items;
  }
}
