import 'package:flutter/material.dart';
import 'package:qurban_sales/db/database_helper.dart';
import 'package:qurban_sales/models/sale.dart';
import 'package:qurban_sales/pages/pdf_preview_page.dart';

class InputPage extends StatefulWidget {
  final String transactionType;
  const InputPage({super.key, required this.transactionType});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final _formKey = GlobalKey<FormState>();

  // Controller untuk mengambil teks inputan
  final _nomorController = TextEditingController();
  final _namaController = TextEditingController();
  final _hpController = TextEditingController();
  final _alamatController = TextEditingController();
  final _hargaController = TextEditingController(
    text: "2500000",
  ); // Default price
  final _weightController = TextEditingController(); // Controller for weight
  String? _selectedGender = 'Jantan'; // Default gender

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Input Data Pembeli")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField("Nomor", _nomorController, TextInputType.number),
              _buildTextField(
                "Nama Pembeli",
                _namaController,
                TextInputType.name,
              ),
              _buildTextField("Nomor HP", _hpController, TextInputType.phone),
              _buildTextField(
                "Harga (Rp)",
                _hargaController,
                TextInputType.number,
              ),
              _buildTextField(
                "Alamat",
                _alamatController,
                TextInputType.multiline,
                maxLines: 3,
              ),

              _buildDropdownGender(),

              const SizedBox(height: 15),

              if (widget.transactionType == "Bay' Naqdan")
                _buildTextField(
                  "Bobot Hewan (Kg)",
                  _weightController,
                  TextInputType.number,
                ),

              const SizedBox(height: 30),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _onFinishPressed,
                  child: const Text(
                    "Selesai",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper untuk membuat Text Field biar kodenya rapi
  Widget _buildTextField(
    String label,
    TextEditingController controller,
    TextInputType type, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.edit, color: Color(0xFF1B5E20)),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Harap diisi' : null,
      ),
    );
  }

  Widget _buildDropdownGender() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        decoration: const InputDecoration(
          labelText: "Jenis Kelamin Hewan",
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.pets, color: Color(0xFF1B5E20)),
        ),
        items: ['Jantan', 'Betina'].map((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _selectedGender = newValue;
          });
        },
        validator: (value) =>
            value == null ? 'Harap pilih jenis kelamin' : null,
      ),
    );
  }

  void _onFinishPressed() {
    if (_formKey.currentState!.validate()) {
      // Tampilkan Pop Up Pilihan
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Data Lengkap"),
          content: const Text("Pilih tindakan selanjutnya"),
          actions: [
            TextButton(
              onPressed: () => _saveData(cetak: false),
              child: const Text("SIMPAN SAJA"),
            ),
            ElevatedButton(
              onPressed: () => _saveData(cetak: true),
              child: const Text("CETAK & SIMPAN"),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _saveData({required bool cetak}) async {
    try {
      // 1. Buat object Sale
      final sale = Sale(
        nomor: _nomorController.text,
        nama: _namaController.text,
        noHp: _hpController.text,
        alamat: _alamatController.text,
        createdAt: DateTime.now().toString(),
        type: widget.transactionType,
        price: int.parse(
          _hargaController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ), // Remove non-numeric chars
        weight: _weightController.text.isNotEmpty
            ? _weightController.text
            : null,
        gender: _selectedGender,
      );

      // Simpan ke Database
      await DatabaseHelper.instance.create(sale);

      if (!mounted) return;

      // Navigasi
      Navigator.pop(context); // Tutup dialog

      if (cetak) {
        // Jika cetak, arahkan ke halaman PDF
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PdfPreviewPage(sale: sale)),
        );
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Data berhasil disimpan")));
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        Navigator.pop(context); // Tutup dialog jika masih terbuka
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal menyimpan data: $e")));
      }
    }
  }
}
