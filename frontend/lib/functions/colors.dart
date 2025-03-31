import 'package:flutter/material.dart';

Color? getColorFromString(String colorName) {
  var colorMap = {
    'red': Colors.red,
    'blue': Colors.blue,
    'green': Colors.green,
    'yellow': Colors.yellow,
  };

  return colorMap[colorName.toLowerCase()];
}

String? getStringFromColor(Color color) {
  var colorMap = {
    Colors.red: 'red',
    Colors.blue: 'blue',
    Colors.green: 'green',
    Colors.yellow: 'yellow',
  };

  return colorMap[color];
}
