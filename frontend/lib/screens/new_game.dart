import 'package:flutter/material.dart';
import 'package:geography_board_game/screens/lobby.dart';

class NewGameScreen extends StatefulWidget {
  const NewGameScreen({super.key});

  @override
  State<NewGameScreen> createState() {
    return _NewGameScreenState();
  }
}

class _NewGameScreenState extends State<NewGameScreen> {
  Set<int> selectedNumOfPlayers = {2};
  bool specialPowersSelected = false;

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
            const Text('Αριθμός παικτών'),
            const SizedBox(height: 10),
            SegmentedButton<int>(
              showSelectedIcon: false,
              segments: <ButtonSegment<int>>[
                for (int i = 2; i < 9; i++)
                  ButtonSegment<int>(
                    value: i,
                    label: Text('$i'),
                  ),
              ],
              selected: selectedNumOfPlayers,
              onSelectionChanged: (Set<int> newSelection) {
                setState(() {
                  selectedNumOfPlayers = {newSelection.first};
                });
              },
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Δυνάμεις: '),
                Switch(
                  value: specialPowersSelected,
                  onChanged: (value) {
                    setState(() {
                      specialPowersSelected = value;
                    });
                  },
                )
              ],
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => LobbyScreen(),
                  ),
                );
              },
              child: const Text('Εκκίνηση'),
            )
          ],
        ),
      ),
    );
  }
}
