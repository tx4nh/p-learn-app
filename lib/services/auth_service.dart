import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api/endpoints.dart';

class AuthService {
  final _authStateController = StreamController<bool>.broadcast();
  bool isLoggedIn = false;
  Stream<bool> get onAuthStateChanged => _authStateController.stream;
  Future<bool> login(String email, String password) async {
    try {
      String loginUrl;

      try {
        loginUrl = Endpoints.login;
        if (loginUrl.isEmpty || loginUrl.startsWith('null')) {
          throw Exception('URL không hợp lệ từ Endpoints');
        }
      } catch (e) {
        throw Exception('Không thể tạo URL đăng nhập.');
      }

      final url = Uri.parse(loginUrl);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'username': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        _authStateController.add(true);
        isLoggedIn = true;
        return true;
      } else {
        _authStateController.add(false);
        return false;
      }
    } catch (e) {
      _authStateController.add(false);
      return false;
    }
  }

  void logout() {
    _authStateController.add(false);
  }

  void dispose() {
    _authStateController.close();
  }

  Future<void> checkAuthStatus() async {
    await Future.delayed(const Duration(milliseconds: 500));
    isLoggedIn = false;
  }
}
