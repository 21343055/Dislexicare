import 'package:flutter/material.dart';

class DisleksiaPage extends StatelessWidget {
  const DisleksiaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header biru melengkung
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
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Artikel Disleksia",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Konten scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul artikel
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Apa itu Disleksia?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Gambar
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        "assets/images/apa.png",
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Isi artikel
                  const Text(
                    "Disleksia adalah gangguan belajar yang memengaruhi kemampuan seseorang "
                    "untuk membaca, menulis, dan mengeja dengan baik. Gangguan ini tidak "
                    "berhubungan dengan tingkat kecerdasan, melainkan pada cara otak "
                    "memproses simbol bahasa.\n\n"
                    "Anak dengan disleksia sering mengalami kesulitan mengenali huruf, "
                    "menghubungkan bunyi dengan simbol, dan memahami teks bacaan. "
                    "Namun dengan dukungan dan metode pembelajaran yang tepat, "
                    "anak disleksia tetap dapat berkembang optimal.",
                    style: TextStyle(fontSize: 16, height: 1.5),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
