import 'package:flutter/material.dart';
import 'package:geography_board_game/functions/colors.dart';
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
  final _availableColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
  ];
  int _selectedIndex = 0;
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
            playerColor:
                getStringFromColor(_availableColors[_selectedIndex]) ?? 'Red'),
      ),
    );
  }

  BorderRadius? createBorders(List<Color> colors, index) {
    if (index == colors.length - 1) {
      return BorderRadius.only(
        topRight: Radius.circular(20),
        bottomRight: Radius.circular(20),
      );
    }

    if (index == 0) {
      return BorderRadius.only(
        topLeft: Radius.circular(20),
        bottomLeft: Radius.circular(20),
      );
    }

    return null;
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
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                child: ToggleButtons(
                  isSelected: List.generate(_availableColors.length,
                      (index) => index == _selectedIndex),
                  constraints: BoxConstraints(
                    maxWidth: 40,
                    maxHeight: 40,
                  ),
                  selectedColor: Colors.white,
                  fillColor: _availableColors[_selectedIndex],
                  splashColor: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  borderColor: Colors.black,
                  selectedBorderColor: Colors.black,
                  onPressed: (int index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  children: List.generate(_availableColors.length, (index) {
                    return Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: _availableColors[index],
                        border: Border.all(
                          color: _selectedIndex == index
                              ? Colors.black
                              : Colors.transparent,
                          width: 3,
                        ),
                        borderRadius: createBorders(_availableColors, index),
                      ),
                    );
                  }),
                ),
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
