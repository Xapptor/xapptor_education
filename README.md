# **Xapptor Education**
[![pub package](https://img.shields.io/pub/v/xapptor_education?color=blue)](https://pub.dartlang.org/packages/xapptor_education)
### Module for taking classes, tests and learning.

## **Let's get started**

### **1 - Depend on it**
##### Add it to your package's pubspec.yaml file
```yml
dependencies:
    xapptor_education: ^0.0.1
```

### **2 - Install it**
##### Install packages from the command line
```sh
flutter pub get
```

### **3 - Learn it like a charm**

#### **Certificates Visualizer**
```dart

List certificates_id = [];
List courses_id = [];
List<CourseCertificate> certificates = [];
Map<String, dynamic> user_info = {};
String user_id = "";

@override
  void initState() {
    super.initState();
    set_user_info();
}

set_user_info() async {
    user_id = FirebaseAuth.instance.currentUser!.uid;
    user_info = await get_user_info(user_id);
    setState(() {});
    check_user_courses();
    get_certificates();
}

// Checking for user courses.

check_user_courses() {
    if (user_info["products_acquired"] != null) {
        if (user_info["products_acquired"].length > 0) {
            courses_id = List.from(user_info["products_acquired"]);
            for (var course_id in courses_id) {
                check_if_course_was_completed(
                    course_id: course_id,
                    user_info: user_info,
                    context: context,
                );
            }
        }
    }
}

get_certificates() async {
    certificates.clear();
    if (user_info["certificates"] != null) {
        if (user_info["certificates"].length > 0) {
        certificates_id = List.from(user_info["certificates"]);

        for (var certificate_id in certificates_id) {
            await FirebaseFirestore.instance
                .collection("certificates")
                .doc(certificate_id)
                .get()
                .then((snapshot_certificate) async {
                    Map<String, dynamic> data_certificate =
                        snapshot_certificate.data()!;

                    await FirebaseFirestore.instance
                        .collection("courses")
                        .doc(data_certificate["course_id"])
                        .get()
                        .then((snapshot_course) {
                            Map<String, dynamic> data_course = snapshot_course.data()!;

                            certificates.add(
                            CourseCertificate(
                                id: certificate_id,
                                date: timestamp_to_date(data_certificate["date"]),
                                course_name: data_course["name"],
                                user_name:
                                    user_info["firstname"] + " " + user_info["lastname"],
                                user_id: user_id,
                            ),
                        );
                        setState(() {});
                    });
                });
            }
        }
    }
}

// Finally calling Certificates Visualizer

CertificatesVisualizer(
    certificate: certificates[i],
    topbar_color: Colors.blue,
    pdf_converter_url: 'https://yourmicroservice.com/yourpdfconverter',
    local_host_pdf_converter_url: 'http://localhost:8080/yourpdfconverter',
);
```

#### **Certificates and Rewards**
```dart
CertificatesAndRewards(
    button_color_1: Colors.green,
    button_color_2: Colors.cyan,
    text_color: Colors.black,
    topbar_color: Colors.blue,
    pdf_converter_url:
        "https://us-central1-your-firebase-project-or-microservice.cloudfunctions.net/convert_html_to_pdf",
    local_host_pdf_converter_url:
        "http://localhost:5001/your-firebase-project-or-microservice/us-central1/convert_html_to_pdf",
);
```

#### **Class Quiz**
```dart
ClassQuiz(
    course_id: course_id,
    course_name: course_name,
    unit_id: unit_id,
    last_unit: false,
    language_picker_items_text_color: Colors.cyan,
    language_picker: false,
    text_color: Colors.black,
    topbar_color: Colors.blue,
);
```

#### **Class Session**
```dart
ClassSession(
    course_id: course_id,
    course_name: course_name,
    unit_id: unit_id,
    language_picker_items_text_color: Colors.cyan,
    language_picker: false,
    topbar_color: Colors.blue,
    text_color: Colors.black,
);
```

#### **Class Quiz Question**
```dart
ClassQuizQuestion(
    question_title: questions_object[i]["question_title"],
    answers: final_possible_answers,
    demos: questions_object[i]["demos"],
    class_quiz: this,
    correct_answer: questions_object[i]["correct_answer"].toString(),
    question_id: i,
    text_color: Colors.black,
);
```

#### **Class Quiz Result**
```dart
ClassQuizResult(
    button_text: button_text,
    class_quiz: this,
    text_color: Colors.black,
);
```

#### **Courses List**
```dart
CoursesList(
    language_picker_items_text_color: Colors.cyan,
    language_picker: false,
    text_color: Colors.black,
    topbar_color: Colors.blue,
);
```

### **4 - Check Abeinstitute Repo for more examples**
[Abeinstitute Repo](https://github.com/Xapptor/abeinstitute)

[Abeinstitute](https://www.abeinstitute.com)