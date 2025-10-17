class ScheduleItem {
  final String id;
  final String time;
  final String subject;
  final String room;
  final DateTime date;

  ScheduleItem({
    required this.id,
    required this.time,
    required this.subject,
    required this.room,
    required this.date,
  });

  // Parse từ JSON API
  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      id: json['id'] ?? '',
      time: json['time'] ?? '',
      subject: json['subject'] ?? '',
      room: json['room'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time,
      'subject': subject,
      'room': room,
      'date': date.toIso8601String(),
    };
  }
}