import 'package:xapptor_translation/model/text_list.dart';
import 'package:xapptor_translation/translation_stream.dart';
import 'package:auto_size_text_pk/auto_size_text_pk.dart';
import 'package:flutter/material.dart';
import 'package:xapptor_ui/widgets/custom_card.dart';
import 'class_quiz_answer_item.dart';
import 'package:xapptor_logic/is_portrait.dart';

class ClassQuizQuestion extends StatefulWidget {
  const ClassQuizQuestion({
    required this.question_title,
    required this.answers,
    required this.demos,
    required this.class_quiz,
    required this.correct_answer,
    required this.question_id,
    required this.text_color,
  });

  final String question_title;
  final List answers;
  final List? demos;
  final class_quiz;
  final String correct_answer;
  final int question_id;
  final Color text_color;

  @override
  _ClassQuizQuestionState createState() => _ClassQuizQuestionState();
}

class _ClassQuizQuestionState extends State<ClassQuizQuestion> {
  int current_index = 0;

  List<bool> answers_selected = <bool>[];

  late TranslationStream translation_stream;
  List<TranslationStream> translation_stream_list = [];

  TranslationTextListArray text_list = TranslationTextListArray(
    [
      TranslationTextList(
        source_language: "en",
        text_list: [
          "Text",
          "Text",
          "Text",
        ],
      ),
    ],
  );

  List<String> answers_list = [];

  get_quiz_data() {
    for (var i = 0; i < widget.answers.length; i++) {
      answers_selected.add(false);
    }

    widget.answers.shuffle();
    setState(() {});
  }

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

  @override
  void initState() {
    super.initState();

    text_list.list[0].text_list = [
      widget.question_title,
      "Validate",
      widget.correct_answer,
    ];

    for (int i = 0; i < widget.answers.length; i++) {
      text_list.list[0].text_list.add(widget.answers[i].toString());
      answers_list.add(widget.answers[i].toString());
    }

    translation_stream = TranslationStream(
      translation_text_list_array: text_list,
      update_text_list_function: update_text_list,
      list_index: 0,
      source_language_index: source_language_index,
    );
    translation_stream_list = [translation_stream];

    get_quiz_data();
  }

  @override
  Widget build(BuildContext context) {
    bool portrait = is_portrait(context);

    return Container(
      child: Column(
        children: <Widget>[
          Spacer(flex: 1),
          Expanded(
            flex: 3,
            child: Container(
              width: portrait ? 300 : 700,
              child: AutoSizeText(
                text_list.get(source_language_index)[0],
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                minFontSize: 12,
                maxLines: 5,
                overflow: TextOverflow.clip,
              ),
            ),
          ),
          widget.demos == null
              ? Container()
              : Expanded(
                  flex: 3,
                  child: Image.network(
                    widget.demos![0],
                    fit: BoxFit.fitHeight,
                  ),
                ),
          Expanded(
            flex: 9,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.answers.length,
              itemBuilder: (BuildContext context, int index) =>
                  FractionallySizedBox(
                widthFactor: portrait ? 0.85 : 0.4,
                child: ClassQuizAnswerItem(
                  answer_text: text_list.list[0].text_list.length >= (index + 4)
                      ? answers_list[index].contains("http")
                          ? answers_list[index]
                          : text_list.get(source_language_index)[index + 3]
                      : "",
                  index: index,
                  class_quiz_question: this,
                  selected: current_index == index,
                  background_color: widget.answers.length > 2
                      ? (index % 2 == 0)
                          ? Colors.white
                          : Color(0xffe4eded)
                      : Colors.white,
                  text_color: widget.text_color,
                ),
              ),
            ),
          ),
          Spacer(flex: 1),
          Expanded(
            flex: 1,
            child: Container(
              width: 200,
              child: CustomCard(
                linear_gradient: LinearGradient(
                  colors: [
                    widget.text_color,
                    widget.text_color,
                  ],
                ),
                border_radius: 1000,
                on_pressed: () {
                  bool answer_is_correct =
                      text_list.get(source_language_index)[current_index + 3] ==
                          text_list.get(source_language_index)[2];

                  widget.class_quiz
                      .get_next_question(answer_is_correct, widget.question_id);
                },
                child: Center(
                  child: Text(
                    text_list.get(source_language_index)[1],
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Spacer(flex: 1),
        ],
      ),
    );
  }
}
