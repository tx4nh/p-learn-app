import 'dart:async';

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../api/endpoints.dart';

class AuthService {
  // 1. Tạo một StreamController để quản lý trạng thái đăng nhập.

  // .broadcast() cho phép có nhiều listener cùng lúc.

  final _authStateController = StreamController<bool>.broadcast();

  // 2. Cung cấp một Stream công khai để UI có thể lắng nghe.

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
        // 3. Khi đăng nhập thành công, phát ra trạng thái 'true' (đã đăng nhập).

        _authStateController.add(true);

        return true;
      } else {
        // Khi đăng nhập thất bại, phát ra trạng thái 'false'.

        _authStateController.add(false);

        return false;
      }
    } catch (e) {
      // Bei network error, also push false state

      _authStateController.add(false);

      throw Exception(
        'Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại kết nối mạng.',
      );
    }
  }

  // 4. Hàm đăng xuất

  void logout() {
    // Khi đăng xuất, phát ra trạng thái 'false'.

    _authStateController.add(false);
  }

  // 5. Hàm để giải phóng tài nguyên khi không cần thiết

  void dispose() {
    _authStateController.close();
  }
}
