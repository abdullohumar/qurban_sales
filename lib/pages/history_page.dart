import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal
import '../db/database_helper.dart';
import '../models/sale.dart';
import 'pdf_preview_page.dart'; // Biar bisa cetak ulang dari history

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<Sale>> _salesList;

  @override
  void initState() {
    super.initState();
    _refreshSalesList();
  }

  // Fungsi untuk mengambil ulang data dari database
  void _refreshSalesList() {
    setState(() {
      _salesList = DatabaseHelper.instance.realAllSales();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Penjualan")),
      body: FutureBuilder<List<Sale>>(
        future: _salesList,
        builder: (context, snapshot) {
          // 1. Loading...
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2. Jika Kosong
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada data penjualan."));
          }

          final sales = snapshot.data!;

          return ListView.builder(
            itemCount: sales.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final sale = sales[index];

              // Format tanggal (contoh: 12 Okt 2024, 14:30)
              final date = DateTime.parse(sale.createdAt);
              final dateString = DateFormat(
                'd MMM yyyy, HH:mm',
                'id_ID',
              ).format(date);
              final currencyFormatter = NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
                decimalDigits: 0,
              );
              final priceString = currencyFormatter.format(sale.price);

              return Dismissible(
                key: Key(sale.id.toString()), // ID unik untuk fitur hapus
                direction:
                    DismissDirection.endToStart, // Geser dari kanan ke kiri
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) => _showDeleteConfirmation(context),
                onDismissed: (direction) async {
                  // Hapus dari database
                  await DatabaseHelper.instance.delete(sale.id!);
                  // Hapus notifikasi
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Data dihapus")),
                    );
                  }
                  // Refresh list
                  _refreshSalesList();
                },
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF1B5E20),
                      child: Text(
                        sale.nomor,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    title: Text(
                      sale.nama,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(dateString),
                        Text(
                          "${sale.type} - $priceString",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showDetailPopup(context, sale),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Pop-up Detail
  void _showDetailPopup(BuildContext context, Sale sale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Detail: ${sale.nama}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _rowDetail("Nomor Nota", sale.nomor),
            _rowDetail("Nama", sale.nama),
            _rowDetail("No HP", sale.noHp),
            _rowDetail("Alamat", sale.alamat),
            const Divider(),
            _rowDetail("Tipe Akad", sale.type),
            _rowDetail(
              "Nominal",
              NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
                decimalDigits: 0,
              ).format(sale.price),
            ),
            const Divider(height: 30),
            // Tombol Cetak Ulang
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Tutup popup dulu
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PdfPreviewPage(sale: sale),
                    ),
                  );
                },
                icon: const Icon(Icons.print),
                label: const Text("Cetak Ulang PDF"),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  Widget _rowDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              "$label:",
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Data?"),
        content: const Text("Data yang dihapus tidak bisa dikembalikan."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }
}
