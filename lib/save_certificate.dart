// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:xapptor_logic/send_email.dart';
import 'initialize.dart';
import 'package:xapptor_db/xapptor_db.dart';

save_certificate({
  required User user,
  required Map user_info,
  required String course_id,
  required bool has_certificate,
  required bool show_has_certificate,
  required BuildContext context,
}) async {
  if (!has_certificate) {
    XapptorDB.instance.collection("certificates").add({
      "course_id": course_id,
      "date": FieldValue.serverTimestamp(),
      "user_id": user.uid,
    }).then((new_certificate) async {
      XapptorDB.instance.collection("users").doc(user.uid).update({
        "certificates": FieldValue.arrayUnion([new_certificate.id]),
      }).catchError((err) => debugPrint(err));

      DocumentSnapshot course_snapshot = await XapptorDB.instance.collection("courses").doc(course_id).get();

      String course_name = course_snapshot.get("name");

      await send_email(
        to: user.email!,
        subject: "${user_info["firstname"]} ${user_info["lastname"]}, $course_name certificate",
        text:
            "Congratulations ${user_info["firstname"]} ${user_info["lastname"]}, here is your $course_name certificate, ${xapptor_education_options.website}/certificates/${new_certificate.id}",
      ).then((value) => {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Certificate email sent! ✉️"),
                duration: Duration(seconds: 3),
              ),
            ),
          });
    }).catchError((error) {
      debugPrint(error);
    });
  } else {
    if (show_has_certificate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You already have this certificate 👍"),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
