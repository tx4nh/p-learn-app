import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; 
import '../api/endpoints.dart';

class AuthService with ChangeNotifier {
  String? _username;
  String? _email;
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;
  String? get currentUsername => _username; 
  String? get currentEmail => _email;

  Future<bool> login(String username, String password) async {
    print('📡 [AuthService] Đang gửi yêu cầu đăng nhập đến: ${Endpoints.login}');
    print('   => Body: ${jsonEncode({'username': username, 'password': password})}');

    try {
      final url = Uri.parse(Endpoints.login);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      print('📦 [AuthService] Server Response Status Code: ${response.statusCode}');
      print('📦 [AuthService] Server Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ [AuthService] Đăng nhập thành công từ API.');

        try {
          final responseData = jsonDecode(response.body);

          if (responseData.containsKey('token') && 
              responseData['token'] is Map &&
              responseData['token'].containsKey('access_token') &&
              responseData.containsKey('user') &&
              responseData['user'] is Map &&
              responseData['user'].containsKey('username') &&
              responseData['user'].containsKey('email')) { 

            final String accessToken = responseData['token']['access_token'];
            final String serverUsername = responseData['user']['username'];
            final String serverEmail = responseData['user']['email'];

            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('access_token', accessToken);
            await prefs.setString('username', serverUsername);
            await prefs.setString('email', serverEmail);
            
            print('💾 [AuthService] Đã LƯU token, username, và email vào SharedPreferences!');
            
            _isLoggedIn = true;
            _username = serverUsername;
            _email = serverEmail;
            notifyListeners();
            return true;
          } else {
            print('❌ [AuthService] Lỗi: Cấu trúc JSON trả về không đúng định dạng.');
            print('   => Expected: {"token": ..., "user": {"username": "...", "email": "..."}}');
            print('   => Received: ${response.body}');
            return false;
          }
        } catch (e) {
          print('🔥 [AuthService] Lỗi khi xử lý JSON: ${e.toString()}');
          print('   => Body nhận được: ${response.body}');
          return false;
        }
      } else {
        print('❌ [AuthService] API trả về lỗi (statusCode != 200).');
        return false;
      }
    } catch (e) {
      print('🔥 [AuthService] ĐÃ CÓ LỖI KẾT NỐI: ${e.toString()}');
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    print('📡 [REGISTER] Đang gửi yêu cầu đăng ký đến: ${Endpoints.register}');
    print('   => Body: ${jsonEncode({
          'username': username,
          'email': email,
          'password': password
        })}');

    try {
      final url = Uri.parse(Endpoints.register); 
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      print('📦 [REGISTER] Server Response Status Code: ${response.statusCode}');
      print('📦 [REGISTER] Server Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [REGISTER] Đăng ký thành công từ API.');
        return true;
      } else {
        print('❌ [REGISTER] API trả về lỗi (statusCode không phải 200 hoặc 201).');
        return false;
      }
    } catch (e) {
      print('🔥 [REGISTER] ĐÃ CÓ LỖI KẾT NỐI: ${e.toString()}');
      return false;
    }
  }

  Future<String> resetPassword(String email, String newPassword) async {
        print('📡 [AuthService] [RESET_PW] Đang gửi yêu cầu đến: ${Endpoints.resetPassword}');
    
    final url = Uri.parse(Endpoints.resetPassword);
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        // Dựa theo ảnh bạn cung cấp, body cần 'email' và 'new_password'
        body: jsonEncode({
          'email': email,
          'new_password': newPassword,
        }),
      );

      // Giải mã body để xử lý tiếng Việt (nếu có) và log
      // Ngay cả khi response 200 là string, 422 có thể là JSON
      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
      print('📦 [AuthService] [RESET_PW] Response Status: ${response.statusCode}');
      print('📦 [AuthService] [RESET_PW] Response Body: $responseBody');

      if (response.statusCode == 200) {
        print('✅ [AuthService] [RESET_PW] Đặt lại mật khẩu thành công.');
        return responseBody.toString(); 
      } else if (response.statusCode == 422) {
        print('❌ [AuthService] [RESET_PW] Lỗi Validation (422).');
        String errorMessage = 'Dữ liệu không hợp lệ';
        if (responseBody is Map && responseBody.containsKey('detail')) {
          errorMessage = responseBody['detail'];
        }
        throw Exception(errorMessage);
      } else {
        // Các lỗi máy chủ khác
        print('❌ [AuthService] [RESET_PW] Lỗi server: ${response.statusCode}.');
        throw Exception('Lỗi máy chủ: ${response.statusCode}');
      }
    } catch (e) {
      print('🔥 [AuthService] [RESET_PW] Lỗi khi gọi resetPassword: ${e.toString()}');
      throw Exception('Không thể kết nối. ${e.toString()}');
    }
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token'); 
    await prefs.remove('username');
    await prefs.remove('email');

    _isLoggedIn = false;
    _username = null;
    _email = null;
    print('🚪 [AuthService] Đã logout và xóa token, username, email.');
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token != null) {
      _isLoggedIn = true;
      _username = prefs.getString('username');
      _email = prefs.getString('email');
      print('🔄 [AuthService] Tự động đăng nhập với token: $token');
      print('   => User: $_username, Email: $_email');
    } else {
      _isLoggedIn = false;
      print('🔄 [AuthService] Không tìm thấy token, yêu cầu đăng nhập.');
    }
    notifyListeners();
  }
}