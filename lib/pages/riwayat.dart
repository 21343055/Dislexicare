import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/riwayat_model.dart';
import '../service/riwayat_service.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  List<RiwayatModel> riwayat = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRiwayat();
  }

  /// =========================
  /// 🔹 AMBIL RIWAYAT DARI API
  /// =========================
  Future<void> fetchRiwayat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("userId");

      if (userId == null) {
        setState(() => isLoading = false);
        return;
      }

      final data = await RiwayatService.getRiwayat(userId);

      setState(() {
        riwayat = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Gagal mengambil riwayat: $e");
      setState(() => isLoading = false);
    }
  }

  /// =========================
  /// 🔹 UI
  /// =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      "Riwayat Deteksi",
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

          const SizedBox(height: 20),

          /// =========================
          /// LIST RIWAYAT
          /// =========================
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : riwayat.isEmpty
                ? const Center(
                    child: Text(
                      "Belum ada riwayat deteksi",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: riwayat.length,
                    itemBuilder: (context, index) {
                      final item = riwayat[index];
                      final bool isDisleksia =
                          item.status.toLowerCase() == "disleksia";

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// STATUS + ICON
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.status,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(
                                    isDisleksia
                                        ? Icons.cancel
                                        : Icons.check_circle,
                                    color: isDisleksia
                                        ? Colors.red
                                        : Colors.green,
                                    size: 28,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              /// NAMA ANAK
                              Text(
                                item.nama,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 8),

                              /// TANGGAL
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_month,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _formatTanggal(item.tanggal),
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                              /// CONFIDENCE
                              Text(
                                "Confidence: ${_formatConfidence(item.confidence)}%",
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// 🔹 FORMAT TANGGAL
  /// =========================
  String _formatTanggal(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  /// =========================
  /// 🔹 FORMAT CONFIDENCE (Handle data lama 0-1 dan baru 0-100)
  /// =========================
  String _formatConfidence(double confidence) {
    // Jika confidence > 1, anggap sudah dalam persen (0-100)
    // Jika confidence <= 1, anggap dalam desimal (0-1) dan perlu multiply 100
    if (confidence > 1.0) {
      return confidence.toStringAsFixed(1);
    } else {
      return (confidence * 100).toStringAsFixed(1);
    }
  }
}
