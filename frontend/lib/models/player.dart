import 'package:flutter/material.dart';
import 'package:geography_board_game/models/game_action.dart';

class Player {
  const Player({
    required this.color,
    required this.name,
    this.score = 0,
    this.blocksReceived = 0,
    this.actionsAvailable = const [],
    this.id = '',
    // todo: make players choose their names
  });

  final Color color;
  final String name;
  final int score;
  final int blocksReceived;
  final List<GameAction> actionsAvailable;
  final String id;
}
