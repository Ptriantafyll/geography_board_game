import 'package:flutter/material.dart';

void showAlertDialog(String title, String message, BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
          },
          child: const Text('ok'),
        )
      ],
    ),
  );
}
