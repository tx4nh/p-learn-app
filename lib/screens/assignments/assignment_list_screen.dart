import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:p_learn_app/models/assignment_model.dart';
import 'package:p_learn_app/models/course_model.dart';
import 'package:intl/intl.dart';
import 'package:p_learn_app/api/endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AssignmentListScreen extends StatefulWidget {
  final Course course;

  const AssignmentListScreen({super.key, required this.course});

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  late Future<List<Assignment>> _assignmentsFuture;

  @override
  void initState() {
    super.initState();
    _assignmentsFuture = _fetchAssignments();
  }

  // === CÁC HÀM GỌI API ===

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      throw Exception('Người dùng chưa đăng nhập hoặc token đã hết hạn');
    }

    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Assignment>> _fetchAssignments() async {
    final subjectId = widget.course.id;
    final url = Uri.parse(Endpoints.getAllTasks(subjectId));
    final headers = await _getAuthHeaders();

    try {
      final response = await http.get(url, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((item) => Assignment.fromJson(item)).toList();
      } else {
        throw Exception('Lỗi tải dữ liệu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString()); 
    }
  }

  Future<void> _addAssignment(String title, DateTime dueDate) async {
    final url = Uri.parse(Endpoints.createTask(widget.course.id));
    final headers = await _getAuthHeaders();
    final body = jsonEncode({
      'title': title,
      'dueDate': dueDate.toIso8601String(),
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context); // Đóng dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm bài tập thành công')),
        );
        setState(() {
          _assignmentsFuture = _fetchAssignments();
        });
      } else {
        throw Exception('Lỗi: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thêm thất bại: $e')),
      );
    }
  }

  Future<void> _editAssignment(Assignment assignment, String newTitle, DateTime newDueDate) async {
    final url = Uri.parse(Endpoints.updateTask(assignment.id));
    final headers = await _getAuthHeaders();
    final body = jsonEncode({
      'title': newTitle,
      'dueDate': newDueDate.toIso8601String(),
    });

    try {
      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật bài tập thành công')),
        );
        setState(() {
          _assignmentsFuture = _fetchAssignments();
        });
      } else {
        throw Exception('Lỗi: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thất bại: $e')),
      );
    }
  }

  Future<void> _deleteAssignment(Assignment assignment) async {
    final url = Uri.parse(Endpoints.deleteTask(assignment.id));
    final headers = await _getAuthHeaders();

    try {
      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (!mounted) return;
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa bài tập thành công')),
        );
        // Tải lại danh sách
        setState(() {
          _assignmentsFuture = _fetchAssignments();
        });
      } else {
        throw Exception('Lỗi: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xóa thất bại: $e')),
      );
    }
  }



  String _getDueDateInfo(DateTime dueDate) {
    final now = DateTime.now();
    final midnightDueDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final midnightNow = DateTime(now.year, now.month, now.day);
    final difference = midnightDueDate.difference(midnightNow).inDays;

    if (difference < 0) {
      return 'Đã quá hạn';
    } else if (difference == 0) {
      return 'Hạn hôm nay';
    } else if (difference == 1) {
      return 'Còn 1 ngày';
    } else {
      return 'Còn $difference ngày';
    }
  }

  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;

    if (dueDate.isBefore(now) && difference < 0) {
      return Colors.red;
    } else if (difference <= 3) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }



  void _showAddAssignmentDialog() {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    DateTime? selectedDueDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              title: const Text('Thêm bài tập mới'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Tiêu đề bài tập',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Vui lòng nhập tiêu đề' : null,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (pickedDate != null) {
                          setStateInDialog(() {
                            selectedDueDate = pickedDate;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Hạn nộp',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          selectedDueDate == null
                              ? 'Chọn ngày'
                              : DateFormat('dd/MM/yyyy').format(selectedDueDate!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate() && selectedDueDate != null) {
                      _addAssignment(titleController.text, selectedDueDate!);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Thêm', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditAssignmentDialog(Assignment assignment) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: assignment.title);
    DateTime? selectedDueDate = assignment.dueDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              title: const Text('Chỉnh sửa bài tập'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Tiêu đề bài tập',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Vui lòng nhập tiêu đề' : null,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDueDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (pickedDate != null) {
                          setStateInDialog(() {
                            selectedDueDate = pickedDate;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Hạn nộp',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          selectedDueDate == null
                              ? 'Chọn ngày'
                              : DateFormat('dd/MM/yyyy').format(selectedDueDate!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate() && selectedDueDate != null) {
                      _editAssignment(assignment, titleController.text, selectedDueDate!);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Lưu', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmDialog(Assignment assignment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa bài tập "${assignment.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteAssignment(assignment);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAssignmentOptions(Assignment assignment) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Chỉnh sửa'),
              onTap: () {
                Navigator.pop(context); 
                _showEditAssignmentDialog(assignment);
_showEditAssignmentDialog(assignment);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Xóa'),
              onTap: () {
                Navigator.pop(context); 
                _showDeleteConfirmDialog(assignment);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.grey),
              title: const Text('Hủy'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  // === CẬP NHẬT HÀM BUILD ===

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.course.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.redAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 10,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                _assignmentsFuture = _fetchAssignments();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Assignment>>(
        future: _assignmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.red),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 60),
                    const SizedBox(height: 16),
                    Text(
                      'Không thể tải bài tập',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                     const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final assignments = snapshot.data ?? [];

          if (assignments.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.assignment_turned_in_outlined, size: 80, color: Colors.grey),
                   SizedBox(height: 16),
                   Text('Không có bài tập nào cho môn học này.'),
                ],
              )
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              final assignment = assignments[index];
              final dueDateInfo = _getDueDateInfo(assignment.dueDate);
              final dueDateColor = _getDueDateColor(assignment.dueDate);

              return Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: InkWell(
                  onLongPress: () {
                    _showAssignmentOptions(assignment);
                  },
                  borderRadius: BorderRadius.circular(12.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: dueDateColor.withOpacity(0.1),
                      child: Icon(Icons.assignment, color: dueDateColor),
                    ),
                    title: Text(assignment.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text(
                      'Hạn nộp: ${DateFormat('dd/MM/yyyy').format(assignment.dueDate)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    trailing: Text(
                      dueDateInfo,
                      style: TextStyle(color: dueDateColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAssignmentDialog,
        backgroundColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}