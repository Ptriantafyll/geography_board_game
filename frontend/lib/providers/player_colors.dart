import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final colorsProvider = Provider(
  (ref) => [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    // Colors.red,
    // Colors.blue,
    // Colors.green,
    // Colors.yellow,
  ],
);
