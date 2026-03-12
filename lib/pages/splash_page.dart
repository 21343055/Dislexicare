import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_color.dart';
import '../widget/custom_button.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  /// =============================
  /// CEK SESSION LOGIN
  /// =============================
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLogin = prefs.getBool('isLogin') ?? false;

    await Future.delayed(const Duration(seconds: 2)); // efek splash

    if (!mounted) return;

    if (isLogin) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() => isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColor.primary, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: isChecking
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),

                      /// =============================
                      /// LOGO / TITLE
                      /// =============================
                      const Text(
                        "DislexiCare",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Hello, Welcome!\nWelcome to DislexiCare",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.white70),
                      ),

                      const Spacer(),

                      /// =============================
                      /// LOGIN BUTTON
                      /// =============================
                      CustomButton(
                        text: "Login",
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                      ),
                      const SizedBox(height: 16),

                      /// =============================
                      /// SIGN UP BUTTON
                      /// =============================
                      CustomButton(
                        text: "Sign Up",
                        isOutlined: true,
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/signup');
                        },
                      ),

                      const Spacer(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
