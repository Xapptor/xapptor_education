import 'dart:math';
import 'package:xapptor_education/check_if_certificate_exists.dart';
import 'package:xapptor_translation/model/text_list.dart';
import 'package:xapptor_translation/translation_stream.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'class_quiz_question.dart';
import 'class_quiz_result.dart';
import 'package:xapptor_translation/language_picker.dart';
import 'package:xapptor_ui/widgets/top_and_bottom/topbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:xapptor_ui/utils/is_portrait.dart';
import 'package:xapptor_db/xapptor_db.dart';

class ClassQuiz extends StatefulWidget {
  final String course_id;
  final String course_name;
  final String unit_id;
  final bool last_unit;
  final Color language_picker_items_text_color;
  final bool language_picker;
  final Color text_color;
  final Color topbar_color;

  const ClassQuiz({
    super.key,
    required this.course_id,
    required this.course_name,
    required this.unit_id,
    required this.last_unit,
    required this.language_picker_items_text_color,
    required this.language_picker,
    required this.text_color,
    required this.topbar_color,
  });

  @override
  State<ClassQuiz> createState() => _ClassQuizState();
}

class _ClassQuizState extends State<ClassQuiz> {
  String user_id = "";

  int source_language_index = 0;

  update_source_language({
    required int new_source_language_index,
  }) {
    source_language_index = new_source_language_index;
    setState(() {});
  }

  TranslationTextListArray text_list = TranslationTextListArray([
    TranslationTextList(
      source_language: "en",
      text_list: [
        "Lives:",
        "Progress:",
        "Continue",
      ],
    ),
  ]);

  late TranslationStream translation_stream;
  List<TranslationStream> translation_stream_list = [];

  bool quiz_passed = false;
  List questions_result = [];
  double percentage_progress = 0;
  int lives = 3;

  final PageController page_controller = PageController(initialPage: 0);

  int current_page = 0;
  List<Widget> widgets_list = [];

  List<Widget> widgets_action(bool portrait) {
    return [
      Container(
        width: 150,
        margin: const EdgeInsets.only(right: 20),
        child: widget.language_picker
            ? LanguagePicker(
                translation_stream_list: translation_stream_list,
                language_picker_items_text_color: widget.language_picker_items_text_color,
                update_source_language: update_source_language,
              )
            : null,
      ),
    ];
  }

  get_quiz_data(String unit_id) {
    XapptorDB.instance.collection('quizzes').doc(unit_id).get().then((DocumentSnapshot doc_snap) {
      List questions_object = doc_snap.get("questions");

      questions_object.shuffle();

      for (var i = 0; i < questions_object.length; i++) {
        questions_result.add(false);

        List final_possible_answers = [];
        List current_answers = questions_object[i]["answers"];

        if (current_answers.length > 2) {
          while (final_possible_answers.length < (current_answers.length == 3 ? 2 : 3)) {
            final random = Random();

            String random_possible_answer = current_answers[random.nextInt(current_answers.length)].toString();

            if (random_possible_answer != questions_object[i]["correct_answer"].toString()) {
              bool random_possible_answer_already_exist = false;

              for (var four_possible_answer in final_possible_answers) {
                if (four_possible_answer == random_possible_answer) {
                  random_possible_answer_already_exist = true;
                }
              }

              if (!random_possible_answer_already_exist) {
                final_possible_answers.add(random_possible_answer);
              }
            }
          }

          final_possible_answers.add(
            questions_object[i]["correct_answer"].toString(),
          );
        } else {
          final_possible_answers = current_answers;
        }

        widgets_list.add(
          ClassQuizQuestion(
            question_title: questions_object[i]["question_title"],
            answers: final_possible_answers,
            demos: questions_object[i]["demos"],
            class_quiz: this,
            correct_answer: questions_object[i]["correct_answer"].toString(),
            question_id: i,
            text_color: widget.text_color,
          ),
        );
      }

      translation_stream = TranslationStream(
        translation_text_list_array: text_list,
        update_text_list_function: update_text_list,
        list_index: 0,
        source_language_index: source_language_index,
      );
      translation_stream_list = [translation_stream];

      widgets_list.add(
        ClassQuizResult(
          button_text: text_list.get(source_language_index)[2],
          class_quiz: this,
          text_color: widget.text_color,
        ),
      );

      setState(() {});
    });
  }

  update_text_list({
    required int index,
    required String new_text,
    required int list_index,
  }) {
    text_list.get(source_language_index)[index] = new_text;
    setState(() {});
  }

  get_next_question(bool answer_is_correct, int question_id) {
    if (answer_is_correct) {
      questions_result[question_id] = true;
    } else {
      lives--;
    }

    if (lives == 0) {
      quiz_passed = false;

      page_controller.animateToPage(
        widgets_list.length - 1,
        duration: const Duration(milliseconds: 800),
        curve: Curves.elasticOut,
      );
    } else {
      List possible_next_page_index = [];

      for (int i = 0; i < questions_result.length; i++) {
        if (!questions_result[i]) {
          possible_next_page_index.add(i);
        }
      }

      percentage_progress =
          (100 * (questions_result.length - possible_next_page_index.length)) / questions_result.length;

      if (possible_next_page_index.isNotEmpty) {
        int next_page_index = 0;

        if (possible_next_page_index.length > 1) {
          next_page_index = possible_next_page_index.firstWhere((possible) => possible != current_page);
        } else {
          next_page_index = possible_next_page_index[0];
        }

        page_controller.animateToPage(next_page_index,
            duration: const Duration(milliseconds: 800), curve: Curves.elasticOut);
      } else {
        quiz_passed = true;

        page_controller.animateToPage(widgets_list.length - 1,
            duration: const Duration(milliseconds: 800), curve: Curves.elasticOut);

        XapptorDB.instance.collection("users").doc(user_id).update({
          "units_completed": FieldValue.arrayUnion([widget.unit_id]),
        }).catchError((err) => debugPrint(err));

        if (widget.last_unit) {
          check_if_certificate_exists(
            course_id: widget.course_id,
            context: context,
            show_has_certificate: true,
          );
        }
      }
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    translation_stream = TranslationStream(
      translation_text_list_array: text_list,
      update_text_list_function: update_text_list,
      list_index: 0,
      source_language_index: source_language_index,
    );
    translation_stream_list = [translation_stream];

    user_id = FirebaseAuth.instance.currentUser!.uid;
    get_quiz_data(widget.unit_id);
  }

  @override
  Widget build(BuildContext context) {
    bool portrait = is_portrait(context);

    String progress_text =
        "${text_list.get(source_language_index)[1]} ${percentage_progress.toString().length > 4 ? percentage_progress.toString().substring(0, percentage_progress.toString().indexOf(".")) : percentage_progress.toString()}";

    return Scaffold(
      appBar: TopBar(
        context: context,
        background_color: widget.topbar_color,
        has_back_button: true,
        actions: widgets_action(portrait),
        custom_leading: null,
        logo_path: "assets/images/logo.png",
      ),
      body: Container(
        child: widgets_list.isEmpty
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: const EdgeInsets.only(
                        top: 15,
                        bottom: 15,
                      ),
                      child: Text(
                        "${text_list.get(source_language_index)[0]} $lives",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 8,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height / 1.33,
                      child: PageView(
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (int page) {
                          setState(() {
                            current_page = page;
                          });
                        },
                        pageSnapping: true,
                        controller: page_controller,
                        children: widgets_list,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      progress_text,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
