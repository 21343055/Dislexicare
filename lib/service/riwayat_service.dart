import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api.dart';
import '../models/riwayat_model.dart';

class RiwayatService {
  static Future<List<RiwayatModel>> getRiwayat(int userId) async {
    final url = Uri.parse("${ApiConfig.getHistory}?user_id=$userId");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      if (jsonData['status'] == true) {
        return (jsonData['data'] as List)
            .map((e) => RiwayatModel.fromJson(e))
            .toList();
      } else {
        return [];
      }
    } else {
      throw Exception("Gagal mengambil riwayat");
    }
  }
}
