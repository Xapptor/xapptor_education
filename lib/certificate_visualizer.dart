// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:xapptor_logic/date/check_limit_per_date.dart';
import 'package:xapptor_logic/file_downloader/file_downloader.dart';
import 'model/course_certificate.dart';
import 'package:xapptor_ui/widgets/topbar.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'generate_pdf_certificate_bytes.dart';
import 'package:xapptor_router/get_last_path_segment.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CertificateVisualizer extends StatefulWidget {
  CourseCertificate? certificate;
  final Color topbar_color;
  final String institution_name;
  final String location;
  final String website;
  final String logo_image_path;
  final String ribbon_image_path;
  final String signature_image_path;

  CertificateVisualizer({
    super.key,
    required this.certificate,
    required this.topbar_color,
    required this.institution_name,
    required this.location,
    required this.website,
    required this.logo_image_path,
    required this.ribbon_image_path,
    required this.signature_image_path,
  });

  @override
  State<CertificateVisualizer> createState() => _CertificateVisualizerState();
}

class _CertificateVisualizerState extends State<CertificateVisualizer> {
  String html_string = "";
  late Uint8List? pdf_bytes;
  String pdf_url = "";
  late Reference storage_ref;
  Timer? generate_pdf_timer;

  get_storage_ref() {
    storage_ref = FirebaseStorage.instance
        .ref("users")
        .child(widget.certificate!.user_id)
        .child("certificates")
        .child("${widget.certificate!.id}.pdf");

    check_if_file_exist();
  }

  check_if_file_exist() {
    storage_ref.getDownloadURL().then((url) async {
      pdf_url = url;
      setState(() {});
    }).onError((error, stackTrace) async {
      debugPrint(error.toString());
      generate_pdf_timer = Timer(const Duration(milliseconds: 500), () async {
        generate_pdf();
      });
    });
  }

  generate_pdf() async {
    pdf_bytes = await generate_pdf_certificate_bytes(
      institution_name: widget.institution_name,
      location: widget.location,
      website: widget.website,
      logo_image_path: widget.logo_image_path,
      ribbon_image_path: widget.ribbon_image_path,
      signature_image_path: widget.signature_image_path,
      certificate: widget.certificate!,
      main_color: widget.topbar_color,
    );
    await storage_ref.putData(pdf_bytes!);
    pdf_url = await storage_ref.getDownloadURL();
    setState(() {});
  }

  check_certificate() async {
    if (widget.certificate != null) {
      get_storage_ref();
    } else {
      String certificate_id = get_last_path_segment();

      widget.certificate = await get_certificate_from_id(
        id: certificate_id,
      );

      get_storage_ref();
    }
  }

  @override
  void initState() {
    super.initState();
    check_certificate();
  }

  @override
  void dispose() {
    if (generate_pdf_timer != null) {
      generate_pdf_timer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        context: context,
        background_color: widget.topbar_color,
        has_back_button: true,
        actions: pdf_url.isNotEmpty
            ? [
                IconButton(
                  icon: const Icon(
                    FontAwesomeIcons.download,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    download_pdf_certificate();
                  },
                ),
                FirebaseAuth.instance.currentUser != null
                    ? FirebaseAuth.instance.currentUser!.uid == widget.certificate!.user_id
                        ? IconButton(
                            icon: const Icon(
                              Icons.autorenew,
                              color: Colors.white,
                            ),
                            onPressed: () async {
                              check_limit_per_date(
                                new_value: widget.certificate!.id,
                                context: context,
                                reached_limit_alert_title: "Max certificates generated per day!",
                                check_limit_per_date_callback: () {
                                  pdf_url = "";
                                  setState(() {});
                                  generate_pdf();
                                },
                                cache_lifetime_in_seconds: Duration.secondsPerDay * 5,
                                limit: 5,
                                limit_field_name: "generate_certificate_limit",
                                array_field_name: "certificates",
                                reach_limit: ReachLimit.by_day,
                                save_same_value_multiple_times: true,
                              );
                            },
                          )
                        : Container()
                    : Container(),
              ]
            : [],
        custom_leading: null,
        logo_path: "assets/images/logo.png",
      ),
      body: pdf_url != ""
          ? SafeArea(
              child: SfPdfViewer.network(
                pdf_url,
              ),
            )
          : Center(
              child: Text(
                "Loading.. ⏳",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: widget.topbar_color,
                ),
              ),
            ),
    );
  }

  download_pdf_certificate() {
    String user_name = widget.certificate!.user_name.split(" ").join("_");
    String certificate_name = widget.certificate!.course_name.split(" ").join("_");

    String file_name = "certificate_${user_name}_${certificate_name}_${widget.certificate!.id}.pdf";

    if (UniversalPlatform.isWeb) {
      FileDownloader.save(
        src: pdf_url,
        file_name: file_name,
      );
    } else {
      http.get(Uri.parse(pdf_url)).then((response) {
        FileDownloader.save(
          src: response.bodyBytes,
          file_name: file_name,
        );
      });
    }
  }
}
