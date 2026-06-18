import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'main.dart';
import 'pdf_service.dart';

class TagihanPage extends StatefulWidget {
  const TagihanPage({
    super.key,
  });

  @override
  State<TagihanPage> createState() => _TagihanPageState();
}

class _TagihanPageState extends State<TagihanPage> {
  final formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  // ==========================
  // VERIFIKASI LUNAS
  // ==========================
  Future<void> verifikasiLunas(
    int index,
  ) async {
    setState(() {
      dataTagihan[index]["status"] = "Lunas";

      // Tambahkan ke riwayat
      dataRiwayat.add(
        Map<String, dynamic>.from(
          dataTagihan[index],
        ),
      );
    });

    await simpanData();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Pembayaran berhasil diverifikasi",
        ),
      ),
    );
  }

  // ==========================
  // TOLAK PEMBAYARAN
  // ==========================
  Future<void> tolakPembayaran(
    int index,
  ) async {
    setState(() {
      dataTagihan[index]["status"] = "Belum Bayar";

      dataTagihan[index]["metode"] = null;

      dataTagihan[index]["buktiTransfer"] = null;
    });

    await simpanData();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Pembayaran ditolak",
        ),
      ),
    );
  }

  // ==========================
  // LIHAT BUKTI TRANSFER
  // ==========================
  void lihatBukti(
    String imagePath,
  ) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              20,
            ),
            child: Image.file(
              File(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F9FF),
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          "Tagihan",
        ),
      ),
      body: dataTagihan.isEmpty
          ? const Center(
              child: Text(
                "Belum ada tagihan",
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(
                15,
              ),
              itemCount: dataTagihan.length,
              itemBuilder: (
                context,
                index,
              ) {
                final item = dataTagihan[index];

                bool lunas = item["status"] == "Lunas";

                bool menunggu = item["status"] == "Menunggu Verifikasi";

                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.only(
                    bottom: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(
                      16,
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: lunas
                                ? Colors.green
                                : menunggu
                                    ? Colors.orange
                                    : Colors.red,
                            child: Icon(
                              lunas ? Icons.check : Icons.warning,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            item["nama"],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                              Text(
                                "Status : ${item["status"]}",
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            // ===================
                            // CETAK STRUK
                            // ===================
                            if (lunas)
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                  ),
                                  onPressed: () {
                                    PdfService.cetakStruk(
                                      nama: item["nama"],
                                      pemakaian: item["pemakaian"],
                                      tagihan: item["tagihan"],
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.print,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "Struk",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),

                            // ===================
                            // MENUNGGU VERIFIKASI
                            // ===================
                            if (menunggu) ...[
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                  ),
                                  onPressed: () {
                                    lihatBukti(
                                      item["buktiTransfer"],
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.image,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "Lihat Bukti",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  onPressed: () {
                                    verifikasiLunas(
                                      index,
                                    );
                                  },
                                  child: const Text(
                                    "Lunas",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () {
                                    tolakPembayaran(
                                      index,
                                    );
                                  },
                                  child: const Text(
                                    "Tolak",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],

                            // ===================
                            // BELUM BAYAR
                            // ===================
                            if (!lunas && !menunggu)
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                  ),
                                  onPressed: null,
                                  child: const Text(
                                    "Belum Bayar",
                                  ),
                                ),
                              ),
                          ],
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
