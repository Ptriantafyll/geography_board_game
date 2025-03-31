import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geography_board_game/functions/websocket.dart';
import 'package:geography_board_game/models/player.dart';
import 'package:geography_board_game/providers/player_colors.dart';
import 'package:geography_board_game/screens/lobby.dart';
import 'package:geography_board_game/widgets/color_picker.dart';

class NewGameScreen extends ConsumerStatefulWidget {
  const NewGameScreen({super.key});

  @override
  ConsumerState<NewGameScreen> createState() {
    return _NewGameScreenState();
  }
}

class _NewGameScreenState extends ConsumerState<NewGameScreen> {
  List<Color> _availableColors = [];
  int _selectedIndex = 0;
  final _playerNameController = TextEditingController();
  bool _specialPowersSelected = false;
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
          player: Player(
            color: _availableColors[_selectedIndex],
            name: _playerNameController.text,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _availableColors = ref.read(colorsProvider);
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
              const Text('Όνομα παίκτη'),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: TextField(
                  maxLength: 20,
                  controller: _playerNameController,
                  decoration: InputDecoration(
                    label: Text('Όνομα'),
                  ),
                ),
              ),
              const Text('Χρώμα παίκτη'),
              ColorPicker(
                availableColors: _availableColors,
                onSelectColor: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
              const SizedBox(height: 10),
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
