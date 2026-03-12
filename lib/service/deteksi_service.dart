import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../config/api.dart';

class DeteksiService {
  /// ================================
  /// CEK DISLEKSIA (TEXT + AUDIO)
  /// ================================
  static Future<Map<String, dynamic>> cekDisleksia({
    required String tulisanAnak,
    required PlatformFile audioFile,
    String? teksSoal,  // 🆕 Teks referensi (opsional)
  }) async {
    final url = ApiConfig.predictMultimodal;
    print("Menghubungi ML API: $url");
    
    final request = http.MultipartRequest(
      "POST",
      Uri.parse(url),
    );

    /// DATA UNTUK ML
    request.fields['teks'] = tulisanAnak;
    
    // 🆕 Kirim teks soal jika ada
    if (teksSoal != null && teksSoal.isNotEmpty) {
      request.fields['teks_soal'] = teksSoal;
      print("✅ Mengirim teks_soal: $teksSoal");
      print("   Tulisan anak: $tulisanAnak");
    } else {
      print("⚠️ Teks soal TIDAK dikirim (null atau kosong)");
    }

    if (audioFile.bytes != null) {
      // WEB: Gunakan Bytes
      request.files.add(
        http.MultipartFile.fromBytes(
          'audio',
          audioFile.bytes!,
          filename: audioFile.name,
          contentType: MediaType('audio', 'wav'),
        ),
      );
    } else if (audioFile.path != null) {
      // MOBILE: Gunakan Path
      request.files.add(
        await http.MultipartFile.fromPath(
          'audio',
          audioFile.path!,
          contentType: MediaType('audio', 'wav'),
        ),
      );
    } else {
      return {
        "status": false,
        "message": "File audio rusak atau tidak terbaca",
      };
    }

    try {
      print("Mengirim request ke ML API...");
      
      // ⏱️ Tambahkan timeout 120 detik (lebih lama untuk audio processing)
      final response = await request.send().timeout(
        const Duration(seconds: 120),
        onTimeout: () {
          throw Exception("Timeout: Server ML tidak merespons dalam 120 detik. Coba lagi dengan audio yang lebih pendek.");
        },
      );
      
      print("Membaca response...");
      final body = await response.stream.bytesToString();

      print("ML API Response Status: ${response.statusCode}");
      print("ML API Response Body: $body");

      if (response.statusCode == 200) {
        final data = jsonDecode(body);
        
        // Handle jika ada error dari API
        if (data.containsKey("error")) {
          return {
            "status": false,
            "message": "Error dari ML: ${data['error']}\n${data['detail'] ?? ''}",
          };
        }

        return {
          "status": true,
          "prediction": data["prediction"],
          "confidence": data["confidence_disleksia"] ?? "Unknown",
        };
      }

      return {
        "status": false,
        "message": "Gagal memproses deteksi (Status: ${response.statusCode})\nResponse: ${body.length > 200 ? body.substring(0, 200) + '...' : body}"
      };
    } catch (e) {
      print("Error koneksi ML: $e");
      return {
        "status": false,
        "message": "Error: ${e.toString()}"
      };
    }
  }

  /// ================================
  /// SIMPAN HASIL KE DATABASE
  /// ================================
  static Future<Map<String, dynamic>> simpanHasil({
    required int userId,
    required String namaAnak,
    required int soalId,
    required String jawabanAnak,
    required String hasil,
    required String confidence,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.simpanHasilDeteksi),
        body: jsonEncode({
          "user_id": userId,
          "nama_anak": namaAnak,
          "soal_id": soalId,
          "jawaban": jawabanAnak,
          "hasil": hasil,
          "confidence": confidence,
        }),
        headers: {"Content-Type": "application/json"},
      );

      print("Response simpanHasil: ${response.statusCode} - ${response.body}");
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["status"] == true) {
        return {"status": true, "message": "Berhasil disimpan"};
      } else {
        return {
          "status": false,
          "message": "Gagal: ${data['message'] ?? response.body}",
        };
      }
    } catch (e) {
      print("Error simpanHasil: $e");
      return {"status": false, "message": "Error Koneksi: $e"};
    }
  }
}
