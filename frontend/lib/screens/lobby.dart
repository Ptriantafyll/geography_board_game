import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geography_board_game/models/player.dart';
import 'package:geography_board_game/widgets/player_item.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:uuid/uuid.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  // take this from db
  String? _lobbyId;
  final List<Player> _players = [
    Player(color: Colors.red, name: 'Maria'),
    // Player(color: Colors.blue, name: 'Panos'),
    // Player(color: Colors.green, name: 'Geo'),
    // Player(color: Colors.yellow, name: 'Xrist'),
  ];

  Widget? test;

  // connect once to the websocket server
  final _channel = WebSocketChannel.connect(
    Uri.parse("ws://localhost:8080"),
  );

  @override
  void initState() {
    // todo: implement initState to have websocket.listen
    _channel.stream.listen((message) {
      if (message == null) {
        return;
      }

      final messageData = jsonDecode(message);
      if (messageData['type'] == 'LOBBY_CREATED') {
        setState(() {
          _lobbyId = messageData['lobbyId'];
          test = Text('Lobby created with id $_lobbyId');
        });
      }
    });
    // todo: implement backend logic to create lobby, add players etc.
    super.initState();
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

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
      body: Column(
        children: [
          test ?? Text('Lobby not yet created'),
          Expanded(
            child: ListView.builder(
              itemCount: _players.length,
              itemBuilder: (ctx, index) => PlayerItem(
                player: _players[index],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          _channel.sink.add(
            jsonEncode(
              {
                "type": "CREATE_LOBBY",
                // "players": _players.map((player) => player.name).toList(),
              },
            ),
          );
        },
        child: Text('Εκκίνηση παιχνιδιού'),
      ),
    );
  }
}
