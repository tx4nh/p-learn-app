import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:p_learn_app/utils/date_time_utils.dart';

class AddCourseDialog extends StatefulWidget {
  final Future<void> Function(Map<String, dynamic> courseData) addCourse;

  const AddCourseDialog({super.key, required this.addCourse});

  @override
  State<AddCourseDialog> createState() => _AddCourseDialogState();
}

class _AddCourseDialogState extends State<AddCourseDialog> {
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

  @override
  void dispose() {
    _fullNameController.dispose();
    _shortNameController.dispose();
    _roomController.dispose();
    super.dispose();
  }

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

  void _submitForm() {
    if (_formKey.currentState!.validate() &&
        _startDate != null &&
        _endDate != null &&
        _startTime != null &&
        _endTime != null) {
      
      String startDateStr = DateTimeUtils.dateToString(_startDate!);
      String endDateStr = DateTimeUtils.dateToString(_endDate!);
      String startTimeStr = DateTimeUtils.timeOfDayToString(_startTime!);
      String endTimeStr = DateTimeUtils.timeOfDayToString(_endTime!);

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
      
      widget.addCourse(courseData);

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ tất cả các trường')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          onPressed: _submitForm,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Thêm', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}