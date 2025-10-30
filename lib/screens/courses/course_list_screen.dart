import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:p_learn_app/models/course_model.dart';
import 'package:p_learn_app/screens/assignments/assignment_list_screen.dart';
import 'package:p_learn_app/api/endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  late Future<List<Course>> _coursesFuture;

  final List<IconData> _courseIcons = [
    Icons.phone_android,
    Icons.web,
    Icons.storage,
    Icons.memory,
    Icons.computer,
    Icons.code,
  ];

  @override
  void initState() {
    super.initState();
    _coursesFuture = _fetchCourses();
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

  Future<List<Course>> _fetchCourses() async {
    final url = Uri.parse(Endpoints.getAllSubjects);
    final headers = await _getAuthHeaders();

    try {
      final response = await http.get(url, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((item) => Course.fromJson(item)).toList();
      } else {
        throw Exception('Lỗi tải dữ liệu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString()); 
    }
  }

  Future<void> _addCourse(Map<String, dynamic> courseData) async {
    final url = Uri.parse(Endpoints.createSubject);
    final headers = await _getAuthHeaders();
    final body = jsonEncode(courseData);

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm môn học thành công')),
        );
        setState(() {
          _coursesFuture = _fetchCourses();
        });
      } else {
         print('DEBUG: Lỗi server: ${response.body}');
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

  Future<void> _editCourse(Course course, Map<String, dynamic> courseData) async {
    final url = Uri.parse(Endpoints.updateSubject(course.id));
    final headers = await _getAuthHeaders();
    final body = jsonEncode(courseData);

    try {
      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật môn học thành công')),
        );
        setState(() {
          _coursesFuture = _fetchCourses();
        });
      } else {
        print("DEBUG: Lỗi cập nhật: ${response.body}");
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

  Future<void> _deleteCourse(Course course) async {
    final url = Uri.parse(Endpoints.deleteSubject(course.id));
    final headers = await _getAuthHeaders();

    try {
      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa môn học thành công')),
        );
        setState(() {
          _coursesFuture = _fetchCourses();
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

  void _showAddCourseDialog() {
    showDialog(
      context: context,
      // 2. Hiển thị widget dialog mới
      builder: (context) => _AddCourseDialog(addCourse: _addCourse),
    );
  }

  void _showEditCourseDialog(Course course) {
    final _formKey = GlobalKey<FormState>();

    final _fullNameController = TextEditingController(text: course.fullName);
    final _shortNameController = TextEditingController(text: course.shortName);
    final _roomController = TextEditingController(text: course.schedule.isNotEmpty ? course.schedule.first.room : '');

    int? _dayOfWeek = course.schedule.isNotEmpty ? course.schedule.first.dayOfWeek : null;
    DateTime? _startDate = DateTime.tryParse(course.startDate);
    DateTime? _endDate = DateTime.tryParse(course.endDate);
    
    TimeOfDay? _startTime;
    if (course.schedule.isNotEmpty && course.schedule.first.startTime.isNotEmpty) {
      try {
        final utcTime = DateTime.parse("1970-01-01T${course.schedule.first.startTime}");
        _startTime = TimeOfDay.fromDateTime(utcTime.toLocal());
      } catch (e) {
        print("Lỗi parse startTime: $e");
        _startTime = null;
      }
    }
    
    TimeOfDay? _endTime;
    if (course.schedule.isNotEmpty && course.schedule.first.endTime.isNotEmpty) {
      try {
        final utcTime = DateTime.parse("1970-01-01T${course.schedule.first.endTime}");
        _endTime = TimeOfDay.fromDateTime(utcTime.toLocal());
      } catch (e) {
        print("Lỗi parse endTime: $e");
        _endTime = null;
      }
    }
    
    final List<String> weekDays = [
      'Chủ Nhật', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'
    ];

    Future<void> _pickDate(
        BuildContext context, StateSetter setState, bool isStart) async {
      final now = DateTime.now();
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: (isStart ? _startDate : _endDate) ?? now,
        firstDate: now.subtract(const Duration(days: 365)),
        lastDate: now.add(const Duration(days: 365 * 2)),
      );
      if (pickedDate != null) {
        setState(() { isStart ? _startDate = pickedDate : _endDate = pickedDate; });
      }
    }

    Future<void> _pickTime(
        BuildContext context, StateSetter setState, bool isStart) async {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: (isStart ? _startTime : _endTime) ?? TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() { isStart ? _startTime = pickedTime : _endTime = pickedTime; });
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Chỉnh sửa môn học'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _fullNameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên đầy đủ môn học',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Vui lòng nhập tên' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _shortNameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên viết tắt (ví dụ: DĐ)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Vui lòng nhập tên viết tắt' : null,
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => _pickDate(context, setState, true),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Ngày bắt đầu',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            _startDate == null
                                ? 'Chọn ngày'
                                : DateFormat('dd/MM/yyyy').format(_startDate!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => _pickDate(context, setState, false),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Ngày kết thúc',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            _endDate == null
                                ? 'Chọn ngày'
                                : DateFormat('dd/MM/yyyy').format(_endDate!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Lịch học', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Divider(),
                      DropdownButtonFormField<int>(
                        value: _dayOfWeek,
                        decoration: const InputDecoration(
                          labelText: 'Thứ (ngày trong tuần)',
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(7, (index) {
                          return DropdownMenuItem(
                            value: index,
                            child: Text(weekDays[index]),
                          );
                        }),
                        onChanged: (value) {
                          setState(() { _dayOfWeek = value; });
                        },
                        validator: (value) =>
                            (value == null) ? 'Vui lòng chọn ngày' : null,
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => _pickTime(context, setState, true),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Giờ bắt đầu',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            _startTime == null
                                ? 'Chọn giờ'
                                : _startTime!.format(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => _pickTime(context, setState, false),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Giờ kết thúc',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            _endTime == null
                                ? 'Chọn giờ'
                                : _endTime!.format(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _roomController,
                        decoration: const InputDecoration(
                          labelText: 'Phòng học (ví dụ: A1-501)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Vui lòng nhập phòng học' : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        _startDate != null &&
                        _endDate != null &&
                        _startTime != null &&
                        _endTime != null) {
                      
                      String startDateStr = _startDate!.toIso8601String().split('T').first;
                      String endDateStr = _endDate!.toIso8601String().split('T').first;
                      final now = DateTime.now();
                      String startTimeStr = DateTime.utc(now.year, now.month, now.day, _startTime!.hour, _startTime!.minute)
                          .toIso8601String().split('T').last;
                      String endTimeStr = DateTime.utc(now.year, now.month, now.day, _endTime!.hour, _endTime!.minute)
                          .toIso8601String().split('T').last;

                      final Map<String, dynamic> courseData = {
                        "shortName": _shortNameController.text,
                        "fullName": _fullNameController.text,
                        "schedule": [
                          {
                            "dayOfWeek": _dayOfWeek,
                            "startTime": startTimeStr,
                            "endTime": endTimeStr,
                            "room": _roomController.text
                          }
                        ],
                        "startDate": startDateStr,
                        "endDate": endDateStr
                      };
                      
                      _editCourse(course, courseData);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng điền đầy đủ tất cả các trường')),
                      );
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

  void _showDeleteConfirmDialog(Course course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa môn học "${course.fullName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteCourse(course);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCourseOptions(Course course) {
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
                _showEditCourseDialog(course);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Xóa'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmDialog(course);
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
        title: const Text('Môn học', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                _coursesFuture = _fetchCourses();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Course>>(
        future: _coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.red),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Không thể tải dữ liệu',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      snapshot.error.toString(), 
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          final courses = snapshot.data ?? [];
          if (courses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có môn học nào',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nhấn nút + để thêm môn học mới',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }
          return _buildCourseList(courses);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCourseDialog,
        backgroundColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCourseList(List<Course> courses) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        final String roomDisplay = course.schedule.isNotEmpty 
            ? course.schedule.first.room
            : 'Chưa có phòng';

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AssignmentListScreen(course: course),
              ),
            );
          },
          onLongPress: () => _showCourseOptions(course),
          child: Container(
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.red[100],
                    child: Icon(_courseIcons[index % _courseIcons.length], color: Colors.red),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(course.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                        const SizedBox(height: 8.0),
                        Text(roomDisplay, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    onPressed: () => _showCourseOptions(course),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// 1. TÁCH DIALOG RA WIDGET RIÊNG
class _AddCourseDialog extends StatefulWidget {
  // Nhận hàm addCourse từ bên ngoài
  final Future<void> Function(Map<String, dynamic> courseData) addCourse;

  const _AddCourseDialog({required this.addCourse});

  @override
  State<_AddCourseDialog> createState() => _AddCourseDialogState();
}

class _AddCourseDialogState extends State<_AddCourseDialog> {
  // Toàn bộ state và controller được chuyển vào đây
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _shortNameController = TextEditingController();
  final _roomController = TextEditingController();

  int? _dayOfWeek;
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  final List<String> weekDays = [
    'Chủ Nhật', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'
  ];

  // Hủy các controller khi widget bị xóa
  @override
  void dispose() {
    _fullNameController.dispose();
    _shortNameController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  // Hàm chọn ngày
  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  // Hàm chọn giờ
  Future<void> _pickTime(BuildContext context, bool isStart) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        if (isStart) {
          _startTime = pickedTime;
        } else {
          _endTime = pickedTime;
        }
      });
    }
  }

  // Hàm xử lý khi nhấn nút Thêm
  void _submitForm() {
    if (_formKey.currentState!.validate() &&
        _startDate != null &&
        _endDate != null &&
        _startTime != null &&
        _endTime != null) {
      
      String startDateStr = _startDate!.toIso8601String().split('T').first;
      String endDateStr = _endDate!.toIso8601String().split('T').first;
      final now = DateTime.now();
      String startTimeStr = DateTime.utc(now.year, now.month, now.day, _startTime!.hour, _startTime!.minute)
          .toIso8601String()
          .split('T')
          .last;
      String endTimeStr = DateTime.utc(now.year, now.month, now.day, _endTime!.hour, _endTime!.minute)
          .toIso8601String()
          .split('T')
          .last;

      final Map<String, dynamic> courseData = {
        "shortName": _shortNameController.text,
        "fullName": _fullNameController.text,
        "schedule": [
          {
            "dayOfWeek": _dayOfWeek,
            "startTime": startTimeStr,
            "endTime": endTimeStr,
            "room": _roomController.text
          }
        ],
        "startDate": startDateStr,
        "endDate": endDateStr
      };
      
      // Gọi hàm được truyền vào từ widget cha
      widget.addCourse(courseData);

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ tất cả các trường')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Giao diện của AlertDialog được đặt ở đây
    return AlertDialog(
      title: const Text('Thêm môn học mới'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Tên đầy đủ môn học',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Vui lòng nhập tên' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _shortNameController,
                decoration: const InputDecoration(
                  labelText: 'Tên viết tắt (ví dụ: DĐ)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Vui lòng nhập tên viết tắt' : null,
              ),
              
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _pickDate(context, true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Ngày bắt đầu',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _startDate == null
                        ? 'Chọn ngày'
                        : DateFormat('dd/MM/yyyy').format(_startDate!),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _pickDate(context, false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Ngày kết thúc',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _endDate == null
                        ? 'Chọn ngày'
                        : DateFormat('dd/MM/yyyy').format(_endDate!),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Lịch học', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Divider(),
              DropdownButtonFormField<int>(
                value: _dayOfWeek,
                decoration: const InputDecoration(
                  labelText: 'Thứ (ngày trong tuần)',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(7, (index) {
                  return DropdownMenuItem(
                    value: index,
                    child: Text(weekDays[index]),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    _dayOfWeek = value;
                  });
                },
                validator: (value) =>
                    (value == null) ? 'Vui lòng chọn ngày' : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _pickTime(context, true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Giờ bắt đầu',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _startTime == null
                        ? 'Chọn giờ'
                        : _startTime!.format(context),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _pickTime(context, false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Giờ kết thúc',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _endTime == null
                        ? 'Chọn giờ'
                        : _endTime!.format(context),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roomController,
                decoration: const InputDecoration(
                  labelText: 'Phòng học (ví dụ: A1-501)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Vui lòng nhập phòng học' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _submitForm, // Gọi hàm xử lý submit
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Thêm', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}