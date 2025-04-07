import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geography_board_game/models/player.dart';
import 'package:geography_board_game/models/websocket_response.dart';
import 'package:geography_board_game/providers/websocket_provider.dart';
import 'package:geography_board_game/widgets/player_item.dart';

class LobbyScreen extends ConsumerStatefulWidget {
  const LobbyScreen({
    super.key,
    required this.owner,
    required this.players,
    required this.lobbyId,
  });

  final Player owner;
  final List<Player> players;
  final String lobbyId;

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  late WebsocketNotifier webSocketNotifier;
  List<Player> _players = [];

  @override
  void initState() {
    webSocketNotifier = ref.read(websocketProvider.notifier);
    super.initState();
  }

  @override
  void dispose() async {
    // todo: maybe leave lobby instead of deleting and creating player when starting the app
    // delete player when screen is closed
    webSocketNotifier.deletePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _players = widget.players;
    final lobbyIdWidget = Text('Lobby id: ${widget.lobbyId}');
    final response = ref.watch(websocketProvider);

    if (response is PlayerJoinedResponse) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        String newPlayerName;
        Color newPlayerColor;

        for (var newPlayer in response.playersInLobby) {
          if (!widget.players.any((player) => player.id == newPlayer.id)) {
            newPlayerColor = newPlayer.color;
            newPlayerName = newPlayer.name;
            break;
          }
        }

        final newPlayer = Player(
          color: response.playersInLobby[0].color,
          name: response.playersInLobby[0].name,
        );

        setState(() {
          widget.players.add(newPlayer);
        });

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
          lobbyIdWidget,
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
