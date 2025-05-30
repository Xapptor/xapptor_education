import 'package:flutter/material.dart';
import 'package:xapptor_ui/widgets/card/custom_card.dart';

class ClassQuizAnswerItem extends StatefulWidget {
  final String answer_text;
  final int index;
  // ignore: prefer_typing_uninitialized_variables
  final class_quiz_question;
  final bool selected;
  final Color background_color;
  final Color text_color;

  const ClassQuizAnswerItem({
    super.key,
    required this.answer_text,
    required this.index,
    required this.class_quiz_question,
    required this.selected,
    required this.background_color,
    required this.text_color,
  });

  @override
  State<ClassQuizAnswerItem> createState() => _ClassQuizAnswerItemState();
}

class _ClassQuizAnswerItemState extends State<ClassQuizAnswerItem> {
  @override
  Widget build(BuildContext context) {
    bool is_image = widget.answer_text.contains("http");

    Color background_color = widget.selected ? Colors.cyan : widget.background_color;

    return Container(
      height: MediaQuery.of(context).size.height / 6,
      padding: const EdgeInsets.all(5),
      child: CustomCard(
        splash_color: widget.text_color.withValues(alpha: 0.3),
        linear_gradient: LinearGradient(
          colors: [
            background_color,
            background_color,
          ],
        ),
        on_pressed: () {
          widget.class_quiz_question.current_index = widget.index;
          widget.class_quiz_question.setState(() {});
        },
        child: FractionallySizedBox(
          widthFactor: 0.9,
          child: Center(
            child: is_image
                ? Image.network(
                    widget.answer_text,
                    fit: BoxFit.fitHeight,
                  )
                : Text(
                    widget.answer_text,
                    style: TextStyle(
                      color: !widget.selected ? Colors.cyan : widget.background_color,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
