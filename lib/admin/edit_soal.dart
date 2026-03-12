import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/soal_model.dart';
import '../service/soal_service.dart';

class EditSoalPage extends StatefulWidget {
  final SoalModel soal;

  const EditSoalPage({super.key, required this.soal});

  @override
  State<EditSoalPage> createState() => _EditSoalPageState();
}

class _EditSoalPageState extends State<EditSoalPage> {
  late TextEditingController soalController;

  String? selectedTingkat;
  bool isLoading = false;

  final List<String> tingkatList = ['mudah', 'sedang', 'sulit'];

  @override
  void initState() {
    super.initState();
    soalController = TextEditingController(text: widget.soal.kalimat);

    selectedTingkat = widget.soal.tingkatKesulitan.toLowerCase();
  }

  Future<void> _update() async {
    if (selectedTingkat == null || soalController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Data tidak boleh kosong")));
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
      await SoalService.updateSoal(
        userId: userId,
        id: widget.soal.id,
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
      appBar: AppBar(title: const Text("Edit Soal")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: soalController,
              decoration: const InputDecoration(
                labelText: "Teks Soal",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: selectedTingkat,
              items: tingkatList
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e[0].toUpperCase() + e.substring(1)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedTingkat = value;
                });
              },
              decoration: const InputDecoration(
                labelText: "Tingkat Kesulitan",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : _update,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }
}
