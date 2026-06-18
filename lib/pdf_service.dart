import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfService {
  static Future<void> cetakStruk({
    required String nama,
    required int pemakaian,
    required int tagihan,
  }) async {
    final pdf = pw.Document();

    final rupiah = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          80 * PdfPageFormat.mm,
          150 * PdfPageFormat.mm,
        ),
        build: (
          context,
        ) {
          return pw.Column(
            children: [
              pw.Text(
                "STRUK PAM",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(
                height: 20,
              ),
              pw.Text(
                "Nama : $nama",
              ),
              pw.Text(
                "Pemakaian : $pemakaian m³",
              ),
              pw.Text(
                "Tagihan : ${rupiah.format(tagihan)}",
              ),
              pw.Divider(),
              pw.Text(
                "Status : LUNAS",
              ),
              pw.SizedBox(
                height: 20,
              ),
              pw.Text(
                "Terima kasih",
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (
        format,
      ) async =>
          pdf.save(),
    );
  }
}
