import 'package:flutter/material.dart';

// Data model for a course
class Course {
  String name;
  double grade;
  int credits;

  Course({required this.name, required this.grade, required this.credits});
}

class GpaCalculatorScreen extends StatefulWidget {
  const GpaCalculatorScreen({super.key});

  @override
  _GpaCalculatorScreenState createState() => _GpaCalculatorScreenState();
}

class _GpaCalculatorScreenState extends State<GpaCalculatorScreen> {
  final List<Course> _courses = [];
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _gradeController = TextEditingController();
  final _creditsController = TextEditingController();

  double _gpa = 0.0;

  // TODO: Implement API call to fetch courses for the current semester
  // This function would be called in initState() or on a button press.
  Future<void> _fetchCoursesFromApi() async {
    // Example:
    // final response = await http.get(Uri.parse('YOUR_API_ENDPOINT/courses'));
    // if (response.statusCode == 200) {
    //   final List<dynamic> courseData = json.decode(response.body);
    //   setState(() {
    //     _courses = courseData.map((data) => Course(
    //       name: data['name'],
    //       grade: data['grade'], // Assuming grade is pre-filled or 0
    //       credits: data['credits'],
    //     )).toList();
    //   });
    // } else {
    //   // Handle error
    // }
    // For now, we'll use dummy data.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('TODO: Fetch courses from API')),
    );
  }

  void _addCourse() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _courses.add(
          Course(
            name: _nameController.text,
            grade: double.parse(_gradeController.text),
            credits: int.parse(_creditsController.text),
          ),
        );
        _nameController.clear();
        _gradeController.clear();
        _creditsController.clear();
        _calculateGpa();
      });
      Navigator.of(context).pop(); // Close the dialog
    }
  }

  void _calculateGpa() {
    if (_courses.isEmpty) {
      setState(() {
        _gpa = 0.0;
      });
      return;
    }

    double totalPoints = 0;
    int totalCredits = 0;

    for (var course in _courses) {
      totalPoints += course.grade * course.credits;
      totalCredits += course.credits;
    }

    setState(() {
      _gpa = totalCredits == 0 ? 0.0 : totalPoints / totalCredits;
    });
  }

  void _showAddCourseDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Thêm môn học'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Tên môn học'),
                  validator: (value) =>
                      value!.isEmpty ? 'Vui lòng nhập tên môn học' : null,
                ),
                TextFormField(
                  controller: _gradeController,
                  decoration: const InputDecoration(
                    labelText: 'Điểm (ví dụ: 3.5)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return 'Vui lòng nhập điểm';
                    if (double.tryParse(value) == null) return 'Số không hợp lệ';
                    return null;
                  },
                ),
                TextFormField(
                  controller: _creditsController,
                  decoration: const InputDecoration(
                    labelText: 'Số tín chỉ (ví dụ: 3)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return 'Vui lòng nhập số tín chỉ';
                    if (int.tryParse(value) == null) return 'Số không hợp lệ';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(onPressed: _addCourse, child: const Text('Thêm')),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tính điểm GPA',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      backgroundColor: Colors.white, // Changed Scaffold background to white
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.red.shade700, // Changed GPA summary background to red
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'GPA của bạn',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white, // Changed text color to white
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _gpa.toStringAsFixed(2),
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Changed text color to white
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(color: Colors.red),
          Expanded(
            child: _courses.isEmpty
                ? const Center(child: Text('Chưa có môn học nào được thêm.'))
                : ListView.builder(
                    itemCount: _courses.length,
                    itemBuilder: (context, index) {
                      final course = _courses[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border(left: BorderSide(color: Colors.red.shade700, width: 5)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(
                            course.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            'Điểm: ${course.grade}, Tín chỉ: ${course.credits}',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 15,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _courses.removeAt(index);
                                _calculateGpa();
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCourseDialog,
        backgroundColor: Colors.red, // Set FAB background to red
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
