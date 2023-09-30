import 'package:flutter/material.dart';
import 'package:xapptor_ui/widgets/custom_card.dart';

class ClassQuizResult extends StatefulWidget {
  const ClassQuizResult({
    super.key,
    required this.button_text,
    required this.class_quiz,
    required this.text_color,
  });

  final String button_text;
  // ignore: prefer_typing_uninitialized_variables
  final class_quiz;
  final Color text_color;

  @override
  State<ClassQuizResult> createState() => _ClassQuizResultState();
}

class _ClassQuizResultState extends State<ClassQuizResult> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Spacer(flex: 1),
        Expanded(
          flex: 14,
          child: Center(
            child: Icon(
              widget.class_quiz.quiz_passed ? Icons.check_circle_outline_rounded : Icons.highlight_off_rounded,
              color: widget.text_color,
              size: 200,
            ),
          ),
        ),
        const Spacer(flex: 1),
        Expanded(
          flex: 1,
          child: SizedBox(
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
                if (widget.class_quiz.quiz_passed) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: Center(
                child: Text(
                  widget.button_text,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        const Spacer(flex: 1),
      ],
    );
  }
}
