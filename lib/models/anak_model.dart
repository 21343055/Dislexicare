class AnakModel {
  final int idAnak;
  final int idUser;
  final String nama;
  final int usia;
  final String jenisKelamin;

  AnakModel({
    required this.idAnak,
    required this.idUser,
    required this.nama,
    required this.usia,
    required this.jenisKelamin,
  });

  /// =============================
  /// FROM JSON (API → APP)
  /// =============================
  factory AnakModel.fromJson(Map<String, dynamic> json) {
    return AnakModel(
      idAnak: int.parse(json['id_anak'].toString()),
      idUser: int.parse(json['id_user'].toString()),
      nama: json['nama'] ?? '',
      usia: int.parse(json['usia'].toString()),
      jenisKelamin: json['jenis_kelamin'] ?? '',
    );
  }

  /// =============================
  /// TO JSON (APP → API)
  /// =============================
  Map<String, dynamic> toJson() {
    return {
      "id_user": idUser,
      "nama": nama,
      "usia": usia,
      "jenis_kelamin": jenisKelamin,
    };
  }
}
