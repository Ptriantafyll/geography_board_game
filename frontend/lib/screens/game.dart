import 'package:flutter/material.dart';
import 'package:geography_board_game/data/questions.dart';
import 'package:geography_board_game/functions/alert.dart';
import 'package:geography_board_game/models/player.dart';
import 'package:geography_board_game/models/question.dart';
import 'package:geography_board_game/widgets/player_item.dart';
import 'package:geography_board_game/widgets/question_card.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.gameId, required this.players});

  final String gameId;
  final List<Player> players;

  @override
  State<StatefulWidget> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _questionController = TextEditingController();
  final questions = dummy_questions;
  GameQuestion? currentQuestion;
  bool showingScores = true;
  bool showingQuestion = false;
  bool answerSubmitted = false;
  bool showingAnswers = false;

  void showQuestion() {
    // todo: get a random question from the db
    print(_questionController.text);

    if (showingScores) {
      showingScores = false;
      showingQuestion = true;
      answerSubmitted = false;
      showingAnswers = false;
    } else if (showingQuestion) {
      // todo: also check if given answer is numbers only
      if (_questionController.text.isEmpty) {
        showAlertDialog(
          "No answer",
          "Please answer the question",
          context,
        );
        return;
      }

      showingScores = false;
      showingQuestion = false;
      answerSubmitted = true;
      showingAnswers = false;
    } else if (answerSubmitted) {
      // todo: get all answers from the question
      // todo: probably from redis?
      // todo: wait for all players to answer and then continue
      // todo: show check mark for players that have answered
      showingScores = false;
      showingQuestion = false;
      answerSubmitted = false;
      showingAnswers = true;
    } else if (showingAnswers) {
      showingScores = true;
      showingQuestion = false;
      answerSubmitted = false;
      showingAnswers = false;
      _questionController.clear();
    }

    setState(() {
      currentQuestion = GameQuestion(
        questionText: questions[0]['question'],
        questionAnswer: questions[0]['answer'],
        icon: Icon(Icons.question_mark),
      );
    });
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (showingScores) {
      content = Column(
        children: [
          Text('Game ID: ${widget.gameId}'),
          Expanded(
            child: ListView.builder(
              itemCount: widget.players.length,
              itemBuilder: (ctx, index) => PlayerItem(
                player: widget.players[index],
                isGame: true,
              ),
            ),
          ),
        ],
      );
    } else if (showingQuestion) {
      content = Center(
        child: QuestionCard(
          gameQuestion: currentQuestion!,
          questionController: _questionController,
        ),
      );
    } else if (answerSubmitted) {
      //todo: wait for all players to answer and then continue
      //todo: show check mark for players that have answered
      content = Center(
        child: Text('Answer submitted'),
      );
    } else if (showingAnswers) {
      content = Center(
        // child: Text('Showing Answers'),
        child: ListView.builder(
          itemCount: widget.players.length,
          itemBuilder: (ctx, index) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PlayerItem(
                player: widget.players[index],
                isGame: false,
              ),
              Text(_questionController.text),
            ],
          ),
        ),
      );
    } else {
      content = Text('No content yet');
    }

    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Colors.cyan,
        title: Center(
          child: Text(
            'Poli cool',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
      ),
      body: content,
      floatingActionButton: ElevatedButton(
        onPressed: showQuestion,
        child: showingScores
            ? const Text('Next Question')
            : showingQuestion
                ? const Text('Show Answers')
                : const Text('Show Scores'),
      ),
    );
  }
}
