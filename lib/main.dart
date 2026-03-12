import 'package:dislexicare/admin/admin_dashboard.dart';
import 'package:flutter/material.dart';
import 'utils/app_color.dart';
import 'pages/splash_page.dart';
import 'pages/login.dart';
import 'pages/signup.dart';
import 'pages/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DislexiCareApp());
}

class DislexiCareApp extends StatelessWidget {
  const DislexiCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DislexiCare',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primaryColor: AppColor.primary,
        scaffoldBackgroundColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColor.primary, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),

      /// Splash sebagai auth guard
      initialRoute: '/splash',

      routes: {
        '/splash': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => const HomePage(),
        '/admin-dashboard': (context) => const AdminDashboardPage(),
      },

      /// fallback jika route tidak ditemukan
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("Halaman tidak ditemukan")),
          ),
        );
      },
    );
  }
}
