import 'package:flutter/material.dart';

class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    // todo: use GameQuestion model
    required this.questions,
    required this.answers,
  });

  final List<String> questions;
  final List<String> answers;

  @override
  Widget build(BuildContext context) {
    return Card(
      // Maybe make this just return 1 question
      child: ListView.builder(
        itemCount: 6,
        itemBuilder: (ctx, index) => ListTile(
          title: Text(questions[index]),
        ),
      ),
    );
  }
}
