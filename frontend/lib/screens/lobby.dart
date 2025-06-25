import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
    // leave lobby when scren is closed
    await webSocketNotifier.leaveLobby(widget.lobbyId);
    // delete player when screen is closed
    await webSocketNotifier.deletePlayer();
    super.dispose();
  }

  void _startGame() {
    webSocketNotifier.startGame(widget.lobbyId);
  }

  @override
  Widget build(BuildContext context) {
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
              isOwner: widget.isOwner,
            ),
          ),
        );

        ref.read(websocketProvider.notifier).reset();
      });
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
          SizedBox(
            height: 300,
            child: widget.players.length <= 4
                ? ListView.builder(
                    itemCount: widget.players.length,
                    itemBuilder: (ctx, index) => PlayerItem(
                      player: widget.players[index],
                      isGame: false,
                    ),
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: widget.players.length,
                    itemBuilder: (ctx, index) => PlayerItem(
                      player: widget.players[index],
                      isGame: false,
                    ),
                  ),
          ),
          const SizedBox(
            height: 10,
          ),
          QrImageView(
            data: widget.lobbyId,
            version: QrVersions.auto,
            size: 200.0,
          ),
        ],
      ),
      // todo: make the owner be able to copy and share the lobby id
      floatingActionButton: widget.isOwner
          ? ElevatedButton(
              onPressed: _startGame,
              child: Text('Εκκίνηση παιχνιδιού'),
            )
          : null,
    );
  }
}
