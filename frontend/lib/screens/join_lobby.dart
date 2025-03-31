import 'package:flutter/material.dart';
import 'package:geography_board_game/screens/lobby.dart';

class JoinLobbyScreen extends StatefulWidget {
  const JoinLobbyScreen({super.key});

  @override
  State<JoinLobbyScreen> createState() => _JoinLobbyScreenState();
}

class _JoinLobbyScreenState extends State<JoinLobbyScreen> {
  final _lobbyIdController = TextEditingController();

  void _onJoinLobby() {
    // todo: give lobby id to backend and check if there are any erorrs
    bool lobbyExists = false;

    if (_lobbyIdController.text.isNotEmpty /* && lobby is in db */) {
      lobbyExists = true;
    }

    if (!lobbyExists) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Invalid Input'),
          content: const Text('Lobby not found'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Okay'),
            )
          ],
        ),
      );
      return;
    }

    // todo: add text field for name and color picker
    // Navigator.of(context).pushReplacement(
    //   MaterialPageRoute(
    //     builder: (ctx) => LobbyScreen(
    //       connectionUri: "ws://localhost:8080",
    //       playerName: ,
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
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
