import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pdf_service.dart';

class TagihanPage extends StatefulWidget {
  const TagihanPage({super.key});

  @override
  State<TagihanPage> createState() => _TagihanPageState();
}

class _TagihanPageState extends State<TagihanPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> dataTagihan = [];
  bool isLoading = true;

  final formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    ambilDataTagihan();
  }

  // ==========================
  // AMBIL DATA DARI SUPABASE (JOIN TABLE)
  // ==========================
  Future<void> ambilDataTagihan() async {
    setState(() => isLoading = true);
    try {
      // Mengambil data tagihan sekaligus join ke tabel pelanggan untuk dapat 'nama'
      final response = await supabase
          .from('tagihan')
          .select('*, pelanggan(nama)')
          .order('created_at', ascending: false);

      setState(() {
        dataTagihan = response;
      });
    } catch (e) {
      _showSnackBar("Gagal mengambil data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ==========================
  // VERIFIKASI LUNAS
  // ==========================
  Future<void> verifikasiLunas(int idTagihan, int index) async {
    try {
      await supabase
          .from('tagihan')
          .update({'status': 'Lunas'})
          .eq('id', idTagihan);

      setState(() {
        dataTagihan[index]["status"] = "Lunas";
      });

      _showSnackBar("Pembayaran berhasil diverifikasi");
    } catch (e) {
      _showSnackBar("Gagal memverifikasi: $e");
    }
  }

  // ==========================
  // TOLAK PEMBAYARAN
  // ==========================
  Future<void> tolakPembayaran(int idTagihan, int index) async {
    try {
      await supabase
          .from('tagihan')
          .update({
            'status': 'Belum Bayar',
            'metode': null,
            'bukti_transfer': null,
          })
          .eq('id', idTagihan);

      setState(() {
        dataTagihan[index]["status"] = "Belum Bayar";
        dataTagihan[index]["metode"] = null;
        dataTagihan[index]["bukti_transfer"] = null;
      });

      _showSnackBar("Pembayaran ditolak");
    } catch (e) {
      _showSnackBar("Gagal menolak pembayaran: $e");
    }
  }

  // ==========================
  // LIHAT BUKTI TRANSFER (URL DARI STORAGE)
  // ==========================
  void lihatBukti(String imageUrl) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Gagal memuat gambar atau bukti kosong"),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showSnackBar(String pesan) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F9FF),
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Data Tagihan Pelanggan"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: ambilDataTagihan,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : dataTagihan.isEmpty
              ? const Center(child: Text("Belum ada data tagihan"))
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: dataTagihan.length,
                  itemBuilder: (context, index) {
                    final item = dataTagihan[index];
                    final int idTagihan = item["id"];
                    
                    // Ambil nama dari relasi tabel pelanggan
                    final String namaPelanggan = item["pelanggan"] != null 
                        ? item["pelanggan"]["nama"] 
                        : "Tanpa Nama";

                    bool lunas = item["status"] == "Lunas";
                    bool menunggu = item["status"] == "Menunggu Verifikasi";

                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
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
                                namaPelanggan,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 5),
                                  Text("Pemakaian : ${item["pemakaian"]} m³"),
                                  Text(formatRupiah.format(item["tagihan"])),
                                  Text("Metode : ${item["metode"] ?? "-"}"),
                                  Text("Status : ${item["status"]}"),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
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
                                          nama: namaPelanggan,
                                          pemakaian: item["pemakaian"],
                                          tagihan: item["tagihan"],
                                        );
                                      },
                                      icon: const Icon(Icons.print, color: Colors.white),
                                      label: const Text("Struk", style: TextStyle(color: Colors.white)),
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
                                        lihatBukti(item["bukti_transfer"] ?? "");
                                      },
                                      icon: const Icon(Icons.image, color: Colors.white),
                                      label: const Text("Bukti", style: TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                      onPressed: () => verifikasiLunas(idTagihan, index),
                                      child: const Text("Lunas", style: TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: () => tolakPembayaran(idTagihan, index),
                                      child: const Text("Tolak", style: TextStyle(color: Colors.white)),
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
                                      child: const Text("Belum Bayar", style: TextStyle(color: Colors.white)),
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