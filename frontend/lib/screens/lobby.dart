import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geography_board_game/functions/alert.dart';
import 'package:geography_board_game/models/player.dart';
import 'package:geography_board_game/models/websocket_response.dart';
import 'package:geography_board_game/providers/websocket_provider.dart';
import 'package:geography_board_game/widgets/player_item.dart';

class LobbyScreen extends ConsumerStatefulWidget {
  const LobbyScreen({
    super.key,
    required this.player,
    this.isJoinLobby = false,
    this.lobbyId = '',
  });

  final Player player;
  final bool isJoinLobby;
  final String lobbyId;

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  late WebsocketNotifier webSocketNotifier;
  Widget? lobbyIdWidget;
  List<Player> _players = [];

  @override
  void initState() {
    // todo: maybe create player when starting the app and only joining here
    super.initState();
    webSocketNotifier = ref.read(websocketProvider.notifier);

    Future.microtask(() {
      webSocketNotifier.createPlayer(widget.player.name, widget.player.color);
    });
    // _players.add(Player(color: widget.player.color, name: widget.player.name));
    // print("before players $_players");
    // _players = [Player(color: widget.player.color, name: widget.player.name)];

    if (widget.isJoinLobby) {
      print('ere');
      Future.microtask(() {
        webSocketNotifier.joinLobby(widget.lobbyId);
      });
    } else {
      print('here');
      Future.microtask(() {
        webSocketNotifier.createLobby();
      });
      // todo: add QR code for lobby id
    }
  }

  @override
  void dispose() async {
    // todo: maybe leave lobby instead of deleting and creating player when starting the app
    // delete player when screen is closed
    // ref.read(websocketProvider.notifier).deletePlayer();
    webSocketNotifier.deletePlayer();
    webSocketNotifier.removePlayers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final response = ref.watch(websocketProvider);
    print("players in build $_players");

    if (response is PlayerJoinFailedResponse) {
      Navigator.of(context).pop();
      // todo: do this at lobby screen
      // showAlertDialog('Μη έγκυρο δωμάτιο', 'Το δωμάτιο δε βρέθηκε', context);
      print('player join failed');
    }

    if (response is LobbyCreatedResponse) {
      print('lobby created');
      lobbyIdWidget = Text('Lobby id: ${response.lobbyId}');
      _players = [Player(color: widget.player.color, name: widget.player.name)];
    }

    if (response is PlayerJoinedResponse) {
      print("player joined");
      _players = response.playersInLobby;
      print("players now: $_players");
      lobbyIdWidget = Text('Lobby id: ${response.lobbyId}');
    }

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
          lobbyIdWidget ?? Text('Lobby not yet created'),
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
