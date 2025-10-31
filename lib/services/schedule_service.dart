import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/schedule_model.dart';
import '../models/course_model.dart';
import '../api/endpoints.dart';

class ScheduleService {
  Future<List<ScheduleItem>> getSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null || token.isEmpty) {
      print('Error fetching schedule: Token is missing or empty.');
      throw Exception('Not authenticated. Token is missing.');
    }

    try {
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

      print('[DEBUG SERVICE] Nhận được ${subjectsData.length} môn học từ API.');

      final List<Course> courses = subjectsData
          .map((json) => Course.fromJson(json))
          .toList();
      return _processCoursesIntoScheduleItems(courses);
    } catch (e) {
      print('Error fetching schedule: $e');
      rethrow;
    }
  }

  List<ScheduleItem> _processCoursesIntoScheduleItems(List<Course> courses) {
    final List<ScheduleItem> items = [];

    print('[DEBUG] Bắt đầu xử lý ${courses.length} courses.');

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
      print('[DEBUG] Đang xử lý course: ${course.fullName}');
      print('[DEBUG] ... Dữ liệu StartDate: "${course.startDate}"');
      print('[DEBUG] ... Dữ liệu EndDate: "${course.endDate}"');
      print(
        '[DEBUG] ... Môn này có ${course.schedule.length} lịch học chi tiết (rules).',
      );

      if (course.schedule.isEmpty) {
        print('[DEBUG] ... BỎ QUA vì course.schedule bị rỗng.');
        continue;
      }

      try {
        DateTime courseStartDate = DateTime.parse(course.startDate);
        DateTime courseEndDate = DateTime.parse(course.endDate);
        print('[DEBUG] ... Parse Date thành công.');

        DateTime currentDate = courseStartDate;
        while (currentDate.isBefore(courseEndDate) ||
            currentDate.isAtSameMomentAs(courseEndDate)) {
          for (final rule in course.schedule) {
            int? dartWeekday = apiToDartWeekday[rule.dayOfWeek];

            if (dartWeekday != null && currentDate.weekday == dartWeekday) {
              print(
                '[DEBUG] ... === KHỚP NGÀY! === (API day: ${rule.dayOfWeek} == Dart day: ${currentDate.weekday})',
              );
              print('[DEBUG] ...... Dữ liệu StartTime: "${rule.startTime}"');

              try {
                final startTime = rule.startTime.substring(0, 5);
                final endTime = rule.endTime.substring(0, 5);
                final timeString = '$startTime - $endTime';

                items.add(
                  ScheduleItem(
                    id: '${course.id}-${currentDate.toIso8601String()}',
                    subject: course.fullName,
                    room: rule.room,
                    date: currentDate,
                    time: timeString,
                  ),
                );
                print('[DEBUG] ...... THÊM LỊCH HỌC THÀNH CÔNG!');
              } catch (e) {
                print(
                  '[LỖI PARSE TIME] Không thể parse time: "${rule.startTime}". Lỗi: $e',
                );
              }
            }
          }
          currentDate = currentDate.add(const Duration(days: 1));
        }
      } catch (e) {
        print(
          '[LỖI PARSE DATE] Không thể parse date: "${course.startDate}" hoặc "${course.endDate}". Lỗi: $e',
        );
      }
    }

    print('[DEBUG] Xử lý xong. Tổng số items tìm được: ${items.length}');
    return items;
  }
}
