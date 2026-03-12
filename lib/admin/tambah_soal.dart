import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/soal_service.dart';

class TambahSoalPage extends StatefulWidget {
  const TambahSoalPage({super.key});

  @override
  State<TambahSoalPage> createState() => _TambahSoalPageState();
}

class _TambahSoalPageState extends State<TambahSoalPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController soalController = TextEditingController();

  String? selectedTingkat;
  bool isLoading = false;

  final List<String> tingkatList = ['mudah', 'sedang', 'sulit'];

  @override
  void initState() {
    super.initState();
    selectedTingkat = tingkatList.first; // default = mudah
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedTingkat == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Pilih tingkat kesulitan")));
      return;
    }

    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("userId");

    if (userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sesi habis, silakan login ulang")),
      );
      setState(() => isLoading = false);
      return;
    }

    try {
      await SoalService.addSoal(
        userId: userId,
        teksSoal: soalController.text,
        tingkatKesulitan: selectedTingkat!,
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Soal")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: soalController,
                decoration: const InputDecoration(
                  labelText: "Teks Soal",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Tidak boleh kosong" : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: selectedTingkat,
                items: tingkatList
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e[0].toUpperCase() + e.substring(1)),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    selectedTingkat = v;
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Tingkat Kesulitan",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : _simpan,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Simpan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
