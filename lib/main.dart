import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';
import 'dashboard_page.dart';

List<Map<String, dynamic>> dataPelanggan = [];

List<Map<String, dynamic>> dataTagihan = [];

List<Map<String, dynamic>> dataRiwayat = [];

String currentUser = "";
String currentRole = "";

Future<void> loadSession() async {
  final prefs = await SharedPreferences.getInstance();
  currentUser = prefs.getString("currentUser") ?? "";
  currentRole = prefs.getString("currentRole") ?? "";
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ffchsmgkzhkbibzpaawd.supabase.co', // Ganti dengan URL proyek Supabase-mu
    anonKey: 'sb_publishable_TvhSlR06UtG0ZcY9nb7G-A_8Ch5rIrW', // Ganti dengan Anon Key Supabase-mu
  );
  await loadSession();

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: "Aplikasi PAM",

      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(
          0xffF5F9FF,
        ),
      ),

      home: currentRole.isNotEmpty ? DashboardPage() : const LoginPage(),
    );
  }
}
