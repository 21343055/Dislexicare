import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  bool isLoading = false;

  Future<void> _ubahPassword() async {
    final oldPass = oldPasswordController.text.trim();
    final newPass = newPasswordController.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua field harus diisi")));
      return;
    }

    if (newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password baru minimal 6 karakter")),
      );
      return;
    }

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
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.changePassword),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "old_password": oldPass,
          "new_password": newPass,
        }),
      );

      final result = jsonDecode(response.body);

      if (!mounted) return;

      if (result["status"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password berhasil diubah"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
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
          content: Text("Gagal terhubung ke server"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Ubah Password",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text(
                "Masukkan password lama dan password baru Anda",
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),

              /// PASSWORD LAMA
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password Lama",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              /// PASSWORD BARU
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password Baru",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              /// BUTTON
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _ubahPassword,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Ubah Password",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
