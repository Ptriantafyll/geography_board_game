import 'package:flutter/material.dart';
import 'package:geography_board_game/models/question.dart';

class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    // todo: use GameQuestion model
    required this.gameQuestion,
    required this.questionController,
    required this.onSubmitAnswer,
  });

  final GameQuestion gameQuestion;
  final TextEditingController questionController;
  final Function onSubmitAnswer;

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.black,
      // todo: make card prettier
      child: SizedBox(
        height: 250,
        width: 250,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(gameQuestion.questionText),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                maxLength: 20,
                controller: questionController,
                decoration: InputDecoration(
                  label: Text('Απάντηση'),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                onSubmitAnswer();
              },
              child: Text('Submit'),
            )
          ],
        ),
      ),
    );
  }
}
