enum ActionType {
  copy,
  block,
  changeDigit,
}

class GameAction {
  const GameAction({required this.type, required this.description});

  final ActionType type;
  final String description;
}
