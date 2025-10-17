import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../api/endpoints.dart';

class AuthService with ChangeNotifier {
  String? _userEmail;
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;
  String? get currentUserEmail => _userEmail;

  Future<bool> login(String email, String password) async {
  // LOG: In ra thông tin trước khi gửi đi
  print('📡 [AuthService] Đang gửi yêu cầu đăng nhập đến: ${Endpoints.login}');
  print('   => Body: ${jsonEncode({'username': email, 'password': password})}');

  try {
    final url = Uri.parse(Endpoints.login);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'username': email, 'password': password}),
    );

    // LOG: In ra mã trạng thái và nội dung phản hồi từ server
    print('📦 [AuthService] Server Response Status Code: ${response.statusCode}');
    print('📦 [AuthService] Server Response Body: ${response.body}');

    if (response.statusCode == 200) {
      print('✅ [AuthService] Đăng nhập thành công từ API.');
      _isLoggedIn = true;
      _userEmail = email; 
      notifyListeners(); 
      return true;
    } else {
      print('❌ [AuthService] API trả về lỗi (statusCode != 200).');
      return false;
    }
  } catch (e) {
    // LOG: Bắt lỗi nếu không thể kết nối đến server
    print('🔥 [AuthService] ĐÃ CÓ LỖI KẾT NỐI: ${e.toString()}');
    return false;
  }
}

// Thêm hàm này vào trong class AuthService
Future<bool> register(String username, String email, String password) async {
  // LOG: In ra thông tin trước khi gửi đi
  print('📡 [REGISTER] Đang gửi yêu cầu đăng ký đến: ${Endpoints.register}');
  print('   => Body: ${jsonEncode({
        'username': username,
        'email': email,
        'password': password
      })}');

  try {
    // Giả sử bạn có Endpoints.register
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

    // LOG: In ra mã trạng thái và nội dung phản hồi từ server
    print('📦 [REGISTER] Server Response Status Code: ${response.statusCode}');
    print('📦 [REGISTER] Server Response Body: ${response.body}');

    // Kiểm tra mã 200 (OK) hoặc 201 (Created) cho việc đăng ký thành công
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ [REGISTER] Đăng ký thành công từ API.');
      return true;
    } else {
      print('❌ [REGISTER] API trả về lỗi (statusCode không phải 200 hoặc 201).');
      return false;
    }
  } catch (e) {
    // LOG: Bắt lỗi nếu không thể kết nối đến server
    print('🔥 [REGISTER] ĐÃ CÓ LỖI KẾT NỐI: ${e.toString()}');
    return false;
  }
}

  void logout() {
    _isLoggedIn = false;
    _userEmail = null;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isLoggedIn = false;
  }
}
