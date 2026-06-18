import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'main.dart';

class TagihanSayaPage extends StatefulWidget {
  const TagihanSayaPage({
    super.key,
  });

  @override
  State<TagihanSayaPage> createState() => _TagihanSayaPageState();
}

class _TagihanSayaPageState extends State<TagihanSayaPage> {
  final formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  // ==========================
  // PILIH GAMBAR BUKTI TRANSFER
  // ==========================
  Future<void> pilihGambar(
    Map<String, dynamic> item,
    String metodeBayar,
  ) async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image == null) return;

    item["status"] = "Menunggu Verifikasi";

    item["metode"] = metodeBayar;

    item["buktiTransfer"] = image.path;

    await simpanData();

    setState(() {});

    if (!mounted) return;

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Bukti pembayaran berhasil dikirim ($metodeBayar)",
        ),
      ),
    );
  }

  // ==========================
  // PILIH METODE PEMBAYARAN
  // ==========================
  void pilihPembayaran(
    Map<String, dynamic> item,
  ) {
    String metodeBayar = "Transfer Bank";

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  20,
                ),
              ),
              title: const Text(
                "Metode Pembayaran",
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  radioItem(
                    "Transfer Bank",
                    metodeBayar,
                    setDialogState,
                    (v) => metodeBayar = v,
                  ),
                  radioItem(
                    "DANA",
                    metodeBayar,
                    setDialogState,
                    (v) => metodeBayar = v,
                  ),
                  radioItem(
                    "ShopeePay",
                    metodeBayar,
                    setDialogState,
                    (v) => metodeBayar = v,
                  ),
                  radioItem(
                    "OVO",
                    metodeBayar,
                    setDialogState,
                    (v) => metodeBayar = v,
                  ),
                  radioItem(
                    "GoPay",
                    metodeBayar,
                    setDialogState,
                    (v) => metodeBayar = v,
                  ),
                  radioItem(
                    "QRIS",
                    metodeBayar,
                    setDialogState,
                    (v) => metodeBayar = v,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                  },
                  child: const Text(
                    "Batal",
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await pilihGambar(
                      item,
                      metodeBayar,
                    );
                  },
                  child: const Text(
                    "Upload Bukti",
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================
  // RADIO BUTTON
  // ==========================
  Widget radioItem(
    String title,
    String group,
    StateSetter setDialogState,
    Function(String) onChanged,
  ) {
    return RadioListTile(
      value: title,
      groupValue: group,
      title: Text(title),
      onChanged: (value) {
        setDialogState(() {
          onChanged(value!);
        });
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final tagihanSaya = dataTagihan
        .where(
          (item) =>
              item["nama"].toString().toLowerCase() ==
              currentUser.toLowerCase(),
        )
        .toList();

    int totalTagihan = tagihanSaya.fold(
      0,
      (sum, item) => sum + (item["tagihan"] as int),
    );

    return Scaffold(
      backgroundColor: const Color(
        0xffF5F9FF,
      ),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Tagihan Saya",
        ),
      ),
      body: tagihanSaya.isEmpty
          ? const Center(
              child: Text(
                "Tidak ada tagihan",
              ),
            )
          : Column(
              children: [
                // TOTAL TAGIHAN
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(
                    20,
                  ),
                  padding: const EdgeInsets.all(
                    20,
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
                      20,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Total Tagihan",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        formatRupiah.format(
                          totalTagihan,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: tagihanSaya.length,
                    itemBuilder: (
                      context,
                      index,
                    ) {
                      final item = tagihanSaya[index];

                      bool lunas = item["status"] == "Lunas";

                      bool menunggu = item["status"] == "Menunggu Verifikasi";

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
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
                          child: Column(
                            children: [
                              ListTile(
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
                                  "Pemakaian ${item["pemakaian"]} m³",
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
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

                                    // PREVIEW BUKTI
                                    if (item["buktiTransfer"] != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          12,
                                        ),
                                        child: Image.file(
                                          File(
                                            item["buktiTransfer"],
                                          ),
                                          height: 120,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: lunas
                                        ? Colors.green.shade100
                                        : menunggu
                                            ? Colors.orange.shade100
                                            : Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(
                                      12,
                                    ),
                                  ),
                                  child: Text(
                                    item["status"],
                                    style: TextStyle(
                                      color: lunas
                                          ? Colors.green
                                          : menunggu
                                              ? Colors.orange
                                              : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              // TOMBOL BAYAR
                              if (!lunas && !menunggu)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    onPressed: () {
                                      pilihPembayaran(
                                        item,
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.payments,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      "Bayar Sekarang",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
