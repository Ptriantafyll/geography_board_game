import 'package:flutter/material.dart';
import 'package:geography_board_game/functions/websocket.dart';
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
  bool _specialPowersSelected = false;
  final _playerNameController = TextEditingController();
  // final color

  void onCreateLobby() {
    if (_playerNameController.text.isEmpty) {
      showAlertDialog('Μη έγκυρο όνομα',
          'Παρακαλώ είσάγετε ένα έγκυρο όνομα παίκτη', context);
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (ctx) => LobbyScreen(
          connectionUri: "ws://localhost:8080",
          playerName: _playerNameController.text,
          playerColor: 'RED', //todo get this from segmented button
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final webSocketConnection = ref
    //     .read(websocketProvider.notifier)
    //     .connectToWebSocketServer("ws://localhost:8080");

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Δυνάμεις: '),
                  Switch(
                    value: _specialPowersSelected,
                    onChanged: (value) {
                      setState(() {
                        _specialPowersSelected = value;
                      });
                    },
                  )
                ],
              ),
              const Text('Αριθμός παικτών'),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                child: SegmentedButton<int>(
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
              ),
              const SizedBox(height: 10),
              const Text('Όνομα παίκτη'),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: TextField(
                  maxLength: 20,
                  controller: _playerNameController,
                  decoration: InputDecoration(
                    label: Text('Name'),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: onCreateLobby,
                child: const Text('Δημιουργία Δωματίου'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
