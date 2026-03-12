import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api.dart';
import '../models/hasil_model.dart';

class HasilService {
  /// =============================
  /// SIMPAN HASIL DETEKSI
  /// =============================
  static Future<void> saveHasil({
    required int anakId,
    required String jawabanTeks,
    required String hasilPrediksi,
    required double confidence,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConfig.simpanHasilDeteksi),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id_anak": anakId,
        "jawaban_teks": jawabanTeks,
        "hasil_prediksi": hasilPrediksi,
        "confidence": confidence,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data["status"] != true) {
      throw Exception(data["message"] ?? "Gagal menyimpan hasil deteksi");
    }
  }

  /// =============================
  /// GET RIWAYAT DETEKSI PER ANAK
  /// =============================
  static Future<List<HasilDeteksiModel>> getHistoryByAnak(int anakId) async {
    final response = await http.post(
      Uri.parse(ApiConfig.getHistory),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"id_anak": anakId}),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => HasilDeteksiModel.fromJson(e)).toList();
    } else {
      throw Exception("Gagal mengambil riwayat deteksi");
    }
  }
}
