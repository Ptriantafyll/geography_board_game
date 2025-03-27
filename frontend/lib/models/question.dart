import 'package:flutter/material.dart';

class GameQuestion {
  const GameQuestion({
    required this.questionText,
    required this.questionAnswer,
    required this.icon,
  });

  final String questionText;
  final double questionAnswer; // All questions have numeric answer
  final Icon icon;
}
