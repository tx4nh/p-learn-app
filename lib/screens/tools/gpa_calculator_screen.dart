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
          title: const Text('Add Course'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Course Name'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a name' : null,
                ),
                TextFormField(
                  controller: _gradeController,
                  decoration: const InputDecoration(
                    labelText: 'Grade (e.g., 3.5)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return 'Please enter a grade';
                    if (double.tryParse(value) == null) return 'Invalid number';
                    return null;
                  },
                ),
                TextFormField(
                  controller: _creditsController,
                  decoration: const InputDecoration(
                    labelText: 'Credits (e.g., 3)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return 'Please enter credits';
                    if (int.tryParse(value) == null) return 'Invalid number';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(onPressed: _addCourse, child: const Text('Add')),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPA Calculator'),
        actions: [
          // This button is a placeholder for the API call
          IconButton(
            icon: const Icon(Icons.api),
            onPressed: _fetchCoursesFromApi,
            tooltip: 'Fetch Courses from API (TODO)',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Your GPA',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  _gpa.toStringAsFixed(2),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _courses.isEmpty
                ? const Center(child: Text('No courses added yet.'))
                : ListView.builder(
                    itemCount: _courses.length,
                    itemBuilder: (context, index) {
                      final course = _courses[index];
                      return ListTile(
                        title: Text(course.name),
                        subtitle: Text(
                          'Grade: ${course.grade}, Credits: ${course.credits}',
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
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCourseDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
