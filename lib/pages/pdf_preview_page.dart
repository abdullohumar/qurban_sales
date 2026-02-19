import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        pdfFileName: 'Tanda_Terima_${sale.nama.replaceAll(" ", "_")}.pdf',
        pageFormats: const {'A4': PdfPageFormat.a4},
        build: (format) => _generatePdf(format, sale),
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format, Sale sale) async {
    final pdf = pw.Document();
    final String formattedDate = DateFormat(
      'd MMMM yyyy',
      'id_ID',
    ).format(DateTime.now());
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final String priceString = currencyFormatter.format(sale.price);
    final String terbilang = Terbilang.convert(sale.price);

    // Warna Teks Header (Biru Tua sesuai brand image sebelumnya)
    final PdfColor brandColor = PdfColor.fromInt(0xFF1E3A8A);

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        // Margin kita buat agak besar biar terlihat elegan (mirip surat resmi)
        margin: const pw.EdgeInsets.all(50),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // --- 1. HEADER (Kecil & Di Tengah) ---
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      "Rejo Farm",
                      style: pw.TextStyle(
                        color: brandColor,
                        fontSize: 26, // Ukuran pas, tidak terlalu raksasa
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      "Ds. Banjarejo, RT.02, RW.02, Kec. Pakis, Kab. Malang",
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 15),
              pw.Divider(
                thickness: 1,
                color: brandColor,
              ), // Garis pemisah tipis
              pw.SizedBox(height: 30), // Jarak ke judul
              // --- 2. JUDUL ---
              pw.Center(
                child: pw.Text(
                  "TANDA TERIMA PEMBAYARAN",
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline,
                    letterSpacing: 1.5, // Sedikit renggang biar elegan
                  ),
                ),
              ),

              pw.SizedBox(height: 40), // Memberi napas sebelum masuk form
              // --- 3. ISI FORM (Dibuat Berjarak/Tidak Mepet) ---
              pw.Text(
                "Sudah diterima dari:",
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 15), // Jarak antar elemen
              // Input Nama
              _buildFormRow("Nama", sale.nama),
              pw.SizedBox(height: 25), // Jarak LEBIH LEBAR agar clear
              // Input Alamat
              _buildFormRow("Alamat", sale.alamat),
              pw.SizedBox(height: 25), // Jarak LEBIH LEBAR agar clear
              // Input No HP (Opsional, kalau mau ditampilkan)
              _buildFormRow("No. HP", sale.noHp),
              pw.SizedBox(height: 35), // Jarak sebelum masuk nominal
              // --- 4. NOMINAL & KETERANGAN ---
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 10,
                ),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfColors.grey400,
                  ), // Kotak tipis
                  color: PdfColors.grey100, // Background abu sangat muda
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Nominal:",
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Row(
                      children: [
                        pw.Text(
                          "$priceString,-",
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: brandColor,
                          ),
                        ),
                        pw.SizedBox(width: 10),
                        pw.Text(
                          "($terbilang Rupiah)",
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontStyle: pw.FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 25),

              // Text Akad
              pw.Text(
                sale.type == "Bay' Naqdan"
                    ? "Untuk pembayaran tunai (Bay' Naqdan) hewan kurban dengan kriteria domba ${(sale.gender ?? 'Jantan').toLowerCase()} dengan bobot hidup minimal ${sale.weight ?? '35'} kg."
                    : "Untuk pembayaran di muka (Akad Salam) hewan kurban dengan kriteria domba ${(sale.gender ?? 'Jantan').toLowerCase()} dengan bobot hidup minimal 35 kg yang akan disediakan pada tanggal 1 Dzulhijjah 1447 H.",
                style: const pw.TextStyle(
                  fontSize: 12,
                  lineSpacing: 6,
                ), // Spasi antar baris paragraf diperlebar
                textAlign: pw.TextAlign.justify,
              ),

              pw.Spacer(), // Dorong footer ke paling bawah halaman
              // --- 5. FOOTER (Tanda Tangan) ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        "Penerima:",
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        "Malang, $formattedDate",
                        style: const pw.TextStyle(fontSize: 12),
                      ),

                      pw.SizedBox(height: 70), // Ruang Tanda Tangan Luas

                      pw.Text(
                        "Umar Rahman Gunawan",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          decoration: pw.TextDecoration.underline,
                        ),
                      ),
                      pw.Text(
                        "Pemilik Rejo Farm",
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
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

  // Widget Baris Form yang Rapi & Berjarak
  pw.Widget _buildFormRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.SizedBox(
          width: 80,
          child: pw.Text(
            "$label:",
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 2),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(width: 0.5, style: pw.BorderStyle.dashed),
              ), // Garis putus-putus biar estetik
            ),
            child: pw.Text(value, style: pw.TextStyle(fontSize: 13)),
          ),
        ),
      ],
    );
  }
}

class Terbilang {
  static const List<String> _satuan = [
    '',
    'Satu',
    'Dua',
    'Tiga',
    'Empat',
    'Lima',
    'Enam',
    'Tujuh',
    'Delapan',
    'Sembilan',
    'Sepuluh',
    'Sebelas',
  ];

  static String convert(int number) {
    if (number < 12) {
      return _satuan[number];
    } else if (number < 20) {
      return '${convert(number - 10)} Belas';
    } else if (number < 100) {
      return '${convert(number ~/ 10)} Puluh ${convert(number % 10)}';
    } else if (number < 200) {
      return 'Seratus ${convert(number - 100)}';
    } else if (number < 1000) {
      return '${convert(number ~/ 100)} Ratus ${convert(number % 100)}';
    } else if (number < 2000) {
      return 'Seribu ${convert(number - 1000)}';
    } else if (number < 1000000) {
      return '${convert(number ~/ 1000)} Ribu ${convert(number % 1000)}';
    } else if (number < 1000000000) {
      return '${convert(number ~/ 1000000)} Juta ${convert(number % 1000000)}';
    }
    return number.toString();
  }
}
