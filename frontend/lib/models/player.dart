import 'package:flutter/material.dart';
import 'package:geography_board_game/models/game_action.dart';

class Player {
  const Player({
    required this.color,
    this.score = 0,
    this.blocksReceived = 0,
    this.actionsAvailable = const [],
  });

  final Color color;
  final int score;
  final int blocksReceived;
  final List<GameAction> actionsAvailable;
}
