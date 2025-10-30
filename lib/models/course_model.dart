// models/course_model.dart

// Lớp con để chứa thông tin lịch học
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

  // Factory để parse JSON cho một lịch học
  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      dayOfWeek: json['dayOfWeek'] ?? 0, // Mặc định là Chủ Nhật nếu null
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      room: json['room'] ?? 'N/A', // Mặc định 'N/A' nếu null
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
  final List<Schedule> schedule; // <-- Danh sách lịch học

  Course({
    required this.id,
    required this.fullName,
    required this.shortName,
    required this.startDate,
    required this.endDate,
    required this.schedule,
  });

  // Factory constructor để parse JSON đầy đủ
  factory Course.fromJson(Map<String, dynamic> json) {
    // Xử lý parse danh sách lịch học (schedule)
    var scheduleListFromJson = json['schedules'] as List? ?? []; // Lấy list, nếu null thì dùng []
    List<Schedule> parsedSchedule = scheduleListFromJson
        .map((item) => Schedule.fromJson(item))
        .toList();

    return Course(
      // Giả sử API trả về 'id' khi GET. Nếu không, bạn cần một key khác.
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(), 
      fullName: json['fullName'] ?? 'N/A',
      shortName: json['shortName'] ?? 'N/A',
      startDate: json['startDate'] ?? '', // "2025-10-30"
      endDate: json['endDate'] ?? '', // "2025-10-30"
      schedule: parsedSchedule, // Gán danh sách lịch học đã parse
    );
  }
}