import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profil.dart';
import 'change_pw.dart';
import 'informasi.dart';
import 'deteksi.dart';
import 'riwayat.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _onMenuSelected(BuildContext context, String value) {
    switch (value) {
      case 'profile':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfilePage()),
        );
        break;
      case 'password':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
        );
        break;
      case 'logout':
        _logout(context);
        break;
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget _menuCard({
    required String title,
    required String image,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Expanded(child: Image.asset(image, fit: BoxFit.contain)),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
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
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 30),
            decoration: const BoxDecoration(
              color: Color(0xFF0D1B57),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Row(
              children: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.person, color: Colors.white),
                  onSelected: (value) => _onMenuSelected(context, value),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'profile', child: Text("Profil Saya")),
                    PopupMenuItem(
                      value: 'password',
                      child: Text("Ubah Password"),
                    ),
                    PopupMenuItem(value: 'logout', child: Text("Logout")),
                  ],
                ),
                const SizedBox(width: 12),
                const Text(
                  "DislexiCare",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _menuCard(
                    title: "Informasi\nDisleksia",
                    image: "assets/images/info.jpeg",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const InformasiPage(),
                        ),
                      );
                    },
                  ),
                  _menuCard(
                    title: "Deteksi",
                    image: "assets/images/deteksi.jpeg",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DeteksiPage()),
                      );
                    },
                  ),
                  _menuCard(
                    title: "Riwayat\nDeteksi",
                    image: "assets/images/riwayat.png",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RiwayatPage()),
                      );
                    },
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
