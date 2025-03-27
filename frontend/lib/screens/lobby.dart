import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geography_board_game/models/player.dart';
import 'package:geography_board_game/widgets/player_item.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final List<Player> _players = [
    Player(color: Colors.red, name: 'Maria'),
    // Player(color: Colors.blue, name: 'Panos'),
    // Player(color: Colors.green, name: 'Geo'),
    // Player(color: Colors.yellow, name: 'Xrist'),
  ];
  final _channel = WebSocketChannel.connect(
    Uri.parse("ws://localhost:8080"),
  );

  @override
  void initState() {
    // todo: implement initState to have websocket.listen
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
      body: ListView.builder(
        itemCount: _players.length,
        itemBuilder: (ctx, index) => PlayerItem(
          player: _players[index],
        ),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          _channel.sink.add(
            jsonEncode(
              {
                "type": "GAME_START",
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
