import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../core/models/khatim.dart';

/// Export du Khatim en PDF et partage texte/fichier.
class ExportService {
  ExportService._();

  /// Construit un document PDF représentant le Khatim.
  static Future<Uint8List> buildPdf(Khatim khatim) async {
    final doc = pw.Document();
    final n = khatim.order;

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Khatim — ${khatim.dimension.frenchName} (${khatim.dimension.size})',
                style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Text('Planète : ${khatim.dimension.planet}   •   '
                  'PM : ${khatim.pm}   •   Méthode : ${khatim.method.labelFr}'),
              pw.SizedBox(height: 16),
              pw.Center(
                child: pw.Table(
                  border: pw.TableBorder.all(width: 1),
                  defaultColumnWidth: const pw.FixedColumnWidth(48),
                  children: [
                    for (var r = 0; r < n; r++)
                      pw.TableRow(
                        children: [
                          for (var c = 0; c < n; c++)
                            pw.Container(
                              alignment: pw.Alignment.center,
                              padding: const pw.EdgeInsets.all(6),
                              child: pw.Text('${khatim.grid[r][c]}'),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Caractéristiques',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(width: 0.5),
                children: [
                  for (final item in khatim.characteristics.asList())
                    pw.TableRow(children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('${item.label} (${item.arabic})'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('${item.value}'),
                      ),
                    ]),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Text('Esprits-servants',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              for (final s in khatim.spiritPairs)
                pw.Bullet(
                  text: '${s.sourceLabel} (${s.sourceValue}) — '
                      'céleste: ${s.celestial.transliteration} / '
                      'terrestre: ${s.terrestrial.transliteration}',
                ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Généré par Ciini Kaarey — outil éducatif.',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  /// Ouvre la boîte de dialogue d'impression / export PDF.
  static Future<void> printPdf(Khatim khatim) async {
    final bytes = await buildPdf(khatim);
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  /// Résumé textuel du Khatim pour le partage.
  static String buildTextSummary(Khatim khatim) {
    final b = StringBuffer()
      ..writeln('Khatim ${khatim.dimension.frenchName} (${khatim.dimension.size})')
      ..writeln('PM : ${khatim.pm} — Méthode : ${khatim.method.labelFr}')
      ..writeln('');
    for (final row in khatim.grid) {
      b.writeln(row.map((v) => v.toString().padLeft(4)).join(' '));
    }
    b.writeln('');
    for (final item in khatim.characteristics.asList()) {
      b.writeln('${item.label} (${item.arabic}) : ${item.value}');
    }
    return b.toString();
  }

  static Future<void> shareText(Khatim khatim) async {
    await Share.share(buildTextSummary(khatim), subject: 'Khatim généré');
  }

  static Future<void> sharePdf(Khatim khatim) async {
    final bytes = await buildPdf(khatim);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'khatim_${khatim.dimension.size}_${khatim.pm}.pdf',
    );
  }
}
