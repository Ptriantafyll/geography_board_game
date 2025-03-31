import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geography_board_game/functions/colors.dart';
import 'package:geography_board_game/functions/websocket.dart';
import 'package:geography_board_game/models/player.dart';
import 'package:geography_board_game/widgets/player_item.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:uuid/uuid.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({
    super.key,
    required this.connectionUri,
    required this.playerName,
    required this.playerColor,
  });

  final String connectionUri;
  final String playerName;
  final String playerColor;

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  String? _lobbyId;
  final List<Player> _players = [
    // Player(color: Colors.red, name: 'Maria'),
    // Player(color: Colors.blue, name: 'Panos'),
    // Player(color: Colors.green, name: 'Geo'),
    // Player(color: Colors.yellow, name: 'Xrist'),
  ];

  Widget? test;

  // connect once to the websocket server
  final _channel = WebSocketChannel.connect(
    Uri.parse("ws://localhost:8080"),
  );

  void createLobby(channel) async {
    if (channel == null) {
      showAlertDialog('Error', 'Websocketconnection fialed', context);
      return;
    }

    await channel.sink.add(
      jsonEncode({
        "type": "CREATE_LOBBY",
      }),
    );
  }

  void createPlayer(channel, String name, String color) async {
    if (channel == null) {
      showAlertDialog('Error', 'Websocketconnection fialed', context);
      return;
    }

    await channel.sink.add(
      jsonEncode({
        "type": "CREATE_PLAYER",
        "name": name,
        "color": color,
      }),
    );

    _players.add(
      Player(
        color: getColorFromString(widget.playerColor) ?? Colors.red,
        name: widget.playerName,
      ),
    );
  }

  @override
  void initState() {
    // todo: implement other types
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

    createPlayer(_channel, widget.playerName, widget.playerColor);
    createLobby(_channel);
    // todo: implement backend logic to create lobby, add players etc.
    super.initState();
  }

  @override
  void dispose() {
    // close the connection when the screen is closed
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
        onPressed: () {},
        child: Text('Εκκίνηση παιχνιδιού'),
      ),
    );
  }
}
