import 'package:flutter/material.dart';
import 'main.dart';

class DataPelangganPage extends StatefulWidget {
  const DataPelangganPage({
    super.key,
  });

  @override
  State<DataPelangganPage> createState() => _DataPelangganPageState();
}

class _DataPelangganPageState extends State<DataPelangganPage> {
  final namaController = TextEditingController();

  final alamatController = TextEditingController();

  final meterController = TextEditingController();

  final cariController = TextEditingController();

  List<Map<String, dynamic>> hasilPencarian = [];

  @override
  void initState() {
    super.initState();
    hasilPencarian = List.from(dataPelanggan);
  }

  void cariPelanggan(String keyword) {
    setState(() {
      hasilPencarian = dataPelanggan.where(
        (pelanggan) {
          return pelanggan["nama"].toString().toLowerCase().contains(
                keyword.toLowerCase(),
              );
        },
      ).toList();
    });
  }

  void clearForm() {
    namaController.clear();
    alamatController.clear();
    meterController.clear();
  }

  Widget inputModern(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            18,
          ),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> tambahPelanggan() async {
    if (namaController.text.isEmpty ||
        alamatController.text.isEmpty ||
        meterController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            "Semua data wajib diisi",
          ),
        ),
      );
      return;
    }

    setState(() {
      dataPelanggan.add({
        "nama": namaController.text,
        "alamat": alamatController.text,
        "meter": meterController.text,
      });

      hasilPencarian = List.from(
        dataPelanggan,
      );
    });

    await simpanData();

    clearForm();

    Navigator.pop(context);
  }

  Future<void> hapusPelanggan(
    int index,
  ) async {
    dataPelanggan.remove(
      hasilPencarian[index],
    );

    hasilPencarian = List.from(
      dataPelanggan,
    );

    await simpanData();

    setState(() {});
  }

  void editPelanggan(int index) {
    namaController.text = hasilPencarian[index]["nama"];

    alamatController.text = hasilPencarian[index]["alamat"];

    meterController.text = hasilPencarian[index]["meter"];

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              25,
            ),
          ),
          title: const Text(
            "Edit Pelanggan",
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                inputModern(
                  namaController,
                  "Nama",
                  Icons.person,
                ),
                const SizedBox(height: 15),
                inputModern(
                  alamatController,
                  "Alamat",
                  Icons.home,
                ),
                const SizedBox(height: 15),
                inputModern(
                  meterController,
                  "No Meter",
                  Icons.water_drop,
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  hasilPencarian[index] = {
                    "nama": namaController.text,
                    "alamat": alamatController.text,
                    "meter": meterController.text,
                  };
                });

                await simpanData();

                Navigator.pop(context);

                clearForm();
              },
              child: const Text(
                "Simpan",
              ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              25,
            ),
          ),
          title: const Text(
            "Tambah Pelanggan",
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                inputModern(
                  namaController,
                  "Nama",
                  Icons.person,
                ),
                const SizedBox(height: 15),
                inputModern(
                  alamatController,
                  "Alamat",
                  Icons.home,
                ),
                const SizedBox(height: 15),
                inputModern(
                  meterController,
                  "No Meter",
                  Icons.water_drop,
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: tambahPelanggan,
              child: const Text(
                "Simpan",
              ),
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
            child: hasilPencarian.isEmpty
                ? const Center(
                    child: Text(
                      "Belum ada pelanggan",
                    ),
                  )
                : ListView.builder(
                    itemCount: hasilPencarian.length,
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
                            hasilPencarian[index]["nama"],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            "${hasilPencarian[index]["alamat"]}\nMeter : ${hasilPencarian[index]["meter"]}",
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
