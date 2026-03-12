import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/soal_model.dart';
import '../service/soal_service.dart';
import 'tambah_soal.dart';
import 'edit_soal.dart';
import '../pages/login.dart';

class SoalPage extends StatefulWidget {
  const SoalPage({super.key});

  @override
  State<SoalPage> createState() => _SoalPageState();
}

class _SoalPageState extends State<SoalPage> {
  bool isLoading = true;
  List<SoalModel> soalList = [];

  int? userId;
  String? role;

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  Future<void> _initUser() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt("userId"); // ✅ FIX
    role = prefs.getString("role");

    if (userId == null || role != "admin") {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Akses ditolak. Admin only."),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }

    fetchSoal();
  }

  Future<void> fetchSoal() async {
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal memuat soal")));
    }
  }

  Future<void> hapusSoal(int id) async {
    if (userId == null) return;

    try {
      await SoalService.deleteSoal(id: id, userId: userId!);
      fetchSoal();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Soal berhasil dihapus")));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal menghapus soal")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahSoalPage()),
          );
          fetchSoal();
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: soalList.length,
        itemBuilder: (context, index) {
          final soal = soalList[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(soal.kalimat),
              subtitle: Text("Kesulitan: ${soal.tingkatKesulitan}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditSoalPage(soal: soal),
                        ),
                      );
                      fetchSoal();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => hapusSoal(soal.id),
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
