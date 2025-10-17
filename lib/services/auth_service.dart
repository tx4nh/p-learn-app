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
    try {
      // For now, we'll just simulate a successful login without a real API call
      // In a real app, you would make the http call here.
      /*
      final url = Uri.parse(Endpoints.login);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'username': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        _isLoggedIn = true;
        _userEmail = email; // Store email on successful login
        notifyListeners(); // Notify listeners of the change
        return true;
      } else {
        return false;
      }
      */

      // Simulating a successful login for now
      await Future.delayed(const Duration(seconds: 1));
      _isLoggedIn = true;
      _userEmail = email;
      notifyListeners();
      return true;

    } catch (e) {
      return false;
    }
  }

  void logout() {
    _isLoggedIn = false;
    _userEmail = null;
    notifyListeners();
  }
}
