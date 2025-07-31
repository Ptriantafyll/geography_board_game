import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geography_board_game/data/questions.dart';
import 'package:geography_board_game/functions/alert.dart';
import 'package:geography_board_game/models/player.dart';
import 'package:geography_board_game/models/question.dart';
import 'package:geography_board_game/models/websocket_response.dart';
import 'package:geography_board_game/providers/websocket_provider.dart';
import 'package:geography_board_game/screens/winner.dart';
import 'package:geography_board_game/widgets/player_item.dart';
import 'package:geography_board_game/widgets/question_card.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({
    super.key,
    required this.gameId,
    required this.players,
    required this.isOwner,
  });

  final String gameId;
  final List<Player> players;
  final bool isOwner;

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

  // how many points are needed to win
  final int pointsNeeded = 10;

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

  void updateScores(String winnerId) async {
    for (Player player in widget.players) {
      if (player.id == winnerId) {
        setState(() {
          player.score = player.score + 1;
        });
      }
    }
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

    await webSocketNotifier.submitAnswer(answer, widget.gameId);
  }

  void showQuestion() async {
    // todo: find another way to handle showing the winner
    for (Player player in widget.players) {
      if (player.score == pointsNeeded) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => WinnerScreen(
              winner: player,
            ),
          ),
        );
      }
    }

    await webSocketNotifier.showQuestion(widget.gameId);
  }

  // todo make owner be the only one able to see the buttons
  // todo and send responses to all
  // todo make comments if someone was burnt
  void showAnswers() async {
    await webSocketNotifier.showAnswers(widget.gameId);
  }

  void showScores() async {
    await webSocketNotifier.showScores(widget.gameId);
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
          showingScores = false;
          showingQuestion = true;
          answerSubmitted = false;
          showingAnswers = false;
        });
        ref.read(websocketProvider.notifier).reset();
      });
    }

    if (response is AnswerSubmittedResponse) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          showingScores = false;
          showingQuestion = false;
          answerSubmitted = true;
          showingAnswers = false;

          playersWithAnswers = response.playersWithAnswers;
          playersAnswered = response.playersAnswered;
        });
        ref.read(websocketProvider.notifier).reset();
      });
    }

    if (response is AnswersShownResponse) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          showingScores = false;
          showingQuestion = false;
          answerSubmitted = false;
          showingAnswers = true;
        });
        ref.read(websocketProvider.notifier).reset();
      });
    }

    if (response is ScoresShownResponse) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final answer = currentQuestion.questionAnswer;
        final winnerId = calculateRoundWinner(playersWithAnswers, answer);
        setState(() {
          showingScores = true;
          showingQuestion = false;
          answerSubmitted = false;
          showingAnswers = false;

          // clear every answer before showing scores
          playersAnswered.forEach((playerId, _) {
            playersAnswered[playerId] = false;
          });

          // calculate winner of the round
          roundWinner = widget.players
              .firstWhere(
                (player) => player.id == winnerId,
              )
              .name;

          // update scores
          updateScores(winnerId);
          // todo: send request to update scores in redis as well
        });

        _questionController.clear();

        ref.read(websocketProvider.notifier).reset();
      });
    }

    if (response is PlayerAnsweredResponse) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
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

      bottomButton = widget.isOwner
          ? ElevatedButton(
              onPressed: showQuestion,
              child: const Text('Next Question'),
            )
          : null;
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
      // todo: add edit answer button
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

      var numOfPlayersThatHaveAnswered =
          playersAnswered.values.where((value) => value).length;

      // make button disabled until all players have answered
      bottomButton = widget.isOwner
          ? ElevatedButton(
              onPressed: numOfPlayersThatHaveAnswered == widget.players.length
                  ? showAnswers
                  : null,
              child: const Text('Show Answers'),
            )
          : null;
    } else if (showingAnswers) {
      content = Column(
        children: [
          Text("Correct answer  ${currentQuestion.questionAnswer} "),
          SizedBox(
            height: 300,
            child: widget.players.length <= 4
                ? ListView.builder(
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
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
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
          )
        ],
      );

      bottomButton = widget.isOwner
          ? ElevatedButton(
              onPressed: showScores,
              child: const Text('Show Scores'),
            )
          : null;
    } else {
      content = Text('No content yet');
      bottomButton = null;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // Send leave game request to server
          print("pop");
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Έξοδος παιχνιδιού'),
              content: const Text('Θέλεις να φύγεις από το παιχνίδι;'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(); // Close the dialog without leaving the game
                  },
                  child: const Text('Όχι'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context)
                        .pop(); // Close the dialog and leave the game
                  },
                  child: const Text('Ναι'),
                ),
              ],
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          // backgroundColor: Theme.of(context).colorScheme.primary,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.cyan,
          title: Center(
            child: Text(
              'Poli cool',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
        ),
        body: content,
        floatingActionButton: bottomButton,
      ),
    );
  }
}
