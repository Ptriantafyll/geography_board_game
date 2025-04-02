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
    required this.player,
    this.isJoinLobby = false,
    this.lobbyId = '',
  });

  final String connectionUri;
  final Player player;
  final bool isJoinLobby;
  final String lobbyId;

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  String? _lobbyId;
  bool _lobbyExistsInDb = false;
  List<Player> _players = [];
  Widget? test;

  // connect once to the websocket server
  final _channel = WebSocketChannel.connect(
    Uri.parse("ws://localhost:8080"),
  );

  void createLobby(WebSocketChannel channel) {
    channel.sink.add(
      jsonEncode({
        "type": "CREATE_LOBBY",
      }),
    );
  }

  void createPlayer(WebSocketChannel channel, String name, Color color) {
    channel.sink.add(
      jsonEncode({
        "type": "CREATE_PLAYER",
        "name": name,
        "color": getStringFromColor(color)!.toUpperCase(),
      }),
    );

    _players.add(
      Player(
        color: color,
        name: name,
      ),
    );
  }

  void joinLobby(WebSocketChannel channel, String name, String color) {
    channel.sink.add(
      jsonEncode({
        "type": "JOIN_LOBBY",
        "lobbyId": widget.lobbyId,
      }),
    );
  }

  void exitOnWrongLobbyId(WebSocketChannel channel) {
    bool lobbyExists = false;

    if (widget.lobbyId.isNotEmpty && _lobbyExistsInDb) {
      lobbyExists = true;
    }

    if (!lobbyExists) {
      Navigator.of(context).pop();
      showAlertDialog('Μη έγκυρο δωμάτιο', 'Το δωμάτιο δε βρέθηκε', context);
    }
  }

  @override
  void initState() {
    super.initState();
    // todo: implement other types
    _channel.stream.listen((message) {
      if (message == null) {
        return;
      }

      final messageData = jsonDecode(message);
      if (messageData['type'] == 'LOBBY_CREATED') {
        setState(() {
          _lobbyId = messageData['lobbyId'];
          test = Text('Lobby id $_lobbyId');
        });
      }

      if (messageData['type'] == 'PLAYER_JOINED') {
        List<Player> playersInLobby = [];
        for (Map player in messageData['playersInLobby']) {
          playersInLobby.add(
            Player(
              name: player['name'],
              color: getColorFromString(player['color'])!,
            ),
          );
        }

        setState(() {
          test = Text('Lobby id ${widget.lobbyId}');
          _lobbyExistsInDb = true;
          _players = playersInLobby;
        });
      }

      if (messageData['type'] == 'PLAYER_JOIN_FAILED') {
        exitOnWrongLobbyId(_channel);
        // todo: if I give a false lobby id it continues, make it fail/return
      }
    }, onError: (error) {
      print("Websocket error: $error");
    }, onDone: () {
      print("Websocket closed");
    });

    createPlayer(_channel, widget.player.name, widget.player.color);
    if (widget.isJoinLobby) {
      joinLobby(
        _channel,
        widget.player.name,
        getStringFromColor(widget.player.color) ?? '',
      );
    } else {
      createLobby(_channel);
      // todo: add QR code for lobby id
    }
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
