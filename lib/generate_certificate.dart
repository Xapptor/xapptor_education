import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:xapptor_logic/get_user_info.dart';
import 'package:xapptor_logic/send_email.dart';

import 'initialize.dart';

// Check if exist certificate.

check_if_exist_certificate({
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
      var certificate_snap = await FirebaseFirestore.instance
          .collection('certificates')
          .doc(certificate)
          .get();

      String snapshot_course_id = certificate_snap.get("course_id");

      if (snapshot_course_id == course_id) {
        has_certificate = true;
      }
      save_certificate(
        user: user,
        user_info: user_info,
        course_id: course_id,
        has_certificate: has_certificate,
        context: context,
        show_has_certificate: show_has_certificate,
      );
    }
  } else {
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

// Save certificate.

save_certificate({
  required User user,
  required Map user_info,
  required String course_id,
  required bool has_certificate,
  required bool show_has_certificate,
  required BuildContext context,
}) async {
  if (!has_certificate) {
    FirebaseFirestore.instance.collection("certificates").add({
      "course_id": course_id,
      "date": FieldValue.serverTimestamp(),
      "user_id": user.uid,
    }).then((new_certificate) async {
      FirebaseFirestore.instance.collection("users").doc(user.uid).update({
        "certificates": FieldValue.arrayUnion([new_certificate.id]),
      }).catchError((err) => print(err));

      DocumentSnapshot course_snapshot = await FirebaseFirestore.instance
          .collection("courses")
          .doc(course_id)
          .get();

      String course_name = course_snapshot.get("name");

      send_email(
        to: user.email!,
        subject:
            "${user_info["firstname"]} ${user_info["lastname"]}, $course_name certificate",
        text:
            "Congratulations ${user_info["firstname"]} ${user_info["lastname"]}, here is your $course_name certificate, ${xapptor_education_options.website}/#/certificates/${new_certificate.id}",
      )
          .then((value) => {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Certificate email sent! ✉️"),
                    duration: Duration(seconds: 3),
                  ),
                ),
              })
          .catchError((err) => print(err));
    }).catchError((err) {
      print(err);
    });
  } else {
    if (show_has_certificate) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("You already have this certificate 👍"),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}

// Check if course was completed.

check_if_course_was_completed({
  required String course_id,
  required Map<String, dynamic> user_info,
  required BuildContext context,
}) {
  FirebaseFirestore.instance
      .collection('courses')
      .doc(course_id)
      .get()
      .then((course) async {
    List units_id = course["units"];

    if (user_info["units_completed"] != null) {
      if (user_info["units_completed"].length > 0) {
        for (var unit in user_info["units_completed"]) {
          if (unit == units_id.last) {
            check_if_exist_certificate(
              course_id: course_id,
              context: context,
              show_has_certificate: false,
            );
          }
        }
      }
    }
  });
}
