
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return StreamBuilder<bool>(
      stream: authService.onAuthStateChanged,
      builder: (context, snapshot) {
        // Đang chờ kết nối hoặc chưa có dữ liệu
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Nếu có dữ liệu và trạng thái là đã đăng nhập (true)
        if (snapshot.hasData && snapshot.data == true) {
          return const HomeScreen();
        }

        // Mặc định, hoặc khi trạng thái là đăng xuất (false)
        return const LoginScreen();
      },
    );
  }
}

