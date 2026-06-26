import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DataPelangganPage extends StatefulWidget {
  const DataPelangganPage({super.key});

  @override
  State<DataPelangganPage> createState() => _DataPelangganPageState();
}

class _DataPelangganPageState extends State<DataPelangganPage> {
  final supabase = Supabase.instance.client;
  
  final namaController = TextEditingController();
  final alamatController = TextEditingController();
  final meterController = TextEditingController();
  final noHpController = TextEditingController();
  final cariController = TextEditingController();
  
  List<Map<String, dynamic>> listPelanggan = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    muatDataPelanggan();
  }

  // ==========================================
  // QUERY: CARI PELANGGAN LANGSUNG KE SUPABASE
  // ==========================================
  Future<void> cariPelanggan(String keyword) async {
    if (keyword.isEmpty) {
      muatDataPelanggan();
      return;
    }
    
    try {
      final response = await supabase
          .from('pelanggan')
          .select()
          .ilike('nama', '%$keyword%') // Pencarian case-insensitive cloud
          .order('nama', ascending: true);

      setState(() {
        listPelanggan = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint("Gagal mencari data: $e");
    }
  }

  void clearForm() {
    namaController.clear();
    alamatController.clear();
    meterController.clear();
    noHpController.clear();
  }

  Widget inputModern(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ==========================================
  // QUERY: MUAT DATA PELANGGAN
  // ==========================================
  Future<void> muatDataPelanggan() async {
    setState(() => isLoading = true);
    try {
      final response = await supabase
          .from('pelanggan')
          .select()
          .order('nama', ascending: true);

      setState(() {
        listPelanggan = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint("Gagal mengambil data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }
    
  // ==========================================
  // QUERY: TAMBAH PELANGGAN BARU
  // ==========================================
  Future<void> tambahPelanggan() async {
    String nama = namaController.text.trim();
    String alamat = alamatController.text.trim();
    double noMeter = double.tryParse(meterController.text.trim()) ?? 0.0;

    if (nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama pelanggan wajib diisi!")),
      );
      return;
    }

    try {
      await supabase.from('pelanggan').insert({
        'nama': nama,
        'alamat': alamat,
        'no_meter': noMeter, // Pastikan nama kolom sesuai struktur tabel Supabase-mu
      });

      if (mounted) Navigator.pop(context); // Tutup dialog form tambah
      clearForm();
      muatDataPelanggan(); // Refresh list data
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pelanggan berhasil ditambahkan!")),
        );
      }
    } catch (e) {
      debugPrint("Gagal menambah data: $e");
    }
  }

  // ==========================================
  // QUERY: HAPUS PELANGGAN
  // ==========================================
  Future<void> hapusPelanggan(int id) async {
    try {
      await supabase.from('pelanggan').delete().eq('id', id);
      muatDataPelanggan(); 
    } catch (e) {
      debugPrint("Gagal menghapus: $e");
    }
  }

  // ==========================================
  // QUERY: UPDATE / EDIT DATA PELANGGAN
  // ==========================================
  void editPelanggan(int index) {
    final pelangganLama = listPelanggan[index];
    int idPelanggan = pelangganLama["id"];

    namaController.text = pelangganLama["nama"] ?? '';
    alamatController.text = pelangganLama["alamat"] ?? '';
    meterController.text = (pelangganLama["no_meter"] ?? '').toString();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: const Text("Edit Pelanggan"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                inputModern(namaController, "Nama", Icons.person),
                const SizedBox(height: 15),
                inputModern(alamatController, "Alamat", Icons.home),
                const SizedBox(height: 15),
                inputModern(meterController, "No Meter", Icons.water_drop, keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                try {
                  // Kirim perintah UPDATE ke Supabase
                  await supabase.from('pelanggan').update({
                    "nama": namaController.text.trim(),
                    "alamat": alamatController.text.trim(),
                    "no_meter": double.tryParse(meterController.text.trim()) ?? 0.0,
                  }).eq('id', idPelanggan);

                  if (mounted) Navigator.pop(context); // Tutup dialog
                  clearForm();
                  muatDataPelanggan(); // Reload data terbaru
                } catch (e) {
                  debugPrint("Gagal mengupdate data: $e");
                }
              },
              child: const Text("Simpan"),
            )
          ],
        );
      },
    );
  }

  void formTambah() {
    clearForm();
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: const Text("Tambah Pelanggan"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                inputModern(namaController, "Nama", Icons.person),
                const SizedBox(height: 15),
                inputModern(alamatController, "Alamat", Icons.home),
                const SizedBox(height: 15),
                inputModern(meterController, "No Meter", Icons.water_drop, keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: tambahPelanggan,
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F9FF),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
          "Data Pelanggan",
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: cariController,
              onChanged: cariPelanggan,
              decoration: InputDecoration(
                hintText: "Cari pelanggan...",
                prefixIcon: const Icon(
                  Icons.search,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    20,
                  ),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: listPelanggan.isEmpty
                ? const Center(
                    child: Text(
                      "Belum ada pelanggan",
                    ),
                  )
                : ListView.builder(
                    itemCount: listPelanggan.length,
                    itemBuilder: (
                      context,
                      index,
                    ) {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            20,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(
                            15,
                          ),
                          leading: const CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.orange,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            listPelanggan[index]["nama"],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            "${listPelanggan[index]["alamat"]}\nMeter : ${listPelanggan[index]["no_meter"]}",
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  editPelanggan(
                                    index,
                                  );
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  hapusPelanggan(
                                    index,
                                  );
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: formTambah,
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}
