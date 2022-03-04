import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:xapptor_ui/widgets/url_text.dart';
import 'course_certificate.dart';
import 'package:printing/printing.dart';

Future<Uint8List> generate_pdf_certificate({
  required CourseCertificate certificate,
  required String institution_name,
  required String location,
  required String website,
  required String logo_image_path,
  required String ribbon_image_path,
  required String signature_image_path,
  required Color main_color,
}) async {
  final pdf = pw.Document();

  final logo_image = pw.Container(
    height: 180,
    width: 180,
    child: pw.Image(
      pw.MemoryImage(
        (await rootBundle.load(logo_image_path)).buffer.asUint8List(),
      ),
    ),
  );

  final ribbon_image = pw.Container(
    height: 180,
    width: 180,
    child: pw.Image(
      pw.MemoryImage(
        (await rootBundle.load(ribbon_image_path)).buffer.asUint8List(),
      ),
    ),
  );

  final signature_image = pw.Container(
    height: 180,
    width: 180,
    child: pw.Image(
      pw.MemoryImage(
        (await rootBundle.load(signature_image_path)).buffer.asUint8List(),
      ),
    ),
  );

  var pinyon_script_regular_font = await PdfGoogleFonts.pinyonScriptRegular();

  PdfColor main_pdf_color = PdfColor.fromInt(
    main_color.value,
  );

  pdf.addPage(
    pw.Page(
      theme: pw.ThemeData.withFont(
        base: await PdfGoogleFonts.quicksandRegular(),
        bold: await PdfGoogleFonts.quicksandMedium(),
        icons: await PdfGoogleFonts.materialIcons(),
      ),
      pageFormat: PdfPageFormat(
        40 * PdfPageFormat.cm,
        32 * PdfPageFormat.cm,
      ),
      build: (pw.Context context) {
        return pw.Container(
          decoration: pw.BoxDecoration(
            gradient: pw.LinearGradient(
              colors: [
                main_pdf_color,
                PdfColors.white,
              ],
              begin: pw.Alignment.topCenter,
              end: pw.Alignment.bottomCenter,
              stops: [0.0, 0.3],
              tileMode: pw.TileMode.clamp,
            ),
          ),
          child: pw.Column(
            children: [
              pw.Expanded(
                flex: 40,
                child: pw.Row(
                  children: [
                    pw.Spacer(flex: 1),
                    pw.Expanded(
                      flex: 4,
                      child: pw.Container(
                        child: pw.Column(
                          children: [
                            pw.Spacer(flex: 1),
                            logo_image,
                            pw.Expanded(
                              flex: 2,
                              child: pw.Text(
                                "Achievement Certificate",
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  color: PdfColors.black,
                                  fontSize: 60,
                                  fontWeight: pw.FontWeight.bold,
                                  font: pinyon_script_regular_font,
                                ),
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text(
                                certificate.course_name,
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  color: PdfColors.black,
                                  fontSize: 20,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text(
                                institution_name,
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  color: PdfColors.black,
                                  fontSize: 30,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text(
                                "Does hereby certify that:",
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  color: PdfColors.black,
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text(
                                certificate.user_name,
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  color: PdfColors.black,
                                  fontSize: 24,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Expanded(
                              flex: 2,
                              child: pw.Text(
                                "Has successfully completed the requirements set forth by the ${institution_name} program guidelines for ${certificate.course_name} Certification on ${certificate.date}.",
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  color: PdfColors.black,
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Expanded(
                              flex: 3,
                              child: pw.Row(
                                children: [
                                  pw.Expanded(
                                    flex: 1,
                                    child: pw.Column(
                                      children: [
                                        pw.Expanded(
                                          flex: 2,
                                          child: ribbon_image,
                                        ),
                                        pw.Expanded(
                                          flex: 1,
                                          child: pw.Text(
                                            location,
                                            textAlign: pw.TextAlign.center,
                                            style: pw.TextStyle(
                                              color: PdfColors.black,
                                              fontSize: 14,
                                              fontWeight: pw.FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  pw.Expanded(
                                    flex: 1,
                                    child: pw.Column(
                                      children: [
                                        pw.Expanded(
                                          flex: 2,
                                          child: signature_image,
                                        ),
                                        pw.Container(
                                          height: 1,
                                          width: 150,
                                          margin: pw.EdgeInsets.all(10),
                                          color: PdfColors.black,
                                        ),
                                        pw.Expanded(
                                          flex: 1,
                                          child: pw.Text(
                                            "Program Director",
                                            textAlign: pw.TextAlign.center,
                                            style: pw.TextStyle(
                                              color: PdfColors.black,
                                              fontSize: 14,
                                              fontWeight: pw.FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        pw.Spacer(flex: 1),
                                        pw.Expanded(
                                          flex: 1,
                                          child: pw.Text(
                                            "Certificate ID:",
                                            textAlign: pw.TextAlign.center,
                                            style: pw.TextStyle(
                                              color: PdfColors.black,
                                              fontSize: 14,
                                              fontWeight: pw.FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        pw.Expanded(
                                          flex: 1,
                                          child: pw.Text(
                                            certificate.id,
                                            textAlign: pw.TextAlign.center,
                                            style: pw.TextStyle(
                                              color: PdfColors.black,
                                              fontSize: 14,
                                              fontWeight: pw.FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        pw.Expanded(
                                          flex: 1,
                                          child: PdfUrlText(
                                            text: website +
                                                "/#/certificates/" +
                                                certificate.id,
                                            url: "https://" +
                                                website +
                                                "/#/certificates/" +
                                                certificate.id,
                                            font_size: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.Spacer(flex: 1),
                          ],
                        ),
                      ),
                    ),
                    pw.Spacer(flex: 1),
                  ],
                ),
              ),
              pw.Expanded(
                flex: 1,
                child: pw.Container(
                  color: main_pdf_color,
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  var pdf_bytes = await pdf.save();
  return pdf_bytes;
}
