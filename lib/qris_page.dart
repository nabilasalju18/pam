import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QrisPage extends StatefulWidget {
  final int idTagihan;
  final int nominalTagihan;

  const QrisPage({super.key, required this.idTagihan, required this.nominalTagihan});

  @override
  State<QrisPage> createState() => _QrisPageState();
}

class _QrisPageState extends State<QrisPage> {
  final supabase = Supabase.instance.client;
  bool isProcessing = false;

  final formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  Future<void> konfirmasiPembayaran() async {
    setState(() => isProcessing = true);

    try {
      // Mengubah status menjadi 'Menunggu Verifikasi' dan mengisi metode 'QRIS' di Supabase
      await supabase
          .from('tagihan')
          .update({
            'status': 'Menunggu Verifikasi',
            'metode': 'QRIS',
          })
          .eq('id', widget.idTagihan);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pembayaran berhasil dikirim. Menunggu verifikasi admin."),
            backgroundColor: Colors.green,
          ),
        );
        // Kembali ke halaman sebelumnya dengan membawa status sukses (true) agar halaman utama bisa refresh otomatis
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal mengirim konfirmasi: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F9FF), // Menambahkan background senada dengan halaman utama
      appBar: AppBar(
        title: const Text("Pembayaran QRIS"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Membuat konten berada di tengah vertikal
          children: [
            const Text(
              "Pindai QRIS untuk Membayar",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Dibungkus Card agar QR Code terlihat lebih fokus dan menarik
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Icon(
                  Icons.qr_code_2,
                  size: 240,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Total Tagihan",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              formatRupiah.format(widget.nominalTagihan),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50, // Memberikan tinggi yang pas agar tombol nyaman ditekan
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white, // Memastikan warna teks/loading tetap putih
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isProcessing ? null : konfirmasiPembayaran,
                child: isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        "Saya Sudah Bayar",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}