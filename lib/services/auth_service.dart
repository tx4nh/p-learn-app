

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api/endpoints.dart';

class AuthService {
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
      
        return true;
      } else {
        return false;
      }
    } catch (e) {

      throw Exception(
        'Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại kết nối mạng.',
      );
    }
  }
}