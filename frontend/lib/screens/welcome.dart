import 'package:flutter/material.dart';
import 'package:geography_board_game/screens/join_lobby.dart';
import 'package:geography_board_game/screens/new_game.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // todo: create player here and keep it live until the app is closed

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
            Text(
              'Not implemented',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => NewGameScreen(),
                );
              },
              // style: ElevatedButton.styleFrom(
              //   backgroundColor: Colors.black,
              // ),
              child: const Text("Νέο παιχνίδι"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => JoinLobbyScreen(),
                );
              },
              child: const Text("Συμμετοχή σε δωμάτιο"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              // todo: make the user able to log into an old unfinished game
              child: const Text("Συνέχισε παλιό παιχνίδι"),
            ),
          ],
        ),
      ),
    );
  }
}
