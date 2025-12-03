import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk memuat font jika perlu
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/sale.dart';

class PdfPreviewPage extends StatelessWidget {
  final Sale sale;

  const PdfPreviewPage({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Preview Tanda Terima")),
      body: PdfPreview(
        // Nama file saat di-share
        pdfFileName: 'Tanda_Terima_${sale.nama.replaceAll(" ", "_")}.pdf',
        // Kertas A4
        pageFormats: const {'A4': PdfPageFormat.a4},
        build: (format) => _generatePdf(format, sale),
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format, Sale sale) async {
    final pdf = pw.Document();

    // Format Tanggal Hari Ini (Indonesia)
    final String formattedDate = DateFormat('d MMMM yyyy', 'id_ID').format(DateTime.now());

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(40), // Margin pinggir kertas
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // --- HEADER (KOP SURAT) ---
              pw.Center(
                child: pw.Text("Rejo Farm",
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Center(
                child: pw.Text("Ds. Banjarejo, RT.02, RW.02, Kec. Pakis, Kab. Malang",
                    style: const pw.TextStyle(fontSize: 12), textAlign: pw.TextAlign.center),
              ),
              pw.SizedBox(height: 20),
              pw.Divider(thickness: 2), // Garis pemisah
              pw.SizedBox(height: 20),

              // --- JUDUL ---
              pw.Center(
                child: pw.Text("TANDA TERIMA PEMBAYARAN",
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
              ),
              pw.SizedBox(height: 30),

              // --- KONTEN UTAMA ---
              pw.Text("Sudah diterima dari:", style: const pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 8),
              
              _buildRow("Nama", ": ${sale.nama}"),
              _buildRow("Alamat", ": ${sale.alamat}"),
              _buildRow("No. HP", ": ${sale.noHp}"), // Tambahan biar lengkap
              
              pw.SizedBox(height: 20),
              
              pw.Text("Sejumlah uang dengan nominal:", style: const pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 5),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                  color: PdfColors.grey100,
                ),
                child: pw.Text(
                  "Rp 2.500.000,- (Dua Juta Lima Ratus Ribu Rupiah)", 
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)
                ),
              ),

              pw.SizedBox(height: 20),
              
              pw.Text(
                "Untuk pembayaran di muka (Akad Salam) hewan kurban dengan kriteria domba jantan dengan bobot hidup 35 kg yang akan disediakan pada tanggal 1 Dzulhijjah 1447 H.",
                style: const pw.TextStyle(fontSize: 12, lineSpacing: 5),
                textAlign: pw.TextAlign.justify
              ),

              pw.SizedBox(height: 50),

              // --- FOOTER (Tanda Tangan) ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text("Penerima: Umar Rahman Gunawan (Pemilik Rejo Farm)", style: const pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 5),
                      pw.Text("Malang, $formattedDate", style: const pw.TextStyle(fontSize: 12)),
                      pw.SizedBox(height: 70), // Ruang tanda tangan
                      pw.Text("Umar Rahman Gunawan", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, decoration: pw.TextDecoration.underline)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // Helper untuk membuat baris titik dua rapi
  pw.Widget _buildRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: 80, child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }
}