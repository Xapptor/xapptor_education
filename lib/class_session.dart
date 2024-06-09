import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:xapptor_translation/model/text_list.dart';
import 'package:xapptor_translation/translation_stream.dart';
import 'package:auto_size_text_pk/auto_size_text_pk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:xapptor_ui/values/ui.dart';
import 'package:xapptor_ui/widgets/custom_card.dart';
import 'package:xapptor_translation/language_picker.dart';
import 'package:xapptor_ui/widgets/topbar.dart';
import 'package:xapptor_ui/widgets/webview/webview.dart';
import 'package:xapptor_ui/widgets/is_portrait.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'class_quiz.dart';
import 'package:universal_platform/universal_platform.dart';

class ClassSession extends StatefulWidget {
  final String course_id;
  final String course_name;
  final String unit_id;
  final Color language_picker_items_text_color;
  final bool language_picker;
  final Color text_color;
  final Color topbar_color;
  final String website;

  const ClassSession({
    super.key,
    required this.course_id,
    required this.course_name,
    required this.unit_id,
    required this.language_picker_items_text_color,
    required this.language_picker,
    required this.text_color,
    required this.topbar_color,
    required this.website,
  });

  @override
  State<ClassSession> createState() => _ClassSessionState();
}

class _ClassSessionState extends State<ClassSession> {
  String current_language = "en";
  late TranslationStream translation_stream;
  List<TranslationStream> translation_stream_list = [];

  TranslationTextListArray text_list = TranslationTextListArray(
    [
      TranslationTextList(
        source_language: "en",
        text_list: [
          "text",
          "text",
          "text",
          "text",
          "text",
        ],
      ),
    ],
  );

  bool last_unit = false;
  Map video_urls = {};
  bool first_time_updating_text = true;
  late SharedPreferences prefs;
  String complete_url = "";

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

    if (index == (text_list.list[0].text_list.length - 1)) {
      if (!first_time_updating_text) {
        Timer(const Duration(milliseconds: 300), () {
          set_video_url();
        });
      } else {
        first_time_updating_text = false;
      }
    }
  }

  get_texts() async {
    prefs = await SharedPreferences.getInstance();

    FirebaseFirestore.instance.collection('units').doc(widget.unit_id).get().then((DocumentSnapshot doc_snap) {
      text_list.list[0].text_list = [
        doc_snap.get("title"),
        doc_snap.get("subtitle"),
        doc_snap.get("description"),
        doc_snap.get("recomendation"),
        "Start Quiz",
      ];

      video_urls = doc_snap.get("video_urls");
      last_unit = doc_snap.get('last_unit');

      translation_stream = TranslationStream(
        translation_text_list_array: text_list,
        update_text_list_function: update_text_list,
        list_index: 0,
        source_language_index: source_language_index,
      );
      translation_stream_list = [translation_stream];

      set_video_url();
    });
  }

  String generate_video_url_for_current_platform(String original_url) {
    String new_url = "";
    String video_id = original_url.substring(
      original_url.lastIndexOf("/"),
      original_url.length,
    );
    new_url = "${widget.website}/videos$video_id";
    return new_url;
  }

  set_video_url() {
    if (prefs.getString("target_language") != null) {
      current_language = prefs.getString("target_language")!;
    }

    complete_url = generate_video_url_for_current_platform(
      video_urls[(current_language == "en" || current_language == "es") ? current_language : "en"],
    );

    Timer(const Duration(milliseconds: 300), () {
      if (UniversalPlatform.isWeb) {
        setState(() {});
      } else {
        webview_controller.loadUrl(complete_url);
      }
    });
  }

  @override
  void initState() {
    complete_url = widget.website;
    super.initState();

    translation_stream = TranslationStream(
      translation_text_list_array: text_list,
      update_text_list_function: update_text_list,
      list_index: 0,
      source_language_index: source_language_index,
    );
    translation_stream_list = [translation_stream];

    get_texts();
  }

  // ignore: prefer_typing_uninitialized_variables
  late var webview_controller;

  controller_callback(var current_webview_controller) {
    webview_controller = current_webview_controller;
  }

  @override
  Widget build(BuildContext context) {
    bool portrait = is_portrait(context);

    return Scaffold(
      appBar: TopBar(
        context: context,
        background_color: widget.topbar_color,
        has_back_button: true,
        actions: [
          Container(
            width: 150,
            margin: const EdgeInsets.only(right: 20),
            child: LanguagePicker(
              translation_stream_list: translation_stream_list,
              language_picker_items_text_color: widget.text_color,
              update_source_language: update_source_language,
            ),
          ),
        ],
        custom_leading: IconButton(
          icon: const Icon(
            FontAwesomeIcons.angleLeft,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        logo_path: "assets/images/logo.png",
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              FractionallySizedBox(
                widthFactor: portrait ? 0.85 : 0.3,
                child: Column(
                  children: [
                    SizedBox(
                      height: sized_box_space * 4,
                    ),
                    AutoSizeText(
                      "${text_list.get(source_language_index)[0]} - ${text_list.get(source_language_index)[1]}",
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      minFontSize: 18,
                      maxLines: 2,
                      overflow: TextOverflow.clip,
                    ),
                    SizedBox(
                      height: sized_box_space * 2,
                    ),
                    SelectableText(
                      text_list.get(source_language_index)[2],
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: sized_box_space * 2,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 3,
                width: MediaQuery.of(context).size.width / (portrait ? 1 : 2),
                child: Webview(
                  src: complete_url,
                  id: const Uuid().v8(),
                  controller_callback: controller_callback,
                ),
              ),
              FractionallySizedBox(
                widthFactor: portrait ? 0.85 : 0.3,
                child: Column(
                  children: [
                    SizedBox(
                      height: sized_box_space * 2,
                    ),
                    SelectableText(
                      text_list.get(source_language_index)[3],
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: sized_box_space * 2,
                    ),
                    SizedBox(
                      height: 40,
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClassQuiz(
                                course_id: widget.course_id,
                                course_name: widget.course_name,
                                unit_id: widget.unit_id,
                                last_unit: last_unit,
                                language_picker_items_text_color: widget.language_picker_items_text_color,
                                language_picker: widget.language_picker,
                                text_color: widget.text_color,
                                topbar_color: widget.topbar_color,
                              ),
                            ),
                          );
                        },
                        child: Center(
                          child: Text(
                            text_list.get(source_language_index)[4],
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: sized_box_space * 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
