import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geography_board_game/data/questions.dart';
import 'package:geography_board_game/functions/alert.dart';
import 'package:geography_board_game/models/player.dart';
import 'package:geography_board_game/models/question.dart';
import 'package:geography_board_game/models/websocket_response.dart';
import 'package:geography_board_game/providers/websocket_provider.dart';
import 'package:geography_board_game/widgets/player_item.dart';
import 'package:geography_board_game/widgets/question_card.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key, required this.gameId, required this.players});

  final String gameId;
  final List<Player> players;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late WebsocketNotifier webSocketNotifier;
  final _questionController = TextEditingController();
  final questions = dummy_questions;
  Map<String, String> playersWithAnswers = {};
  Map<String, bool> playersAnswered = {};
  var currentQuestion = GameQuestion(
    icon: Icon(Icons.question_mark),
    questionText: "",
    questionAnswer: 0,
  );
  bool showingScores = true;
  bool showingQuestion = false;
  bool answerSubmitted = false;
  bool showingAnswers = false;
  String roundWinner = '';

  String calculateRoundWinner(
      Map<String, String> playersWithAnswers, double answer) {
    final filtered = playersWithAnswers.entries
        .where((player) => double.parse(player.value) <= answer)
        .toList();

    if (filtered.isEmpty) return '';

    // find closest player answer to the actual answer and lower than it and return player id
    return filtered
        .reduce((a, b) => ((double.parse(a.value) - answer).abs() <
                (double.parse(b.value) - answer).abs())
            ? a
            : b)
        .key;
  }

  void submitAnswer() async {
    final isNumeric =
        RegExp(r'^-?\d+(\.\d+)?$').hasMatch(_questionController.text);

    if (!isNumeric || _questionController.text.isEmpty) {
      showAlertDialog(
        "Σφάλμα απάντησης",
        "Η απάντηση πρέπει να είναι μόνο αριθμοί",
        context,
      );
      return;
    }

    final answer = double.parse(_questionController.text);
    // todo: send websocket request to submit answer

    await webSocketNotifier.submitAnswer(answer, widget.gameId);
  }

  void handleQuestion() async {
    if (showingScores) {
      await webSocketNotifier.showQuestion(widget.gameId);
      setState(() {
        showingScores = false;
        showingQuestion = true;
        answerSubmitted = false;
        showingAnswers = false;
        roundWinner = '';
      });
    } else if (showingQuestion) {
      // this is handled in build if response is question shown
      // return;
    } else if (answerSubmitted) {
      // todo: wait for all players to answer and then continue
      setState(() {
        showingScores = false;
        showingQuestion = false;
        answerSubmitted = false;
        showingAnswers = true;
      });
    } else if (showingAnswers) {
      final answer = currentQuestion.questionAnswer;
      setState(() {
        showingScores = true;
        showingQuestion = false;
        answerSubmitted = false;
        showingAnswers = false;

        // clear every answer before showing scores
        playersAnswered.forEach((playerId, _) {
          playersAnswered[playerId] = false;
        });

        // todo: calculate winner of the round
        final winnerId = calculateRoundWinner(playersWithAnswers, answer);
        roundWinner = widget.players
            .firstWhere(
              (player) => player.id == winnerId,
            )
            .name;
      });
      _questionController.clear();
    }
  }

  @override
  void initState() {
    webSocketNotifier = ref.read(websocketProvider.notifier);
    super.initState();
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final response = ref.watch(websocketProvider);
    Widget content;
    Widget? bottomButton;

    if (response is QuestionShownResponse) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          currentQuestion = response.question;
        });
        showingScores = false;
        showingQuestion = true;
        answerSubmitted = false;
        showingAnswers = false;
        ref.read(websocketProvider.notifier).reset();
      });
    }

    if (response is AnswerSubmittedResponse) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // move to answerSubmitted after getting the response
        setState(() {
          showingScores = false;
          showingQuestion = false;
          answerSubmitted = true;
          showingAnswers = false;

          // todo: clear those after seeing scores
          playersWithAnswers = response.playersWithAnswers;
          playersAnswered = response.playersAnswered;
        });
        ref.read(websocketProvider.notifier).reset();
      });
    }

    if (response is PlayerAnsweredResponse) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        //todo: make button disabled until all players have answered or
        //todo: wait for all players to answer and then continue
        setState(() {
          playersAnswered[response.playerAnswered] = true;
          playersWithAnswers[response.playerAnswered] = response.answer;
        });

        ref.read(websocketProvider.notifier).reset();
      });
    }

    if (showingScores) {
      content = Column(
        children: [
          Text('Game ID: ${widget.gameId}'),
          Text('Last round winner: $roundWinner'),
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

      bottomButton = ElevatedButton(
        onPressed: handleQuestion,
        child: const Text('Next Question'),
      );
    } else if (showingQuestion) {
      content = Center(
        child: QuestionCard(
          gameQuestion: currentQuestion,
          questionController: _questionController,
          onSubmitAnswer: submitAnswer,
        ),
      );

      bottomButton = null;
    } else if (answerSubmitted) {
      content = Center(
        child: ListView.builder(
          itemCount: widget.players.length,
          itemBuilder: (ctx, index) {
            Icon hasAnsweredIcon;
            final playerId = widget.players[index].id;

            if (playersAnswered[playerId]!) {
              hasAnsweredIcon = Icon(
                Icons.check,
                color: Colors.green,
              );
            } else {
              hasAnsweredIcon = Icon(
                Icons.close,
                color: Colors.red,
              );
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PlayerItem(
                  player: widget.players[index],
                  isGame: false,
                ),
                hasAnsweredIcon,
              ],
            );
          },
        ),
      );

      bottomButton = ElevatedButton(
        onPressed: handleQuestion,
        child: const Text('Show Answers'),
      );
      ;
    } else if (showingAnswers) {
      content = Center(
        child: ListView.builder(
          itemCount: widget.players.length,
          itemBuilder: (ctx, index) {
            final playerId = widget.players[index].id;
            final answer = playersWithAnswers[playerId]!;

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PlayerItem(
                  player: widget.players[index],
                  isGame: false,
                ),
                Text(answer),
              ],
            );
          },
        ),
      );

      bottomButton = ElevatedButton(
        onPressed: handleQuestion,
        child: const Text('Show Scores'),
      );
    } else {
      content = Text('No content yet');
      bottomButton = null;
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
        onPressed: handleQuestion,
        child: showingScores
            ? const Text('Next Question')
            : showingQuestion || answerSubmitted
                ? const Text('')
                : const Text('Show Scores'),
      ),
      // todo: uncomment this after everythingis done
      // bottomButton,
    );
  }
}
