import 'package:xapptor_router/app_screen.dart';
import 'package:xapptor_router/app_screens.dart';
import 'package:xapptor_logic/get_user_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:xapptor_translation/model/text_list.dart';
import 'package:xapptor_translation/translation_stream.dart';
import 'class_session.dart';
import 'package:xapptor_ui/widgets/topbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:xapptor_logic/is_portrait.dart';

class CoursesList extends StatefulWidget {
  const CoursesList({
    required this.language_picker_items_text_color,
    required this.language_picker,
    required this.text_color,
    required this.topbar_color,
    required this.website,
  });

  final Color language_picker_items_text_color;
  final bool language_picker;
  final Color text_color;
  final Color topbar_color;
  final String website;

  @override
  _CoursesListState createState() => _CoursesListState();
}

class _CoursesListState extends State<CoursesList> {
  List<String> products_acquired = <String>[];
  List<Map<String, dynamic>> courses_and_units = <Map<String, dynamic>>[];
  List<Course> courses = <Course>[];
  Map<String, dynamic> user_info = {};

  TranslationTextListArray text_list = TranslationTextListArray([
    TranslationTextList(
      source_language: "en",
      text_list: ["You don't have courses"],
    ),
  ]);

  late TranslationStream translation_stream;
  List<TranslationStream> translation_stream_list = [];

  int source_language_index = 0;

  update_source_language({
    required int new_source_language_index,
  }) {
    source_language_index = new_source_language_index;
    setState(() {});
  }

  update_text_list({
    required int index,
    required String new_text,
    required int list_index,
  }) {
    text_list.get(source_language_index)[index] = new_text;
    setState(() {});
  }

  // Retrieving courses.

  get_courses_and_units() async {
    user_info = await get_user_info(FirebaseAuth.instance.currentUser!.uid);
    courses.clear();

    if (user_info["products_acquired"] != null) {
      if (user_info["products_acquired"].length > 0) {
        products_acquired = List.from(user_info["products_acquired"]);

        for (int i = 0; i < products_acquired.length; i++) {
          DocumentSnapshot firestore_course = await FirebaseFirestore.instance
              .collection("courses")
              .doc(products_acquired[i])
              .get();

          List<String> units = List.from(firestore_course.get("units"));

          List<String> units_name = List<String>.generate(
              units.length, (counter) => "Unit ${counter + 1}");

          List<bool> units_completed_status =
              List<bool>.generate(units.length, (counter) => false);

          for (int i = 0; i < units.length; i++) {
            if (user_info["units_completed"] != null) {
              if (user_info["units_completed"].length > 0) {
                for (int j = 0; j < user_info["units_completed"].length; j++) {
                  if (units[i] == user_info["units_completed"][j]) {
                    units_completed_status[i] = true;
                  }
                }
              }
            }
          }

          courses.add(
            Course(
              products_acquired[i],
              firestore_course.get("name"),
              units_name,
              Icons.check_circle_outline,
              units,
              units_completed_status,
            ),
          );
        }
      }
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    get_courses_and_units();

    translation_stream = TranslationStream(
      translation_text_list_array: text_list,
      update_text_list_function: update_text_list,
      list_index: 0,
      source_language_index: source_language_index,
    );

    translation_stream_list = [
      translation_stream,
    ];
  }

  @override
  Widget build(BuildContext context) {
    bool portrait = is_portrait(context);

    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        appBar: TopBar(
          background_color: widget.text_color,
          has_back_button: true,
          actions: [],
          custom_leading: null,
          logo_path: "assets/images/logo.png",
        ),
        body: courses.length > 0
            ? Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: 0.8,
                  widthFactor: 0.8,
                  child: ListView.builder(
                    itemCount: courses.length,
                    itemBuilder: (context, i) {
                      return Column(
                        children: <Widget>[
                          ExpansionTile(
                            backgroundColor: Colors.grey[100],
                            title: Text(
                              courses[i].title,
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            initiallyExpanded: true,
                            children: <Widget>[
                              Column(
                                children: build_expandable_content(
                                  course: courses[i],
                                  context: context,
                                  get_courses_and_units: get_courses_and_units,
                                  language_picker_items_text_color:
                                      widget.language_picker_items_text_color,
                                  language_picker: widget.language_picker,
                                  topbar_color: widget.topbar_color,
                                  text_color: widget.text_color,
                                  website: widget.website,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              )
            : Center(
                child: Text(
                  text_list.get(source_language_index)[0],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
        // : Center(
        //     child: CircularProgressIndicator(
        //       valueColor: new AlwaysStoppedAnimation<Color>(
        //         Theme.of(context).primaryColor,
        //       ),
        //     ),
        //   ),
      ),
    );
  }
}

build_expandable_content({
  required Course course,
  required BuildContext context,
  required Function get_courses_and_units,
  required Color language_picker_items_text_color,
  required bool language_picker,
  required Color topbar_color,
  required Color text_color,
  required String website,
}) {
  List<Widget> column_content = [];

  for (String content in course.contents) {
    int content_index = course.contents.indexOf(content);
    column_content.add(
      GestureDetector(
        onTap: () async {
          String unit_id = course.unit_ids[content_index];

          if (content_index == 0 ||
              course.units_completed_status[content_index - 1]) {
            open_class_session(
              course_id: course.id,
              course_name: course.title,
              unit_id: unit_id,
              language_picker_items_text_color:
                  language_picker_items_text_color,
              language_picker: language_picker,
              topbar_color: topbar_color,
              text_color: text_color,
              website: website,
            );
          }
        },
        child: ListTile(
          title: Text(
            content,
            style: TextStyle(fontSize: 18.0),
          ),
          leading: Icon(
            course.icon,
            color: course.units_completed_status[content_index]
                ? Colors.lightGreen
                : Colors.transparent,
          ),
        ),
      ),
    );
  }

  return column_content;
}

// Open class session.

open_class_session({
  required String course_id,
  required String course_name,
  required String unit_id,
  required Color language_picker_items_text_color,
  required bool language_picker,
  required Color topbar_color,
  required Color text_color,
  required String website,
}) {
  add_new_app_screen(
    AppScreen(
      name: "home/courses/unit_$unit_id",
      child: ClassSession(
        course_id: course_id,
        course_name: course_name,
        unit_id: unit_id,
        language_picker_items_text_color: language_picker_items_text_color,
        language_picker: language_picker,
        topbar_color: topbar_color,
        text_color: text_color,
        website: website,
      ),
    ),
  );
  open_screen("home/courses/unit_$unit_id");
}

// Course model.

class Course {
  Course(
    this.id,
    this.title,
    this.contents,
    this.icon,
    this.unit_ids,
    this.units_completed_status,
  );

  final String id;
  final String title;
  List<String> contents = [];
  final IconData icon;
  List<String> unit_ids = [];
  List<bool> units_completed_status = [];
}
