import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geography_board_game/models/player.dart';
import 'package:geography_board_game/models/websocket_response.dart';
import 'package:geography_board_game/providers/websocket_provider.dart';
import 'package:geography_board_game/screens/game.dart';
import 'package:geography_board_game/widgets/player_item.dart';

class LobbyScreen extends ConsumerStatefulWidget {
  const LobbyScreen({
    super.key,
    required this.isOwner,
    required this.players,
    required this.lobbyId,
  });

  final bool isOwner;
  final List<Player> players;
  final String lobbyId;

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  late WebsocketNotifier webSocketNotifier;

  @override
  void initState() {
    webSocketNotifier = ref.read(websocketProvider.notifier);
    super.initState();
  }

  @override
  void dispose() async {
    // todo: maybe leave lobby instead of deleting and creating player when starting the app
    // leave lobby when scren is closed
    webSocketNotifier.leaveLobby(widget.lobbyId);
    // delete player when screen is closed
    webSocketNotifier.deletePlayer();
    super.dispose();
  }

  void _startGame() {
    webSocketNotifier.startGame(widget.lobbyId);
  }

  @override
  Widget build(BuildContext context) {
    final lobbyIdWidget = Text('Lobby id: ${widget.lobbyId}');
    final response = ref.watch(websocketProvider);

    // todo: check player deleted response after leaving lobby

    if (response is PlayerJoinedResponse) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final newPlayer = response.playersInLobby
            .firstWhere((player) => player.id == response.newPlayerId);

        setState(() {
          widget.players.add(newPlayer);
        });

        ref.read(websocketProvider.notifier).reset();
      });
    }

    if (response is LeftLobbyResponse) {
      // todo: if owner left, make another player the owner
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          widget.players
              .removeWhere((player) => player.id == response.playerId);
        });

        ref.read(websocketProvider.notifier).reset();
      });
    }

    if (response is GameStartedResponse) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // todo: replace with pushReplacement after adding player to be on app level
        // todo: add rejoin functionality
        Navigator.of(context).push(
          MaterialPageRoute(
            // todo: make game have an owner as well
            builder: (ctx) => GameScreen(
              gameId: response.gameId,
              players: widget.players,
            ),
          ),
        );

        ref.read(websocketProvider.notifier).reset();
      });
    }

    return Scaffold(
      appBar: AppBar(
        // todo: add actions for QR scan?
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
          lobbyIdWidget,
          Expanded(
            child: ListView.builder(
              itemCount: widget.players.length,
              itemBuilder: (ctx, index) => PlayerItem(
                player: widget.players[index],
                isGame: false,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: widget.isOwner
          ? ElevatedButton(
              onPressed: _startGame,
              child: Text('Εκκίνηση παιχνιδιού'),
            )
          : null,
    );
  }
}
