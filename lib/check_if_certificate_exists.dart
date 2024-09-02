import 'package:xapptor_db/xapptor_db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xapptor_education/save_certificate.dart';
import 'package:xapptor_logic/user/get_user_info.dart';

check_if_certificate_exists({
  required String course_id,
  required BuildContext context,
  required bool show_has_certificate,
}) async {
  User user = FirebaseAuth.instance.currentUser!;
  Map user_info = await get_user_info(user.uid);
  List? certificates = user_info["certificates"];

  bool has_certificates = false;
  bool has_certificate = false;

  if (certificates != null) {
    if (certificates.isNotEmpty) {
      has_certificates = true;
    }
  }

  if (has_certificates) {
    for (var certificate in certificates!) {
      var certificate_snap = await XapptorDB.instance.collection('certificates').doc(certificate).get();

      String snapshot_course_id = certificate_snap.get("course_id");

      if (snapshot_course_id == course_id) {
        has_certificate = true;
      }
      if (context.mounted) {
        save_certificate(
          user: user,
          user_info: user_info,
          course_id: course_id,
          has_certificate: has_certificate,
          context: context,
          show_has_certificate: show_has_certificate,
        );
      }
    }
  } else {
    if (context.mounted) {
      save_certificate(
        user: user,
        user_info: user_info,
        course_id: course_id,
        has_certificate: has_certificate,
        context: context,
        show_has_certificate: show_has_certificate,
      );
    }
  }
}
