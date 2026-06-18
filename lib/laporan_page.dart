import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'main.dart';

class LaporanPage extends StatelessWidget {
  const LaporanPage({
    super.key,
  });

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

    int totalPemasukan = dataRiwayat.fold(
      0,
      (
        sum,
        item,
      ) =>
          sum + ((item["tagihan"] ?? 0) as int),
    );

    return Scaffold(
      backgroundColor: const Color(
        0xffF5F6FA,
      ),
      appBar: AppBar(
        title: const Text(
          "Laporan PAM",
        ),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(
            20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Laporan Bulanan",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                "Ringkasan data sistem PAM",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 15,
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              laporanCard(
                "Jumlah Pelanggan",
                totalPelanggan.toString(),
                Colors.orange,
                Icons.people,
              ),
              const SizedBox(
                height: 15,
              ),
              laporanCard(
                "Tagihan Aktif",
                totalTagihan.toString(),
                Colors.green,
                Icons.receipt_long,
              ),
              const SizedBox(
                height: 15,
              ),
              laporanCard(
                "Riwayat Pembayaran",
                totalRiwayat.toString(),
                Colors.purple,
                Icons.history,
              ),
              const SizedBox(
                height: 15,
              ),
              laporanCard(
                "Total Pemasukan",
                formatRupiah.format(
                  totalPemasukan,
                ),
                Colors.indigo,
                Icons.payments,
              ),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        15,
                      ),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Fitur PDF laporan akan dibuat tahap berikutnya",
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.picture_as_pdf,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Cetak Laporan PDF",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget laporanCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(
        18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          20,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(
              0,
              4,
            ),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color.withOpacity(
              0.15,
            ),
            child: Icon(
              icon,
              color: color,
              size: 32,
            ),
          ),
          const SizedBox(
            width: 18,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 15,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
