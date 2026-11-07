import 'package:flutter/material.dart';

class ActivityQuestionMark extends StatelessWidget {
  const ActivityQuestionMark({super.key});

  static const questionMarkKey = Key('activity_question_mark');
  static const asset = 'lib/ui/graphics/activity_question_mark_angled.png';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: questionMarkKey,
      label: 'Question mark for the first activity goal',
      image: true,
      child: ExcludeSemantics(child: Image.asset(asset, fit: BoxFit.contain)),
    );
  }
}
