class SoalModel {
  final int id;
  final String kalimat;
  final String tingkatKesulitan;

  SoalModel({
    required this.id,
    required this.kalimat,
    required this.tingkatKesulitan,
  });

  /// =============================
  /// FROM JSON (API → APP)
  /// =============================
  factory SoalModel.fromJson(Map<String, dynamic> json) {
    return SoalModel(
      id: json['id_soal'] != null
          ? int.parse(json['id_soal'].toString())
          : int.parse(json['id'].toString()),
      kalimat: json['kalimat'] ?? '',
      tingkatKesulitan: json['tingkat_kesulitan'] ?? '',
    );
  }

  /// =============================
  /// TO JSON (APP → API)
  /// =============================
  Map<String, dynamic> toJson() {
    return {
      "id_soal": id,
      "kalimat": kalimat,
      "tingkat_kesulitan": tingkatKesulitan,
    };
  }
}
