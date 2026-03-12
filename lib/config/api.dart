import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  /// =============================
  /// BASE URL
  /// =============================

  // Android Emulator : http://10.0.2.2
  // Web / Windows    : http://localhost
  static const String baseUrl = "http://localhost/Dislexicare";

  /// Helper untuk mendapatkan host ML API berdasarkan platform
  static String get mlHost {
    if (kIsWeb) {
      return "http://localhost:8000";
    } else if (Platform.isAndroid) {
      return "http://10.0.2.2:8000";
    } else {
      return "http://127.0.0.1:8000";
    }
  }

  /// =============================
  /// AUTH
  /// =============================
  static const String login = "$baseUrl/api_php/login.php";
  static const String signup = "$baseUrl/api_php/signup.php";

  /// =============================
  /// PROFILE
  /// =============================
  static const String getProfile = "$baseUrl/api_php/get_profile.php";
  static const String updateProfile = "$baseUrl/api_php/update_profile.php";

  /// =============================
  /// Password
  /// =============================
  static const String changePassword = "$baseUrl/api_php/change_password.php";

  /// =============================
  /// DATA ANAK
  /// =============================
  static const String getAnak = "$baseUrl/api_php/get_anak.php";
  static const String addAnak = "$baseUrl/api_php/add_anak.php";

  /// =============================
  /// SOAL
  /// =============================
  static const String getSoal = "$baseUrl/api_php/get_soal.php";
  static const String addSoal = "$baseUrl/api_php/add_soal.php";
  static const String updateSoal = "$baseUrl/api_php/update_soal.php";
  static const String deleteSoal = "$baseUrl/api_php/delete_soal.php";

  /// =============================
  /// DETEKSI & RIWAYAT
  /// =============================
  static const String simpanHasilDeteksi = "$baseUrl/api_php/save_result.php";

  static const String getHistory = "$baseUrl/api_php/get_history.php";

  /// =============================
  /// ML API (FastAPI) - Dynamic based on platform
  /// =============================
  static String get predictText => "$mlHost/predict/text";

  static String get predictAudio => "$mlHost/predict/audio";
  
  static String get predictMultimodal => "$mlHost/predict/multimodal";
}
