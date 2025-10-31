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

     

      final List<Course> courses = subjectsData
          .map((json) => Course.fromJson(json))
          .toList();
      return _processCoursesIntoScheduleItems(courses);
    } catch (e) {

      rethrow;
    }
  }

  List<ScheduleItem> _processCoursesIntoScheduleItems(List<Course> courses) {
    final List<ScheduleItem> items = [];

   

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
    

      if (course.schedule.isEmpty) {
      
        continue;
      }

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
                
              } catch (e) {
                // Handle time parsing errors
              }
            }
          }
          currentDate = currentDate.add(const Duration(days: 1));
        }
      } catch (e) {
        // Handle date parsing errors
      }
    }

    return items;
  }
}
