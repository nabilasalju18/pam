import 'package:flutter/material.dart';
import 'main.dart';

class QrisPage extends StatefulWidget {
  final int indexTagihan;

  const QrisPage({
    super.key,
    required this.indexTagihan,
  });

  @override
  State<QrisPage> createState() => _QrisPageState();
}

class _QrisPageState extends State<QrisPage> {
  @override
  Widget build(BuildContext context) {
    final tagihan = dataTagihan[widget.indexTagihan];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pembayaran QRIS",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(
              Icons.qr_code,
              size: 220,
            ),
            const SizedBox(height: 20),
            Text(
              "Total Tagihan",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            Text(
              "Rp ${tagihan["tagihan"]}",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  setState(() {
                    dataTagihan[widget.indexTagihan]["status"] =
                        "Menunggu Verifikasi";
                  });

                  await simpanData();

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Pembayaran berhasil dikirim",
                        ),
                      ),
                    );

                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  "Saya Sudah Bayar",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
