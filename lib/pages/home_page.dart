import 'package:flutter/material.dart';
import 'package:qurban_sales/pages/history_page.dart';
import 'package:qurban_sales/pages/transaction_type_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text("Rejo Farm"), elevation: 0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo atau judul besar
              const Icon(Icons.mosque, size: 80, color: Color(0xFF1B5E20)),
              const SizedBox(height: 10),
              const Text(
                "Penjualan Hewan Kurban",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 50),

              // Tombol 1
              _buildMenuButton(
                context,
                icon: Icons.add_circle_outline,
                label: "Input Data Baru",
                color: const Color(0xFF1B5E20),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TransactionTypePage(),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              _buildMenuButton(
                context,
                icon: Icons.history_edu,
                label: "History Penjualan",
                color: Colors.orange[800]!,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 80,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 32),
        label: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
