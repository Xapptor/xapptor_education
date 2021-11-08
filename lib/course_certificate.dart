// CourseCertificate model.

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
