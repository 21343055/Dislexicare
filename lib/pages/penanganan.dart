import 'package:flutter/material.dart';

class PenangananPage extends StatelessWidget {
  const PenangananPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
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
                      "Penanganan",
                      style: TextStyle(
                        fontSize: 25,
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
                      "Penanganan Disleksia",
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
                        "assets/images/penanganan.jpeg",
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Isi artikel
                  const Text(
                    "Penanganan disleksia dapat dilakukan dengan berbagai strategi, "
                    "seperti memberikan terapi membaca, latihan pengenalan fonem, "
                    "serta dukungan psikologis. Anak juga dapat terbantu dengan "
                    "penggunaan media pembelajaran interaktif dan pendampingan khusus "
                    "yang disesuaikan dengan kebutuhan masing-masing.",
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
