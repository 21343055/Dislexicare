import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/profil_service.dart';
import 'edit_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = true;
  Map<String, dynamic>? profile;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("userId");

    if (userId == null) {
      if (!mounted) return;
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await ProfileService.getProfile(userId);

      if (!mounted) return;

      if (response["status"] == true) {
        setState(() {
          profile = response["data"];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Widget buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (profile == null) {
      return const Scaffold(body: Center(child: Text("Gagal memuat profil")));
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            /// ================= HEADER =================
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        "Profil Saya",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfilePage(profile: profile!),
                        ),
                      );

                      /// refresh HANYA jika update berhasil
                      if (result == true) {
                        fetchProfile();
                      }
                    },
                    child: const Text(
                      "Ubah",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

            /// ================= INFO UTAMA =================
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.black12,
                    child: Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile!["username"] ?? "-",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(profile!["no_hp"] ?? "-"),
                        Text(profile!["email"] ?? "-"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// ================= DETAIL =================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildInfoItem(
                            "Tanggal Lahir",
                            profile!["tanggal_lahir"] ?? "-",
                          ),
                          buildInfoItem(
                            "Jenis Kelamin",
                            profile!["jenis_kelamin"] ?? "-",
                          ),
                          buildInfoItem(
                            "Kota / Kabupaten",
                            profile!["kota"] ?? "-",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
