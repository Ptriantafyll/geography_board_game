import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geography_board_game/functions/websocket.dart';
import 'package:geography_board_game/models/player.dart';
import 'package:geography_board_game/providers/player_colors.dart';
import 'package:geography_board_game/screens/lobby.dart';
import 'package:geography_board_game/widgets/color_picker.dart';

class JoinLobbyScreen extends ConsumerStatefulWidget {
  const JoinLobbyScreen({super.key});

  @override
  ConsumerState<JoinLobbyScreen> createState() => _JoinLobbyScreenState();
}

class _JoinLobbyScreenState extends ConsumerState<JoinLobbyScreen> {
  List<Color> _availableColors = [];
  int _selectedIndex = 0;
  final _playerNameController = TextEditingController();

  final _lobbyIdController = TextEditingController();

  void _onJoinLobby() {
    if (_lobbyIdController.text.isEmpty || _playerNameController.text.isEmpty) {
      showAlertDialog(
        'Μη έγκυρα στοιχεία',
        'Παρακαλώ εισάγετε ένα όνομα και το ID του δωματίου',
        context,
      );
      return;
    }

    // todo: add text field for name and color picker
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (ctx) => LobbyScreen(
          connectionUri: "ws://localhost:8080",
          player: Player(
            color: _availableColors[_selectedIndex],
            name: _playerNameController.text,
          ),
          isJoinLobby: true,
          lobbyId: _lobbyIdController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _availableColors = ref.read(colorsProvider);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(50),
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
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  controller: _lobbyIdController,
                  maxLength: 36,
                  decoration: InputDecoration(
                    label: Text('Lobby id'),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _onJoinLobby,
                child: const Text('Συμμετοχή'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
