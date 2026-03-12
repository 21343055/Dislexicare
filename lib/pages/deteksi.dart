import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/soal_model.dart';
import '../service/soal_service.dart';
import '../service/deteksi_service.dart';
import 'hasil_deteksi.dart';

class DeteksiPage extends StatefulWidget {
  const DeteksiPage({super.key});

  @override
  State<DeteksiPage> createState() => _DeteksiPageState();
}

class _DeteksiPageState extends State<DeteksiPage> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController tulisanController = TextEditingController();
  final TextEditingController audioController = TextEditingController();

  PlatformFile? audioFile;
  SoalModel? soal;
  bool isLoadingSoal = true;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    fetchSoal();
  }

  @override
  void dispose() {
    namaController.dispose();
    tulisanController.dispose();
    audioController.dispose();
    super.dispose();
  }

  /// =========================
  /// AMBIL SOAL DARI DATABASE
  /// =========================
  Future<void> fetchSoal() async {
    try {
      final soalList = await SoalService.getSoalList();
      if (soalList.isNotEmpty) {
        // Acak urutan soal
        soalList.shuffle();
        
        setState(() {
          soal = soalList.first;
          isLoadingSoal = false;
        });
      }
    } catch (e) {
      setState(() => isLoadingSoal = false);
    }
  }

  /// =========================
  /// PICK AUDIO
  /// =========================
  Future<void> pickAudio() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['wav', 'mp3', 'm4a', 'aac'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          audioFile = file;
          audioController.text = file.name;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("File terpilih: ${file.name}"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Batal memilih audio")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// =========================
  /// CEK KESALAHAN TULISAN
  /// =========================
  double hitungSimilarity(String soal, String jawaban) {
    // Normalisasi: lowercase dan hapus spasi berlebih
    String s1 = soal.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
    String s2 = jawaban.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');

    // Hitung Levenshtein Distance
    List<List<int>> matrix = List.generate(
      s1.length + 1,
      (i) => List.generate(s2.length + 1, (j) => 0),
    );

    for (int i = 0; i <= s1.length; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= s2.length; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        int cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1, // deletion
          matrix[i][j - 1] + 1, // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    int distance = matrix[s1.length][s2.length];
    int maxLength = s1.length > s2.length ? s1.length : s2.length;
    
    // Hitung persentase kesamaan (0-1)
    return maxLength == 0 ? 1.0 : 1 - (distance / maxLength);
  }

  /// =========================
  /// SUBMIT DETEKSI KE ML
  /// =========================
  Future<void> submitDeteksi() async {
    if (soal == null || tulisanController.text.isEmpty || audioFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lengkapi jawaban dan audio anak")),
      );
      return;
    }

    setState(() => isSubmitting = true);

    String hasilDiagnosis;
    String confidenceScore;

    /// 1. CEK KESALAHAN TULISAN
    double similarity = hitungSimilarity(soal!.kalimat, tulisanController.text.trim());
    
    print("Deteksi kesalahan tulisan:");
    print("  Soal: ${soal!.kalimat}");
    print("  Jawaban: ${tulisanController.text.trim()}");
    print("  Similarity: ${(similarity * 100).toStringAsFixed(1)}%");
    
    /// 2. KIRIM KE API ML (dengan teks_soal untuk analisis)
    print("\n🚀 Mengirim data ke API ML...");
    print("  - teksSoal: '${soal!.kalimat}'");
    print("  - tulisanAnak: '${tulisanController.text.trim()}'");
    print("  - audioFile: ${audioFile!.name}");
    
    final response = await DeteksiService.cekDisleksia(
      tulisanAnak: tulisanController.text.trim(),
      audioFile: audioFile!,
      teksSoal: soal!.kalimat,  // 🆕 Kirim teks soal ke API
    );

    if (response["status"] == false) {
      if (!mounted) return;
      setState(() => isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["message"]),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 8),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
      return;
    }

    hasilDiagnosis = response["prediction"];
    confidenceScore = response["confidence"]?.toString() ?? "Unknown";  
    
    print("\n📊 Response dari API:");
    print("  -> Diagnosis: $hasilDiagnosis");
    print("  -> Confidence: $confidenceScore");
    print("  -> Method: ${response['method'] ?? 'unknown'}");

    /// 3. AMBIL USER ID
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("userId");

    if (userId != null) {
      /// 4. SIMPAN KE DATABASE
      final saveResponse = await DeteksiService.simpanHasil(
        userId: userId,
        namaAnak: namaController.text.isEmpty ? "Anak" : namaController.text,
        soalId: soal!.id,
        jawabanAnak: tulisanController.text.trim(),
        hasil: hasilDiagnosis,
        confidence: confidenceScore,
      );

      if (saveResponse["status"] == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal Simpan: ${saveResponse['message']}"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }

    if (!mounted) return;
    setState(() => isSubmitting = false);

    /// 5. NAVIGASI KE HASIL
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HasilDeteksiPage(
          soalId: soal!.id,
          jawabanAnak: tulisanController.text.trim(),
          nama: namaController.text.isEmpty ? "Anak" : namaController.text,
          diagnosis: hasilDiagnosis,
          confidence: confidenceScore,
          tanggal: DateTime.now(),
        ),
      ),
    );
  }

  /// =========================
  /// UI
  /// =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// HEADER
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
                        "Deteksi Disleksia",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balancing the back button
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   /// NAMA ANAK
                  TextField(
                    controller: namaController,
                    decoration: const InputDecoration(
                      labelText: "Nama Anak",
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// SOAL
                  isLoadingSoal
                      ? const Center(child: CircularProgressIndicator())
                      : Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Text("Bacakan & tuliskan kata berikut"),
                              const SizedBox(height: 10),
                              Text(
                                soal!.kalimat,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                  const SizedBox(height: 20),

                  /// JAWABAN TEKS
                  TextField(
                    controller: tulisanController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: "Tulisan Anak"),
                  ),

                  const SizedBox(height: 20),

                  /// AUDIO
                  TextField(
                    controller: audioController,
                    readOnly: true,
                    onTap: pickAudio,
                    decoration: const InputDecoration(
                      labelText: "Upload Audio",
                      prefixIcon: Icon(Icons.mic),
                      hintText: "Pilih file audio",
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// SUBMIT
                  ElevatedButton(
                    onPressed: isSubmitting ? null : submitDeteksi,
                    child: isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Cek Hasil"),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
