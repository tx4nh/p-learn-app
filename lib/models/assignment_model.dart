

class Assignment {
  final String id;
  final String title;
  final String? courseId; 
  final DateTime dueDate;

  Assignment({
    required this.id,
    required this.title,
    this.courseId,
    required this.dueDate,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Không có tiêu đề',
      
      courseId: json['courseId']?.toString(), 
      
      dueDate: json['dueDate'] != null 
               ? DateTime.parse(json['dueDate']) 
               : DateTime.now(),
    );
  }
}