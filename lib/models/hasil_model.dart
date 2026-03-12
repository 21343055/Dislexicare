class HasilDeteksiModel {
  final int idHasil;
  final int idAnak;
  final String jawabanTeks;
  final String? pathAudio;
  final String hasilPrediksi;
  final double confidence;
  final String tanggal;

  HasilDeteksiModel({
    required this.idHasil,
    required this.idAnak,
    required this.jawabanTeks,
    this.pathAudio,
    required this.hasilPrediksi,
    required this.confidence,
    required this.tanggal,
  });

  /// =============================
  /// FROM JSON (API → APP)
  /// =============================
  factory HasilDeteksiModel.fromJson(Map<String, dynamic> json) {
    return HasilDeteksiModel(
      idHasil: int.parse(json['id_hasil'].toString()),
      idAnak: int.parse(json['id_anak'].toString()),
      jawabanTeks: json['jawaban_teks'] ?? '',
      pathAudio: json['path_audio'],
      hasilPrediksi: json['hasil_prediksi'] ?? '',
      confidence: double.parse(json['confidence'].toString()),
      tanggal: json['tanggal'] ?? '',
    );
  }

  /// =============================
  /// TO JSON (APP → API)
  /// =============================
  Map<String, dynamic> toJson() {
    return {
      "id_anak": idAnak,
      "jawaban_teks": jawabanTeks,
      "path_audio": pathAudio,
      "hasil_prediksi": hasilPrediksi,
      "confidence": confidence,
    };
  }
}
