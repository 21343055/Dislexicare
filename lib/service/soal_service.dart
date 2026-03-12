import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api.dart';
import '../models/soal_model.dart';

class SoalService {
  /// =============================
  /// GET LIST SOAL
  /// =============================
  static Future<List<SoalModel>> getSoalList() async {
    final response = await http
        .get(Uri.parse(ApiConfig.getSoal))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception("Server error (${response.statusCode})");
    }

    final json = jsonDecode(response.body);

    if (json["status"] != true) {
      throw Exception(json["message"] ?? "Gagal mengambil data soal");
    }

    final List data = json["data"];
    return data.map((e) => SoalModel.fromJson(e)).toList();
  }

  /// =============================
  /// ADD SOAL (ADMIN)
  /// =============================
  static Future<void> addSoal({
    required int userId,
    required String teksSoal,
    required String tingkatKesulitan,
  }) async {
    final response = await http
        .post(
          Uri.parse(ApiConfig.addSoal),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "user_id": userId,
            "teks_soal": teksSoal,
            "tingkat_kesulitan": tingkatKesulitan,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception("Server error (${response.statusCode})");
    }

    final json = jsonDecode(response.body);

    if (json["status"] != true) {
      throw Exception(json["message"] ?? "Gagal menambahkan soal");
    }
  }

  /// =============================
  /// UPDATE SOAL (ADMIN)
  /// =============================
  static Future<void> updateSoal({
    required int userId,
    required int id,
    required String teksSoal,
    required String tingkatKesulitan,
  }) async {
    final response = await http
        .post(
          Uri.parse(ApiConfig.updateSoal),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "user_id": userId,
            "id": id,
            "teks_soal": teksSoal,
            "tingkat_kesulitan": tingkatKesulitan,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception("Server error (${response.statusCode})");
    }

    final json = jsonDecode(response.body);

    if (json["status"] != true) {
      throw Exception(json["message"] ?? "Gagal mengupdate soal");
    }
  }

  /// =============================
  /// DELETE SOAL (ADMIN)
  /// =============================
  static Future<void> deleteSoal({required int userId, required int id}) async {
    final response = await http
        .post(
          Uri.parse(ApiConfig.deleteSoal),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"user_id": userId, "id": id}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception("Server error (${response.statusCode})");
    }

    final json = jsonDecode(response.body);

    if (json["status"] != true) {
      throw Exception(json["message"] ?? "Gagal menghapus soal");
    }
  }
}
