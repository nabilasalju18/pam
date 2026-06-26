import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TagihanSayaPage extends StatefulWidget {
  const TagihanSayaPage({super.key});

  @override
  State<TagihanSayaPage> createState() => _TagihanSayaPageState();
}

class _TagihanSayaPageState extends State<TagihanSayaPage> {
  final supabase = Supabase.instance.client;
  final ImagePicker picker = ImagePicker();
  
  List<Map<String, dynamic>> dataTagihan = [];
  bool isLoading = true;

  // Format rupiah agar tampilan rapi
  final formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  // Gantilah ID ini sesuai dengan ID Pelanggan yang sedang login di aplikasi kamu
  final int currentPelangganId = 3; 

  // Konstanta tarif per m³ karena di tabel Supabase Anda baru ada kolom 'pemakaian'
  final int tarifPerMeter = 3000;

  @override
  void initState() {
    super.initState();
    ambilTagihanSaya();
  }

  // ==========================================
  // AMBIL DATA TAGIHAN USER DARI SUPABASE
  // ==========================================
  Future<void> ambilTagihanSaya() async {
    setState(() => isLoading = true);
    try {
      final response = await supabase
          .from('tagihan')
          .select('*, pelanggan(nama)')
          .eq('pelanggan_id', currentPelangganId)
          .order('id', ascending: false);

      setState(() {
        dataTagihan = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      _showSnackBar("Gagal memuat tagihan: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ==========================================
  // UPLOAD BUKTI TRANSFER KE SUPABASE STORAGE
  // ==========================================
  Future<void> uploadBukti(int idTagihan, int index, String metode) async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    _showSnackBar("Sedang mengunggah bukti pembayaran...");

    try {
      final file = File(image.path);
      final String fileName = 'bukti_${idTagihan}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // 1. Upload file gambar ke bucket bernama 'bukti_transfer' di Supabase Storage
      await supabase.storage.from('bukti_transfer').upload(fileName, file);

      // 2. Dapatkan URL Publik dari gambar yang baru saja diupload
      final String imageUrl = supabase.storage.from('bukti_transfer').getPublicUrl(fileName);

      // 3. Update data status, metode, dan bukti_transfer di tabel tagihan database
      await supabase.from('tagihan').update({
        'status': 'Menunggu Verifikasi',
        'metode': metode,
        'bukti_transfer': imageUrl,
      }).eq('id', idTagihan);

      setState(() {
        dataTagihan[index]['status'] = 'Menunggu Verifikasi';
        dataTagihan[index]['metode'] = metode;
        dataTagihan[index]['bukti_transfer'] = imageUrl;
      });

      _showSnackBar("Bukti pembayaran berhasil dikirim. Menunggu verifikasi admin.");
    } catch (e) {
      _showSnackBar("Gagal mengunggah bukti: $e");
    }
  }

  void pilihPembayaran(int idTagihan, int index, int totalBayar) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Pilih Metode Pembayaran",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  ListTile(
                    leading: const Icon(Icons.qr_code),
                    title: const Text("QRIS"),
                    subtitle: const Text("Scan barcode otomatis"),
                    onTap: () {
                      Navigator.pop(context);
                      _tampilkanQris(idTagihan, index, totalBayar);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.account_balance),
                    title: const Text("Transfer Bank BCA"),
                    subtitle: const Text("1234567890 a.n PAM Tirta Sejahtera"),
                    onTap: () {
                      Navigator.pop(context);
                      uploadBukti(idTagihan, index, "Transfer BCA");
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _tampilkanQris(int idTagihan, int index, int totalBayar) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("QRIS Pembayaran", textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code_2, size: 180, color: Colors.black87),
            const SizedBox(height: 10),
            Text(
              "Total: ${formatRupiah.format(totalBayar)}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                uploadBukti(idTagihan, index, "QRIS");
              },
              icon: const Icon(Icons.upload_file),
              label: const Text("Sudah Bayar? Upload Bukti"),
            )
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String pesan) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Menghitung total tagihan yang Belum Lunas
    int totalTagihanBelumLunas = dataTagihan
        .where((item) => item["status"] != "Lunas")
        .fold(0, (sum, item) {
          int pemakaian = item["pemakaian"] ?? 0;
          return sum + (pemakaian * tarifPerMeter);
        });

    return Scaffold(
      backgroundColor: const Color(0xffF5F9FF),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text("Tagihan Saya"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: ambilTagihanSaya,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Total Tagihan Belum Lunas",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatRupiah.format(totalTagihanBelumLunas),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: dataTagihan.isEmpty
                      ? const Center(child: Text("Belum ada riwayat tagihan"))
                      : ListView.builder(
                          itemCount: dataTagihan.length,
                          itemBuilder: (context, index) {
                            final item = dataTagihan[index];
                            final int idTagihan = item["id"];
                            final int pemakaian = item["pemakaian"] ?? 0;
                            
                            // Kalkulasi nominal rupiah
                            final int totalBayar = pemakaian * tarifPerMeter;

                            String status = item["status"] ?? "Belum Bayar";
                            Color warnaStatus = status == "Lunas"
                                ? Colors.green
                                : status == "Menunggu Verifikasi"
                                    ? Colors.orange
                                    : Colors.red;

                            final String namaPelanggan = item["pelanggan"] != null
                                ? item["pelanggan"]["nama"]
                                : "Pelanggan";

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          namaPelanggan,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: warnaStatus,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            status,
                                            style: const TextStyle(color: Colors.white, fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 20),
                                    Text("Nomor Invoice : #$idTagihan"),
                                    Text("Pemakaian Air : $pemakaian m³"),
                                    Text(
                                      "Total Biaya : ${formatRupiah.format(totalBayar)}",
                                      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blue),
                                    ),
                                    if (item["metode"] != null) Text("Metode : ${item["metode"]}"),
                                    if (status == "Belum Bayar") ...[
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.payment),
                                          label: const Text("Pilih Metode & Bayar"),
                                          onPressed: () => pilihPembayaran(idTagihan, index, totalBayar),
                                        ),
                                      ),
                                    ],
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