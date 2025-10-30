// models/assignment_model.dart

class Assignment {
  final String id;
  final String title;
  final String? courseId; // API có thể không trả về trường này
  final DateTime dueDate;

  Assignment({
    required this.id,
    required this.title,
    this.courseId,
    required this.dueDate,
  });

  // Factory constructor để parse JSON từ API
  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Không có tiêu đề',
      
      // API /getAll/{subjectId} có thể không trả về courseId
      courseId: json['courseId']?.toString(), 
      
      // Parse chuỗi (String) ngày tháng từ API thành đối tượng DateTime
      // Cung cấp một giá trị dự phòng (fallback) nếu 'dueDate' bị null
      dueDate: json['dueDate'] != null 
               ? DateTime.parse(json['dueDate']) 
               : DateTime.now(),
    );
  }
}