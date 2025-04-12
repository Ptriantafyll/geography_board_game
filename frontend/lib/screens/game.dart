import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          Text('Game ID: ${widget.gameId}'),
          Expanded(
            // todo: add scores
            child: ListView.builder(
              itemCount: widget.players.length,
              itemBuilder: (ctx, index) => PlayerItem(
                player: widget.players[index],
                isGame: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
