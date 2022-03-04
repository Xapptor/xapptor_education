late XapptorEducationOptions xapptor_education_options;

class XapptorEducation {
  XapptorEducation.initialize(
      XapptorEducationOptions new_xapptor_education_options) {
    xapptor_education_options = new_xapptor_education_options;
  }
}

class XapptorEducationOptions {
  XapptorEducationOptions({
    required this.website,
  });

  final String website;
}
