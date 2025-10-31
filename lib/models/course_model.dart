
class Schedule {
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final String room;

  Schedule({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.room,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      dayOfWeek: json['dayOfWeek'] ?? 0,
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      room: json['room'] ?? 'N/A',
    );
  }
}

// Lớp Course chính
class Course {
  final String id;
  final String fullName;
  final String shortName;
  final String startDate;
  final String endDate;
  final List<Schedule> schedule; 

  Course({
    required this.id,
    required this.fullName,
    required this.shortName,
    required this.startDate,
    required this.endDate,
    required this.schedule,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    var scheduleListFromJson = json['schedules'] as List? ?? []; 
    List<Schedule> parsedSchedule = scheduleListFromJson
        .map((item) => Schedule.fromJson(item))
        .toList();

    return Course(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(), 
      fullName: json['fullName'] ?? 'N/A',
      shortName: json['shortName'] ?? 'N/A',
      startDate: json['startDate'] ?? '', 
      endDate: json['endDate'] ?? '', 
      schedule: parsedSchedule, // Gán danh sách lịch học đã parse
    );
  }
}