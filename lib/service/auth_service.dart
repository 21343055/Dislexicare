import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api.dart';
import '../models/user_model.dart';

class AuthService {
  /// =============================
  /// LOGIN
  /// =============================
  static Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConfig.login),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data["status"] == true) {
      return UserModel.fromJson(data["user"]);
    } else {
      throw Exception(data["message"] ?? "Login gagal");
    }
  }

  /// =============================
  /// SIGNUP
  /// =============================
  static Future<void> signup({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConfig.signup),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
        "role": role,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data["status"] != true) {
      throw Exception(data["message"] ?? "Registrasi gagal");
    }
  }
}
