import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/soal_model.dart';
import '../service/soal_service.dart';
import 'tambah_soal.dart';
import 'edit_soal.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  List<SoalModel> soalList = [];
  bool isLoading = true;
  int? userId;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  /// =============================
  /// CEK ROLE ADMIN
  /// =============================
  Future<void> _checkAdmin() async {
    final prefs = await SharedPreferences.getInstance();

    final role = prefs.getString("role");
    userId = prefs.getInt("userId"); // ✅ FIXED

    if (role != "admin" || userId == null) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    _fetchSoal();
  }

  /// =============================
  /// FETCH SOAL
  /// =============================
  Future<void> _fetchSoal() async {
    try {
      final data = await SoalService.getSoalList();
      if (!mounted) return;
      setState(() {
        soalList = data;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  /// =============================
  /// HAPUS SOAL
  /// =============================
  Future<void> _hapusSoal(int id) async {
    await SoalService.deleteSoal(userId: userId!, id: id);
    _fetchSoal();
  }

  /// =============================
  /// LOGOUT
  /// =============================
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo),
              child: Text(
                "Admin Panel",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: _logout,
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("Manajemen Soal"),
        backgroundColor: Colors.indigo,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahSoalPage()),
          );
          _fetchSoal();
        },
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: soalList.length,
              itemBuilder: (context, index) {
                final soal = soalList[index];
                return Card(
                  margin: const EdgeInsets.all(12),
                  child: ListTile(
                    title: Text(soal.kalimat),
                    subtitle: Text("Tingkat: ${soal.tingkatKesulitan}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditSoalPage(soal: soal),
                              ),
                            );
                            _fetchSoal();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _hapusSoal(soal.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
