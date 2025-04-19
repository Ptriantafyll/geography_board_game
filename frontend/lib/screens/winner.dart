import 'package:flutter/material.dart';
import 'package:geography_board_game/models/player.dart';

class WinnerScreen extends StatelessWidget {
  const WinnerScreen({
    super.key,
    required this.winner,
  });

  final Player winner;

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Congratulations ${winner.name}!!!'),
          ],
        ),
      ),
    );
  }
}
