import 'package:flutter/material.dart';
import 'package:p_learn_app/screens/auth/login_screen.dart';
import 'package:p_learn_app/screens/main_navigation/main_tab_screen.dart';
import 'package:p_learn_app/services/auth_service.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        if (!authService.isLoggedIn) {
          return const MainTabScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}