import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config/api.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> profile;

  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController usernameController;
  late TextEditingController phoneController;
  late TextEditingController birthController;
  late TextEditingController cityController;

  String gender = "Laki-Laki";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    usernameController = TextEditingController(
      text: widget.profile["username"],
    );
    phoneController = TextEditingController(
      text: widget.profile["no_hp"] ?? "",
    );
    birthController = TextEditingController(
      text: widget.profile["tanggal_lahir"] ?? "",
    );
    cityController = TextEditingController(text: widget.profile["kota"] ?? "");

    gender = widget.profile["jenis_kelamin"] ?? "Laki-Laki";
  }

  Future<void> _saveProfile() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("userId");

    if (userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User belum login"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final body = {
      "user_id": userId,
      "username": usernameController.text,
      "no_hp": phoneController.text,
      "tanggal_lahir": birthController.text,
      "jenis_kelamin": gender,
      "kota": cityController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.updateProfile),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final result = jsonDecode(response.body);

      if (!mounted) return;

      if (result["status"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil berhasil diperbarui"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // trigger refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result["message"]),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Terjadi kesalahan"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ubah Profil")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            /// Username
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            /// Nomor HP
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Nomor Telepon",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            /// Tanggal Lahir
            TextField(
              controller: birthController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Tanggal Lahir",
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate:
                      DateTime.tryParse(
                        birthController.text.isNotEmpty
                            ? birthController.text
                            : "2000-01-01",
                      ) ??
                      DateTime(2000),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );

                if (picked != null) {
                  birthController.text =
                      "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                }
              },
            ),
            const SizedBox(height: 16),

            /// Jenis Kelamin
            DropdownButtonFormField<String>(
              initialValue: gender,
              items: const [
                DropdownMenuItem(value: "Laki-Laki", child: Text("Laki-Laki")),
                DropdownMenuItem(value: "Perempuan", child: Text("Perempuan")),
              ],
              onChanged: (value) {
                setState(() {
                  gender = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: "Jenis Kelamin",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            /// Kota
            TextField(
              controller: cityController,
              decoration: const InputDecoration(
                labelText: "Kota",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            /// Tombol Simpan
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Simpan",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
