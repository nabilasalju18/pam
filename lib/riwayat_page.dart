import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'main.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({
    super.key,
  });

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  @override
  Widget build(BuildContext context) {
    final formatRupiah = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    // ==========================
    // FILTER BERDASARKAN ROLE
    // ==========================
    final riwayatTampil = currentRole == "pelanggan"
        ? dataRiwayat.where(
            (item) {
              return item["nama"].toString().toLowerCase() ==
                  currentUser.toLowerCase();
            },
          ).toList()
        : dataRiwayat;

    return Scaffold(
      backgroundColor: const Color(0xffF5F9FF),
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text(
          "Riwayat Pembayaran",
        ),
      ),
      body: riwayatTampil.isEmpty
          ? const Center(
              child: Text(
                "Belum ada riwayat pembayaran",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            )
          : ListView.builder(
              itemCount: riwayatTampil.length,
              itemBuilder: (context, index) {
                final item = riwayatTampil[index];

                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(
                      15,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.purple,
                          child: const Icon(
                            Icons.receipt_long,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["nama"],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                "Pemakaian : ${item["pemakaian"]} m³",
                              ),
                              Text(
                                formatRupiah.format(
                                  item["tagihan"],
                                ),
                              ),
                              Text(
                                "Metode : ${item["metode"] ?? "-"}",
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(
                                    10,
                                  ),
                                ),
                                child: const Text(
                                  "Sudah Bayar",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
