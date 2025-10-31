import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:p_learn_app/models/assignment_model.dart';
import 'package:p_learn_app/models/course_model.dart';
import 'package:p_learn_app/api/endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/add_assignment_dialog.dart';
import 'widgets/assignment_empty_view.dart';
import 'widgets/assignment_error_view.dart';
import 'widgets/assignment_list_item.dart';
import 'widgets/edit_assignment_dialog.dart';

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
      final response = await http
          .get(url, headers: headers)
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
        Navigator.pop(context);
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

  Future<void> _editAssignment(
      Assignment assignment, String newTitle, DateTime newDueDate) async {
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

  void _showAddAssignmentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddAssignmentDialog(
          onAddAssignment: _addAssignment,
        );
      },
    );
  }

  void _showEditAssignmentDialog(Assignment assignment) {
    showDialog(
      context: context,
      builder: (context) {
        return EditAssignmentDialog(
          assignment: assignment,
          onEditAssignment: _editAssignment,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.course.fullName,
            style:
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            return AssignmentErrorView(error: snapshot.error.toString());
          }

          final assignments = snapshot.data ?? [];

          if (assignments.isEmpty) {
            return const AssignmentEmptyView();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              final assignment = assignments[index];
              return AssignmentListItem(
                assignment: assignment,
                onLongPress: () {
                  _showAssignmentOptions(assignment);
                },
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