import 'dart:io';

class DeteksiModel {
  final int idAnak;
  final int idSoal;
  final String kalimatSoal;
  final String? jawabanTeks;
  final File? audioFile;

  DeteksiModel({
    required this.idAnak,
    required this.idSoal,
    required this.kalimatSoal,
    this.jawabanTeks,
    this.audioFile,
  });

  /// =============================
  /// VALIDASI
  /// =============================
  bool get isValid {
    return (jawabanTeks != null && jawabanTeks!.isNotEmpty) ||
        audioFile != null;
  }
}
