import 'package:flutter/material.dart';
import 'package:p_learn_app/screens/tools/gpa_calculator_screen.dart';
import 'package:p_learn_app/screens/tools/pomodoro_screen.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Công cụ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildToolCard(
              context,
              icon: Icons.calculate_outlined,
              title: 'Tính điểm GPA',
              subtitle: 'Ước tính điểm trung bình học kỳ của bạn.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GpaCalculatorScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildToolCard(
              context,
              icon: Icons.hourglass_bottom_outlined,
              title: 'Đồng hồ Pomodoro',
              subtitle: 'Quản lý thời gian học tập hiệu quả.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PomodoroScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 40.0, color: Colors.red),
              const SizedBox(height: 16.0),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                subtitle,
                style: TextStyle(fontSize: 15.0, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
