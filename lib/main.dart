import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'dashboard_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

List<Map<String, dynamic>> dataPelanggan = [];

List<Map<String, dynamic>> dataTagihan = [];

List<Map<String, dynamic>> dataRiwayat = [];

// =======================
// LOGIN USER
// =======================
String currentUser = "";
String currentRole = "";

// =======================
// SIMPAN DATA
// =======================
Future<void> simpanData() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setString(
    "pelanggan",
    jsonEncode(
      dataPelanggan,
    ),
  );

  await prefs.setString(
    "tagihan",
    jsonEncode(
      dataTagihan,
    ),
  );

  await prefs.setString(
    "riwayat",
    jsonEncode(
      dataRiwayat,
    ),
  );

  // LOGIN SESSION
  await prefs.setString(
    "currentUser",
    currentUser,
  );

  await prefs.setString(
    "currentRole",
    currentRole,
  );
}

// =======================
// LOAD DATA
// =======================
Future<void> loadData() async {
  final prefs = await SharedPreferences.getInstance();

  String? pelanggan = prefs.getString(
    "pelanggan",
  );

  String? tagihan = prefs.getString(
    "tagihan",
  );

  String? riwayat = prefs.getString(
    "riwayat",
  );

  // LOAD PELANGGAN
  if (pelanggan != null) {
    dataPelanggan = List<Map<String, dynamic>>.from(
      jsonDecode(
        pelanggan,
      ),
    );
  }

  // LOAD TAGIHAN
  if (tagihan != null) {
    dataTagihan = List<Map<String, dynamic>>.from(
      jsonDecode(
        tagihan,
      ),
    );
  }

  // LOAD RIWAYAT
  if (riwayat != null) {
    dataRiwayat = List<Map<String, dynamic>>.from(
      jsonDecode(
        riwayat,
      ),
    );
  }

  // ===================
  // LOAD LOGIN SESSION
  // ===================
  currentUser = prefs.getString(
        "currentUser",
      ) ??
      "";

  currentRole = prefs.getString(
        "currentRole",
      ) ??
      "";
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadData();

  await Supabase.initialize(
    url: 'https://ffchsmgkzhkbibzpaawd.supabase.co',
    publishableKey: 'sb_publishable_TvhSlR06UtG0ZcY9nb7G-A_8Ch5rIrW',
  );
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

      // ===================
      // AUTO LOGIN
      // ===================
      home: currentRole.isNotEmpty ? DashboardPage() : const LoginPage(),
    );
  }
}
