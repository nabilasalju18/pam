import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'main.dart';

class TagihanSayaPage extends StatefulWidget {
  const TagihanSayaPage({super.key});

  @override
  State<TagihanSayaPage> createState() => _TagihanSayaPageState();
}

class _TagihanSayaPageState extends State<TagihanSayaPage> {
  final ImagePicker picker = ImagePicker();

  Future<void> uploadBukti(int index) async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) return;

    setState(() {
      dataTagihan[index]["bukti"] = image.path;
      dataTagihan[index]["status"] = "Menunggu Verifikasi";
    });

    await simpanData();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Bukti pembayaran berhasil diupload",
        ),
      ),
    );
  }

  void pilihPembayaran(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    "Pilih Metode Pembayaran",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ListTile(
                    leading: const Icon(Icons.qr_code),
                    title: const Text("QRIS"),
                    onTap: () {
                      Navigator.pop(context);

                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("QRIS"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.qr_code,
                                size: 150,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Nominal : Rp ${dataTagihan[index]["tagihan"]}",
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const ListTile(
                    leading: Icon(Icons.account_balance_wallet),
                    title: Text("GoPay"),
                    subtitle: Text("081234567890"),
                  ),
                  const ListTile(
                    leading: Icon(Icons.account_balance_wallet),
                    title: Text("OVO"),
                    subtitle: Text("081234567890"),
                  ),
                  const ListTile(
                    leading: Icon(Icons.account_balance_wallet),
                    title: Text("ShopeePay"),
                    subtitle: Text("081234567890"),
                  ),
                  const ListTile(
                    leading: Icon(Icons.account_balance),
                    title: Text("Transfer Bank"),
                    subtitle: Text(
                      "BCA - 1234567890\nA.n PAM Tirta Sejahtera",
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tagihanUser = dataTagihan.where((item) {
      return item["nama"].toString().toLowerCase() == currentUser.toLowerCase();
    }).toList();

    int totalTagihan =
        tagihanUser.where((item) => item["status"] != "Lunas").fold(
              0,
              (sum, item) => sum + ((item["tagihan"] ?? 0) as int),
            );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tagihan Saya"),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                const Text(
                  "Total Tagihan",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Rp $totalTagihan",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: dataTagihan.isEmpty
                ? const Center(
                    child: Text("Belum ada tagihan"),
                  )
                : ListView.builder(
                    itemCount: tagihanUser.length,
                    itemBuilder: (context, index) {
                      final item = tagihanUser[index];

                      String status =
                          item["status"]?.toString() ?? "Belum Bayar";

                      Color warnaStatus = status == "Lunas"
                          ? Colors.green
                          : status == "Menunggu Verifikasi"
                              ? Colors.orange
                              : Colors.red;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["nama"]?.toString() ?? "-",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Periode : ${item["bulan"] ?? "-"}",
                              ),
                              Text(
                                "Pemakaian : ${item["pemakaian"] ?? 0} m³",
                              ),
                              Text(
                                "Tagihan : Rp ${item["tagihan"] ?? 0}",
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: warnaStatus,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  status,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (status != "Lunas")
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.payment),
                                    label: const Text("Bayar"),
                                    onPressed: () {
                                      pilihPembayaran(index);
                                    },
                                  ),
                                ),
                              const SizedBox(height: 8),
                              if (status != "Lunas")
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    icon: const Icon(
                                      Icons.upload_file,
                                    ),
                                    label: const Text(
                                      "Upload Bukti Pembayaran",
                                    ),
                                    onPressed: () {
                                      int indexAsli = dataTagihan.indexOf(item);
                                      uploadBukti(indexAsli);
                                    },
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
