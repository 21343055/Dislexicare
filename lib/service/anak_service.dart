import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api.dart';
import '../models/anak_model.dart';

class AnakService {
  /// =============================
  /// GET LIST ANAK (by user)
  /// =============================
  static Future<List<AnakModel>> getAnakByUser(int userId) async {
    final response = await http.post(
      Uri.parse(ApiConfig.getAnak),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user_id": userId}),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => AnakModel.fromJson(e)).toList();
    } else {
      throw Exception("Gagal mengambil data anak");
    }
  }

  /// =============================
  /// ADD ANAK
  /// =============================
  static Future<void> addAnak({
    required int userId,
    required String nama,
    required int usia,
    required String jenisKelamin,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConfig.addAnak),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "nama": nama,
        "usia": usia,
        "jenis_kelamin": jenisKelamin,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data["status"] != true) {
      throw Exception(data["message"] ?? "Gagal menambahkan anak");
    }
  }
}
