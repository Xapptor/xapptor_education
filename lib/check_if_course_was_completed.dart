// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:xapptor_education/check_if_certificate_exists.dart';

check_if_course_was_completed({
  required String course_id,
  required Map<String, dynamic> user_info,
  required BuildContext context,
}) {
  FirebaseFirestore.instance.collection('courses').doc(course_id).get().then((course) async {
    List units_id = course["units"];

    if (user_info["units_completed"] != null) {
      if (user_info["units_completed"].length > 0) {
        for (var unit in user_info["units_completed"]) {
          if (unit == units_id.last) {
            check_if_certificate_exists(
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
