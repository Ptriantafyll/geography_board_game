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
  GameQuestion? currentQuestion;
  bool showingScores = true;
  bool showingQuestion = false;
  bool answerSubmitted = false;
  bool showingAnswers = false;

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

    // 1. send request
    await webSocketNotifier.submitAnswer(answer, widget.gameId);
    // 2. move to next state (answerSubmitted)
    // todo: remove the following lines after making theresponse from the server
    print(showingScores);
    print(showingQuestion);
    print(answerSubmitted);
    print(showingAnswers);
    setState(() {
      showingScores = false;
      showingQuestion = false;
      answerSubmitted = true;
      showingAnswers = false;
    });
  }

  void handleQuestion() {
    print(showingScores);
    print(showingQuestion);
    print(answerSubmitted);
    print(showingAnswers);
    // todo: get a random question from the db
    print(_questionController.text);

    if (showingScores) {
      // todo: send websocket request to get scores from redis
      showingScores = false;
      showingQuestion = true;
      answerSubmitted = false;
      showingAnswers = false;
    } else if (showingQuestion) {
      // todo: remove this case after everything is set up correctly

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
      // todo: move this in build after checking the response to see if all players have answered
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

    if (response is AnswerSubmittedResponse) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // move to answerSubmitted after getting the response
        showingScores = false;
        showingQuestion = false;
        answerSubmitted = true;
        showingAnswers = false;
        ref.read(websocketProvider.notifier).reset();
      });
    }

    if (response is PlayerAnsweredResponse) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // todo: udpate submitted answers by adding checkmark icon next to player
        ref.read(websocketProvider.notifier).reset();
      });
    }

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

      bottomButton = ElevatedButton(
        onPressed: handleQuestion,
        child: const Text('Next Question'),
      );
    } else if (showingQuestion) {
      content = Center(
        child: QuestionCard(
          gameQuestion: currentQuestion!,
          questionController: _questionController,
          onSubmitAnswer: submitAnswer,
        ),
      );

      bottomButton = null;
    } else if (answerSubmitted) {
      //todo: wait for all players to answer and then continue
      //todo: show check mark for players that have answered
      content = Center(
        child: Text('Answer submitted'),
      );

      bottomButton = null;
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
