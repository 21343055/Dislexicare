import 'package:flutter/material.dart';

import 'riwayat.dart';

class HasilDeteksiPage extends StatelessWidget {
  final int soalId;
  final String jawabanAnak;
  final String nama;
  final String diagnosis;
  final String confidence;
  final DateTime tanggal;

  const HasilDeteksiPage({
    super.key,
    required this.soalId,
    required this.jawabanAnak,
    required this.nama,
    required this.diagnosis,
    required this.confidence,
    required this.tanggal,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisleksia = diagnosis.toLowerCase().contains("disleksia");

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          /// =========================
          /// HEADER
          /// =========================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 50,
              left: 16,
              right: 16,
              bottom: 24,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF0D1B57),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(60),
                bottomRight: Radius.circular(60),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      "Hasil Deteksi",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          const SizedBox(height: 30),

          /// =========================
          /// CARD HASIL
          /// =========================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRow("Nama Anak", nama),
                    const Divider(),

                    _buildRow(
                      "Hasil Deteksi",
                      diagnosis,
                      valueColor: isDisleksia ? Colors.red : Colors.green,
                    ),
                    const Divider(),

                    _buildRow(
                      "Kategori Risiko",
                      confidence,
                      valueColor: confidence.toLowerCase() == "aman"
                          ? Colors.green 
                          : Colors.red,
                    ),
                    const Divider(),

                    _buildRow(
                      "Tanggal",
                      "${tanggal.day.toString().padLeft(2, '0')}/"
                          "${tanggal.month.toString().padLeft(2, '0')}/"
                          "${tanggal.year}",
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          /// =========================
          /// BUTTON ACTION
          /// =========================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RiwayatPage()),
                      );
                    },
                    icon: const Icon(Icons.history),
                    label: const Text(
                      "Lihat Riwayat",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.indigo, width: 2),
                      foregroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// HELPER WIDGET
  /// =========================
  Widget _buildRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// HELPER FUNCTIONS
  /// =========================
}
