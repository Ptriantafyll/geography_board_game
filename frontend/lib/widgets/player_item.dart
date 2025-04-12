import 'package:flutter/material.dart';
import 'package:geography_board_game/models/player.dart';

class PlayerItem extends StatelessWidget {
  const PlayerItem({
    super.key,
    required this.player,
    required this.isGame,
  });

  final Player player;
  final bool isGame;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 24,
            width: 24,
            // color: _players[index].color,
            // person 2 and person 3 could be male/female
            child: Icon(
              Icons.person,
              color: player.color,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            player.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(width: 10),
          isGame ? Text('Score: ${player.score}') : Text('')
        ],
      ),
    );
  }
}
