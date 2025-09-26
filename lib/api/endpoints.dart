import 'package:flutter_dotenv/flutter_dotenv.dart';

class Endpoints {
  static String get baseUrl => dotenv.env['API_BASE_URL']!;

  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get courses => '$baseUrl/courses';
  static String get students => '$baseUrl/students';
}