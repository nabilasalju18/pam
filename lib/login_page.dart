import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import untuk simpan session
import 'package:supabase_flutter/supabase_flutter.dart'; // 1. Import Supabase
import 'dashboard_page.dart';
import 'main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isHidden = true;
  bool isLoading = false;

  // Inisialisasi client Supabase
  final supabase = Supabase.instance.client;

  // =====================
  // LOGIN SUPABASE
  // =====================
Future<void> login() async {
  String username = usernameController.text.trim();
  String password = passwordController.text.trim();

  if (username.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Username dan Password wajib diisi")),
    );
    return;
  }

  setState(() => isLoading = true); // Jika kamu ingin menambahkan loading state

  try {
    // 1. Jalankan query ke tabel 'users' terlebih dahulu
    final response = await supabase
        .from('users')
        .select()
        .eq('username', username)
        .eq('password', password)
        .maybeSingle();

    if (response != null) {
      // Jika user ditemukan di tabel 'users' (Ini biasanya untuk Admin / Petugas)
      currentUser = response['username'];
      
      // Ambil role dari kolom 'role' di database. Jika kolom 'role' tidak ada, 
      // pastikan kolom tersebut dibuat di Supabase, atau gunakan default text 'admin' / 'petugas'
      currentRole = (response['role'] ?? response['username']).toString().toLowerCase(); 

      // Simpan session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("currentUser", currentUser);
      await prefs.setString("currentRole", currentRole);

      _pindahKeDashboard();
      return;
    }

    // 2. JIKA TIDAK KETEMU DI TABEL 'USERS', CEK APAKAH DIA PELANGGAN
    // Kita cek ke tabel 'pelanggan' menggunakan 'nama' sebagai username, 
    // dan pastikan di tabel pelanggan kamu juga menambahkan kolom 'password' (atau no_meter sebagai password bawaan)
    final responsePelanggan = await supabase
        .from('pelanggan')
        .select()
        .eq('nama', username)
        .eq('password', password)
        .maybeSingle();

    if (responsePelanggan != null) {
      // Jika ditemukan di data pelanggan, set statusnya sebagai role 'pelanggan' yang baku
      currentUser = responsePelanggan['nama'];
      currentRole = 'pelanggan'; // Dikunci menjadi string 'pelanggan' agar Dashboard tidak bingung

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("currentUser", currentUser);
      await prefs.setString("currentRole", currentRole);
      // Opsional: Simpan juga ID Pelanggan untuk mempermudah melihat tagihan sendiri nanti
      await prefs.setInt("currentPelangganId", responsePelanggan['id']);

      _pindahKeDashboard();
    } else {
      // Jika di kedua tabel tidak ditemukan
      _showSnackBar("Username / Password salah atau tidak terdaftar");
    }

  } catch (e) {
    _showSnackBar("Terjadi kesalahan: $e");
  } finally {
    setState(() => isLoading = false);
  }
}

// Fungsi pembantu agar kode lebih bersih
void _pindahKeDashboard() {
  if (mounted) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardPage()),
    );
  }
}

void _showSnackBar(String pesan) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }
}
  Widget inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? isHidden : false,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(
          icon,
          color: Colors.blue,
        ),
        suffixIcon: isPassword
            ? IconButton(
                onPressed: () {
                  setState(
                    () {
                      isHidden = !isHidden;
                    },
                  );
                },
                icon: Icon(
                  isHidden ? Icons.visibility : Icons.visibility_off,
                ),
              )
            : null,
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            18,
          ),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xff1976D2),
              Color(0xff64B5F6),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.water_drop,
                        size: 80,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Aplikasi PAM",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Sistem Pengelolaan Air PAM",
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 30),
                    inputField(
                      controller: usernameController,
                      label: "Username",
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 20),
                    inputField(
                      controller: passwordController,
                      label: "Password",
                      icon: Icons.lock,
                      isPassword: true,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: login,
                        child: const Text(
                          "LOGIN",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20)
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}