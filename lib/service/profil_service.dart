import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';

class ProfileService {
  static Future<Map<String, dynamic>> getProfile(int userId) async {
    final uri = Uri.parse("${ApiConfig.getProfile}?user_id=$userId");
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Gagal mengambil data profil");
    }
  }

  /// =============================
  /// UPDATE PROFILE
  /// =============================
  static Future<bool> updateProfile({
    required int userId,
    required String noHp,
    required String tanggalLahir,
    required String jenisKelamin,
    required String kota,
  }) async {
    final uri = Uri.parse(ApiConfig.updateProfile);

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "no_hp": noHp,
        "tanggal_lahir": tanggalLahir,
        "jenis_kelamin": jenisKelamin,
        "kota": kota,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["status"] == true;
    } else {
      return false;
    }
  }
}
