import 'package:flutter/material.dart';

class Question {
  const Question({
    required this.questionText,
    required this.questionAnswer,
    required this.icon,
  });

  final String questionText;
  final double questionAnswer; // All questions have numeric answer
  final Icon icon;
}
