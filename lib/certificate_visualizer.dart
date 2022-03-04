import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:xapptor_logic/file_downloader/file_downloader.dart';
import 'package:xapptor_router/app_screens.dart';
import 'course_certificate.dart';
import 'package:xapptor_ui/widgets/topbar.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'generate_pdf_certificate.dart';

class CertificatesVisualizer extends StatefulWidget {
  CertificatesVisualizer({
    required this.certificate,
    required this.topbar_color,
    required this.institution_name,
    required this.location,
    required this.website,
    required this.logo_image_path,
    required this.ribbon_image_path,
    required this.signature_image_path,
  });

  CourseCertificate? certificate;
  final Color topbar_color;
  final String institution_name;
  final String location;
  final String website;
  final String logo_image_path;
  final String ribbon_image_path;
  final String signature_image_path;

  @override
  _CertificatesVisualizerState createState() => _CertificatesVisualizerState();
}

class _CertificatesVisualizerState extends State<CertificatesVisualizer> {
  String html_string = "";
  Uint8List? pdf_bytes = null;

  // Download base64 PDF certificate from backend.

  download_certificate() async {
    Timer(Duration(milliseconds: 500), () async {
      pdf_bytes = await generate_pdf_certificate(
        institution_name: widget.institution_name,
        location: widget.location,
        website: widget.website,
        logo_image_path: widget.logo_image_path,
        ribbon_image_path: widget.ribbon_image_path,
        signature_image_path: widget.signature_image_path,
        certificate: widget.certificate!,
        main_color: widget.topbar_color,
      );
      setState(() {});
    });
  }

  check_certificate() async {
    if (widget.certificate != null) {
      download_certificate();
    } else {
      String certificate_id =
          Uri.parse(app_screens.last.name).pathSegments.last;

      widget.certificate = await get_certificate_from_id(
        id: certificate_id,
      );

      download_certificate();
    }
  }

  @override
  void initState() {
    super.initState();
    check_certificate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        background_color: widget.topbar_color,
        has_back_button: true,
        actions: [
          IconButton(
            icon: Icon(
              UniversalPlatform.isWeb ? Icons.download_rounded : Icons.share,
              color: Colors.white,
            ),
            onPressed: () async {
              // Download PDF certificate file.

              String file_name =
                  "certificate_${widget.certificate!.user_name.split(" ").join("_")}_${widget.certificate!.course_name.split(" ").join("_")}_${widget.certificate!.id}.pdf";

              FileDownloader.save(
                base64_string: base64.encode(pdf_bytes!),
                file_name: file_name,
              );
            },
          ),
        ],
        custom_leading: null,
        logo_path: "assets/images/logo.png",
      ),
      body: pdf_bytes != null
          ? SafeArea(
              child: SfPdfViewer.memory(
                pdf_bytes!,
                enableDoubleTapZooming: true,
              ),
            )
          : Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
    );
  }
}
