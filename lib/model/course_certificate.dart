import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xapptor_logic/date/timestamp_to_date_string.dart';

class CourseCertificate {
  final String id;
  final String date;
  final String course_name;
  final String user_name;
  final String user_id;

  const CourseCertificate({
    required this.id,
    required this.date,
    required this.course_name,
    required this.user_name,
    required this.user_id,
  });
}

Future<CourseCertificate> get_certificate_from_id({
  required String id,
  String? user_name,
}) async {
  var certificate_snap = await FirebaseFirestore.instance.collection("certificates").doc(id).get();

  var course_snap = await FirebaseFirestore.instance.collection("courses").doc(certificate_snap.get("course_id")).get();

  if (user_name == null) {
    var user_snap = await FirebaseFirestore.instance.collection("users").doc(certificate_snap.get("user_id")).get();
    user_name = user_snap.get("firstname") + " " + user_snap.get("lastname");
  }

  return CourseCertificate(
    id: id,
    date: timestamp_to_date_string(certificate_snap.get("date")),
    course_name: course_snap.get("name"),
    user_name: user_name!,
    user_id: certificate_snap.get("user_id"),
  );
}
