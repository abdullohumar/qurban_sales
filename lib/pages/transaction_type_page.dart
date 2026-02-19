import 'package:flutter/material.dart';
import 'package:qurban_sales/pages/input_page.dart';

class TransactionTypePage extends StatelessWidget {
  const TransactionTypePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pilih Jenis Akad")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTypeButton(
              context,
              title: "Akad Salam",
              subtitle: "Pembayaran di muka, barang dikirim nanti.",
              color: const Color(0xFF1B5E20),
              type: "Akad Salam",
            ),
            const SizedBox(height: 20),
            _buildTypeButton(
              context,
              title: "Bay' Naqdan",
              subtitle: "Pembayaran tunai, serah terima langsung.",
              color: Colors.blue[800]!,
              type: "Bay' Naqdan",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
    required String type,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 100,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () {
          // Navigate to InputPage with the selected type
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InputPage(transactionType: type),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
