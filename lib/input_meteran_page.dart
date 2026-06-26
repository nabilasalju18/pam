import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InputMeteranPage extends StatefulWidget {
  const InputMeteranPage({super.key});

  @override
  State<InputMeteranPage> createState() => _InputMeteranPageState();
}

class _InputMeteranPageState extends State<InputMeteranPage> {
  final supabase = Supabase.instance.client;

  int? selectedPelanggan;
  final cariController = TextEditingController();
  final meterLamaController = TextEditingController();
  final meterBaruController = TextEditingController();

  List<Map<String, dynamic>> semuaPelanggan = [];
  List<Map<String, dynamic>> hasilCari = [];

  int pemakaian = 0;
  int totalTagihan = 0;
  final int tarifAir = 2000;
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    ambilDataPelanggan();
  }

  // ==========================================
  // QUERY: AMBIL DATA PELANGGAN DARI SUPABASE
  // ==========================================
  Future<void> ambilDataPelanggan() async {
    try {
      final response = await supabase
          .from('pelanggan')
          .select()
          .order('nama', ascending: true);

      setState(() {
        semuaPelanggan = List<Map<String, dynamic>>.from(response);
        hasilCari = semuaPelanggan;
      });
    } catch (e) {
      debugPrint("Gagal mengambil data pelanggan: $e");
    }
  }

  // ===================
  // SEARCH PELANGGAN
  // ===================
  void cariPelanggan(
    String keyword,
  ) {
    setState(() {
      hasilCari = semuaPelanggan.where(
        (pelanggan) {
          return pelanggan["nama"].toString().toLowerCase().contains(
                keyword.toLowerCase(),
              );
        },
      ).toList();
    });
  }

  // ===================
  // HITUNG TAGIHAN
  // ===================
Future<void> hitungTagihan() async {
  int meterLama = int.tryParse(meterLamaController.text) ?? 0;
  int meterBaru = int.tryParse(meterBaruController.text) ?? 0;

  if (selectedPelanggan == null || meterBaruController.text.isEmpty) {
    _showSnackBar("Pilih pelanggan dan isi meter sekarang");
    return;
  }

  if (meterBaru < meterLama) {
    _showSnackBar("Meter sekarang tidak boleh lebih kecil dari meter sebelumnya");
    return;
  }

  setState(() => isLoading = true);

  try {
    final dataUser = semuaPelanggan.firstWhere((item) => item["id"] == selectedPelanggan);
    
    // 1. CEK TUNGGAKAN
    final cekTagihan = await supabase
        .from('tagihan')
        .select()
        .eq('pelanggan_id', selectedPelanggan!)
        .eq('status', 'Belum Bayar')
        .maybeSingle();

    if (cekTagihan != null) {
      _showSnackBar("Pelanggan masih memiliki tagihan yang Belum Bayar!");
      setState(() => isLoading = false);
      return;
    }

    int hasilPemakaian = meterBaru - meterLama;
    int hasilTagihan = hasilPemakaian * tarifAir;

    // 2. SIMPAN KE TABEL METERAN (Gunakan maybeSingle untuk mencegah crash null)
    final meteranResponse = await supabase.from('meteran').insert({
      "pelanggan_id": selectedPelanggan, 
      "meter_lama": meterLama,
      "meter_baru": meterBaru,
      "pemakaian": hasilPemakaian, // Sekarang aman karena tipe di DB sudah numeric
    }).select().maybeSingle();

    // Validasi pencegahan error 'method [] called on null'
    if (meteranResponse == null || meteranResponse['id'] == null) {
      _showSnackBar("Gagal mengonfirmasi penyimpanan data meteran.");
      setState(() => isLoading = false);
      return;
    }

    final int baruMeteranId = meteranResponse['id'];

    // 3. SIMPAN KE TABEL TAGIHAN
    await supabase.from('tagihan').insert({
      "pelanggan_id": selectedPelanggan, 
      "meteran_id": baruMeteranId, 
      "pemakaian": hasilPemakaian,
      "tagihan": hasilTagihan,
      "status": "Belum Bayar",
    });

    // 4. UPDATE NO METER PELANGGAN
    await supabase.from('pelanggan').update({
      "no_meter": meterBaru,
    }).eq('id', dataUser['id']);

    setState(() {
      pemakaian = hasilPemakaian;
      totalTagihan = hasilTagihan;
    });

    _showSnackBar("Tagihan dan riwayat meteran berhasil dibuat ke database");

    meterBaruController.clear();
    cariController.clear();
    setState(() {
      selectedPelanggan = null;
      meterLamaController.clear();
    });

    ambilDataPelanggan();

  } catch (e) {
    _showSnackBar("Terjadi kesalahan database: $e");
  } finally {
    setState(() => isLoading = false);
  }
}
  void _showSnackBar(String pesan) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xffF5F9FF,
      ),
      appBar: AppBar(
        title: const Text(
          "Input Meteran",
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
          20,
        ),
        child: Column(
          children: [
            // SEARCH
            TextField(
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
                    18,
                  ),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // DROPDOWN
            DropdownButtonFormField<int>(
              value: selectedPelanggan,
              decoration: InputDecoration(
                labelText: "Pilih Pelanggan",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    18,
                  ),
                  borderSide: BorderSide.none,
                ),
              ),
              items: hasilCari.map((pelanggan) {
                  return DropdownMenuItem<int>(
                    value: pelanggan["id"], // VALUE SEKARANG ADALAH ID (int)
                    child: Text(
                      "${pelanggan["nama"]} - Meter: ${pelanggan["no_meter"] ?? 0}",
                    ),
                  );
                }).toList(),

              // AUTO METER
              onChanged: (value) {
                setState(() {
                  selectedPelanggan = value;

                  var pelanggan = semuaPelanggan.firstWhere(
                    (item) => item["id"] == value,
                    orElse: () => {},
                  );

                  if (pelanggan.isNotEmpty) {
                    meterLamaController.text = (pelanggan["no_meter"] ?? 0).toString();
                  } else {
                    meterLamaController.text = "0";
                  }
                });
              },
            ),

            const SizedBox(
              height: 20,
            ),

            // METER OTOMATIS
            TextField(
              controller: meterLamaController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "No Meter Sebelumnya",
                prefixIcon: const Icon(
                  Icons.speed,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    18,
                  ),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // INPUT METER SEKARANG
            TextField(
              controller: meterBaruController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Meter Sekarang",
                prefixIcon: const Icon(
                  Icons.water_drop,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    18,
                  ),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            // BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      18,
                    ),
                  ),
                ),
                onPressed: hitungTagihan,
                child: const Text(
                  "HITUNG TAGIHAN",
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

            // HASIL
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  20,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      "Pemakaian Air",
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "$pemakaian m³",
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const Divider(),
                    const Text(
                      "Total Tagihan",
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Rp $totalTagihan",
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
