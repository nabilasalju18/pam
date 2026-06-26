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
        const SnackBar(
          content: Text("Username dan Password wajib diisi"),
        ),
      );
      return;
    }

    try {
      // 2. Query ke tabel 'users' mencocokkan username dan password secara case-sensitive atau biasa
      final response = await supabase
          .from('users')
          .select()
          .eq('username', username)
          .eq('password', password)
          .maybeSingle(); // Mengambil single object, atau null jika tidak ketemu

      if (response != null) {
        // Jika data user ditemukan di database
        // Di sini role ditentukan dari kata 'Admin', 'Petugas', atau 'Pelanggan' sesuai input database-mu
        currentUser = response['username'];
        currentRole = response['username'].toString().toLowerCase(); 

        // 3. Simpan session login ke SharedPreferences (menggantikan simpanData lama)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("currentUser", currentUser);
        await prefs.setString("currentRole", currentRole);

        // Pindah ke halaman Dashboard
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => DashboardPage(),
            ),
          );
        }
      } else {
        // Jika data tidak ditemukan / salah password
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Username / Password salah atau tidak terdaftar"),
            ),
          );
        }
      }
    } catch (e) {
      // Menangani error koneksi internet atau database
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Terjadi kesalahan: $e"),
          ),
        );
      }
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