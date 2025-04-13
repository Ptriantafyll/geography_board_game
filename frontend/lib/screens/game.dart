import 'package:flutter/material.dart';
import 'package:geography_board_game/data/questions.dart';
import 'package:geography_board_game/models/player.dart';
import 'package:geography_board_game/widgets/player_item.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.gameId, required this.players});

  final String gameId;
  final List<Player> players;

  @override
  State<StatefulWidget> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final questions = dummy_questions;
  Map<String, Object>? currentQuestion;
  bool showingScores = true;
  bool showingQuestion = false;
  bool showingAnswers = false;

  void showQuestion() {
    // todo: get a random question from the db

    if (showingScores) {
      showingScores = false;
      showingQuestion = true;
      showingAnswers = false;
    } else if (showingQuestion) {
      showingScores = false;
      showingQuestion = false;
      showingAnswers = true;
    } else if (showingAnswers) {
      showingScores = true;
      showingQuestion = false;
      showingAnswers = false;
    }

    setState(() {
      currentQuestion = questions[0];
    });
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
        child: Text(currentQuestion!['question'].toString()),
      );
    } else if (showingAnswers) {
      content = Center(
        child: Text('Showing Answers'),
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
