import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geography_board_game/providers/websocket_provider.dart';
import 'package:geography_board_game/screens/join_lobby.dart';
import 'package:geography_board_game/screens/new_game.dart';
import 'package:geography_board_game/screens/qr_scanner.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Create a websocket connection when opening the app
    final webSocketNotifier = ref.read(websocketProvider.notifier);

    void onQRScannerLaunch() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => QRScannerScreen(),
        ),
      );
    }

    return Scaffold(
      //todo make this appbar a widget for reusability
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
                  builder: (ctx) => JoinLobbyScreen(fromQRScan: false),
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
            const SizedBox(height: 10),
            IconButton(
              onPressed: onQRScannerLaunch,
              icon: const Icon(Icons.qr_code, size: 48),
            )
          ],
        ),
      ),
    );
  }
}
