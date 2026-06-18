import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'login_page.dart';
import 'pelanggan_page.dart';
import 'input_meteran_page.dart';
import 'tagihan_page.dart';
import 'riwayat_page.dart';
import 'laporan_page.dart';
import 'tagihan_saya_page.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});

  Future<void> logout(
    BuildContext context,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(
      "currentUser",
    );

    await prefs.remove(
      "currentRole",
    );

    currentUser = "";
    currentRole = "";

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final formatRupiah = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    int totalPelanggan = dataPelanggan.length;

    int totalTagihan = dataTagihan.length;

    int totalRiwayat = dataRiwayat.length;

    return Scaffold(
      backgroundColor: const Color(
        0xffF5F9FF,
      ),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Dashboard ${currentRole.toUpperCase()}",
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(
            20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =====================
              // HEADER
              // =====================
              Text(
                "Halo, $currentUser",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              Text(
                "Selamat datang di aplikasi PAM",
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(
                height: 20,
              ),

// =====================
// NOTIFIKASI PELANGGAN
// =====================
              if (currentRole == "pelanggan")
                Builder(
                  builder: (context) {
                    final tagihanBelumBayar = dataTagihan.where(
                      (item) {
                        return item["nama"].toString().toLowerCase() ==
                                currentUser.toLowerCase() &&
                            item["status"] == "Belum Bayar";
                      },
                    ).toList();

                    int totalTagihan = 0;

                    for (var item in tagihanBelumBayar) {
                      totalTagihan += (item["tagihan"] as int?) ?? 0;
                    }

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(
                        18,
                      ),
                      decoration: BoxDecoration(
                        color: tagihanBelumBayar.isEmpty
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(
                          20,
                        ),
                        border: Border.all(
                          color: tagihanBelumBayar.isEmpty
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            tagihanBelumBayar.isEmpty
                                ? Icons.check_circle
                                : Icons.warning,
                            color: tagihanBelumBayar.isEmpty
                                ? Colors.green
                                : Colors.red,
                            size: 35,
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tagihanBelumBayar.isEmpty
                                      ? "Tidak ada tunggakan"
                                      : "Anda memiliki ${tagihanBelumBayar.length} tagihan belum dibayar",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  tagihanBelumBayar.isEmpty
                                      ? "Semua tagihan sudah lunas"
                                      : "Total : ${formatRupiah.format(totalTagihan)}",
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(
                height: 25,
              ),

              // =====================
              // STATISTIK
              // =====================
              if (currentRole != "pelanggan")
                Container(
                  padding: const EdgeInsets.all(
                    18,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Colors.blue,
                        Color(
                          0xff42A5F5,
                        ),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(
                      25,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Icon(
                            Icons.people,
                            color: Colors.white,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            "$totalPelanggan",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "Pelanggan",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Icon(
                            Icons.receipt,
                            color: Colors.white,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            "$totalTagihan",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "Tagihan",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Icon(
                            Icons.history,
                            color: Colors.white,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            "$totalRiwayat",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "Riwayat",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              const SizedBox(
                height: 25,
              ),

              const Text(
                "Menu Utama",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              // ADMIN & PETUGAS
              if (currentRole != "pelanggan")
                menuCard(
                  icon: Icons.people,
                  title: "Data Pelanggan",
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DataPelangganPage(),
                      ),
                    );
                  },
                ),

              if (currentRole != "pelanggan")
                menuCard(
                  icon: Icons.water_drop,
                  title: "Input Meteran",
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const InputMeteranPage(),
                      ),
                    );
                  },
                ),

              if (currentRole != "pelanggan")
                menuCard(
                  icon: Icons.money,
                  title: "Tagihan",
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TagihanPage(),
                      ),
                    );
                  },
                ),

              // KHUSUS PELANGGAN
              if (currentRole == "pelanggan")
                menuCard(
                  icon: Icons.receipt_long,
                  title: "Tagihan Saya",
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TagihanSayaPage(),
                      ),
                    );
                  },
                ),

              // SEMUA ROLE
              menuCard(
                icon: Icons.history,
                title: "Riwayat",
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RiwayatPage(),
                    ),
                  );
                },
              ),

              // ADMIN ONLY
              if (currentRole == "admin")
                menuCard(
                  icon: Icons.bar_chart,
                  title: "Laporan",
                  color: Colors.indigo,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LaporanPage(),
                      ),
                    );
                  },
                ),

              // LOGOUT
              menuCard(
                icon: Icons.logout,
                title: "Logout",
                color: Colors.red,
                onTap: () {
                  logout(
                    context,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget menuCard({
      required IconData icon,
      required String title,
      required Color color,
      required VoidCallback onTap,
    }) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 80,
          margin: const EdgeInsets.only(
            bottom: 12,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              20,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
              ),
            ],
          ),
        ),
      );
    }

}
