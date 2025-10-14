
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Màn hình chính'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Gọi hàm đăng xuất từ AuthService
              authService.logout();
            },
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Chào mừng bạn đã đăng nhập thành công!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
