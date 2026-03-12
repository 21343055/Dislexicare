class RiwayatModel {
  final int id;
  final String nama;
  final String status;
  final double confidence;
  final DateTime tanggal;

  RiwayatModel({
    required this.id,
    required this.nama,
    required this.status,
    required this.confidence,
    required this.tanggal,
  });

  factory RiwayatModel.fromJson(Map<String, dynamic> json) {
    return RiwayatModel(
      id: int.parse(json['id'].toString()),
      nama: json['nama'],
      status: json['status'],
      confidence: double.parse(json['confidence'].toString()),
      tanggal: DateTime.parse(json['tanggal']),
    );
  }
}
