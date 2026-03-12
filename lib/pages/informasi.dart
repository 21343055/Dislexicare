import 'package:flutter/material.dart';
import 'disleksia.dart';
import 'pencegahan.dart';
import 'penanganan.dart';

class InformasiPage extends StatelessWidget {
  const InformasiPage({super.key});

  Widget _buildInfoCard(String title, String assetPath, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(assetPath, height: 90, fit: BoxFit.cover),
            ),
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                      "Informasi Disleksia",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48), // sama dengan lebar IconButton
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Konten
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              padding: const EdgeInsets.all(16),
              children: [
                _buildInfoCard(
                  "Apa itu Disleksia?",
                  "assets/images/apa.png",
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DisleksiaPage()),
                    );
                  },
                ),
                _buildInfoCard(
                  "Pencegahan",
                  "assets/images/pencegahan.png",
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PencegahanPage()),
                    );
                  },
                ),
                _buildInfoCard(
                  "Penanganan",
                  "assets/images/penanganan.jpeg",
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PenangananPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
