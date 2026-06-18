import 'package:flutter/material.dart';
import 'main.dart';

class InputMeteranPage extends StatefulWidget {
  const InputMeteranPage({
    super.key,
  });

  @override
  State<InputMeteranPage> createState() => _InputMeteranPageState();
}

class _InputMeteranPageState extends State<InputMeteranPage> {
  String? selectedPelanggan;

  final cariController = TextEditingController();

  final meterLamaController = TextEditingController();

  final meterBaruController = TextEditingController();

  List<Map<String, dynamic>> hasilCari = [];

  int pemakaian = 0;
  int totalTagihan = 0;

  final int tarifAir = 2000;

  @override
  void initState() {
    super.initState();

    hasilCari = List.from(dataPelanggan);
  }

  // ===================
  // SEARCH PELANGGAN
  // ===================
  void cariPelanggan(
    String keyword,
  ) {
    setState(() {
      hasilCari = dataPelanggan.where(
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
    int meterLama = int.tryParse(
          meterLamaController.text,
        ) ??
        0;

    int meterBaru = int.tryParse(
          meterBaruController.text,
        ) ??
        0;

    // VALIDASI
    if (selectedPelanggan == null || meterBaruController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            "Pilih pelanggan dan isi meter sekarang",
          ),
        ),
      );
      return;
    }

    // VALIDASI METER
    if (meterBaru < meterLama) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            "Meter sekarang tidak boleh lebih kecil dari meter sebelumnya",
          ),
        ),
      );
      return;
    }

    // HITUNG
    int hasilPemakaian = meterBaru - meterLama;

    int hasilTagihan = hasilPemakaian * tarifAir;

    setState(() {
      pemakaian = hasilPemakaian;

      totalTagihan = hasilTagihan;
    });

    // CEGAH DUPLIKAT
    bool sudahAda = dataTagihan.any(
      (item) =>
          item["nama"] == selectedPelanggan && item["status"] == "Belum Bayar",
    );

    if (sudahAda) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            "Pelanggan masih punya tagihan",
          ),
        ),
      );
      return;
    }

    // UPDATE METER PELANGGAN
    int indexPelanggan = dataPelanggan.indexWhere(
      (item) => item["nama"] == selectedPelanggan,
    );

    if (indexPelanggan != -1) {
      dataPelanggan[indexPelanggan]["meter"] = meterBaru.toString();
    }

    // SIMPAN TAGIHAN
    dataTagihan.add({
      "nama": selectedPelanggan,
      "pemakaian": hasilPemakaian,
      "tagihan": hasilTagihan,
      "status": "Belum Bayar",
      "meterLama": meterLama,
      "meterBaru": meterBaru,
    });

    await simpanData();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      const SnackBar(
        content: Text(
          "Tagihan berhasil dibuat",
        ),
      ),
    );

    meterBaruController.clear();

    cariController.clear();

    setState(() {
      selectedPelanggan = null;
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
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
            DropdownButtonFormField<String>(
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
              items: hasilCari.map(
                (
                  pelanggan,
                ) {
                  return DropdownMenuItem<String>(
                    value: pelanggan["nama"],
                    child: Text(
                      "${pelanggan["nama"]} - Meter ${pelanggan["meter"]}",
                    ),
                  );
                },
              ).toList(),

              // AUTO METER
              onChanged: (value) {
                setState(() {
                  selectedPelanggan = value;

                  var pelanggan = dataPelanggan.firstWhere(
                    (item) => item["nama"] == value,
                  );

                  meterLamaController.text = pelanggan["meter"].toString();
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
                labelText: "Meter Bulan Lalu",
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
