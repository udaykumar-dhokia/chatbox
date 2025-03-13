import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class PdfHelper {
  Future<void> saveChatToPdf(
    String chatTitle,
    List<Map<String, dynamic>> messages,
  ) async {
    final pdf = pw.Document();
    final logo =
        (await rootBundle.load('lib/assets/chatbox.png')).buffer.asUint8List();

    final font = pw.Font.ttf(
      await rootBundle.load(
        'lib/assets/fonts/Noto_Sans/NotoSans-VariableFont_wdth,wght.ttf',
      ),
    );
    final boldFont = pw.Font.ttf(
      await rootBundle.load(
        'lib/assets/fonts/Noto_Sans/NotoSans-Italic-VariableFont_wdth,wght.ttf',
      ),
    );

    const int maxMessagesPerPage = 40;
    int currentPage = 0;

    while (currentPage * maxMessagesPerPage < messages.length) {
      final pageMessages =
          messages
              .skip(currentPage * maxMessagesPerPage)
              .take(maxMessagesPerPage)
              .toList();

      pdf.addPage(
        pw.MultiPage(
          theme: pw.ThemeData.withFont(base: font, bold: boldFont),
          build: (pw.Context context) {
            return [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Image(pw.MemoryImage(logo), width: 40, height: 40),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    chatTitle,
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  ...pageMessages.map((msg) {
                    final role = msg['sender'] ?? 'Unknown';
                    return pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '$role:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(msg['message'] ?? ''),
                        pw.SizedBox(height: 10),
                      ],
                    );
                  }),
                ],
              ),
            ];
          },
        ),
      );

      currentPage++;
    }

    final output = await getDownloadsDirectory();
    print(output);
    final file = File('${output!.path}/$chatTitle.pdf');
    await file.writeAsBytes(await pdf.save());
  }
}
