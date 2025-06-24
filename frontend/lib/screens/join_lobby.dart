import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geography_board_game/functions/alert.dart';
import 'package:geography_board_game/providers/player_colors.dart';
import 'package:geography_board_game/screens/lobby.dart';
import 'package:geography_board_game/widgets/color_picker.dart';
import 'package:geography_board_game/providers/websocket_provider.dart';
import 'package:geography_board_game/models/websocket_response.dart';

class JoinLobbyScreen extends ConsumerStatefulWidget {
  const JoinLobbyScreen({
    super.key,
    required this.fromQRScan,
    this.lobbyId = '',
  });

  final bool fromQRScan;
  final String? lobbyId;

  @override
  ConsumerState<JoinLobbyScreen> createState() => _JoinLobbyScreenState();
}

class _JoinLobbyScreenState extends ConsumerState<JoinLobbyScreen> {
  List<Color> _availableColors = [];
  int _selectedIndex = 0;
  final _playerNameController = TextEditingController();
  final _lobbyIdController = TextEditingController();

  void _onJoinLobby() async {
    if (widget.fromQRScan && _playerNameController.text.isEmpty) {
      showAlertDialog(
        'Μη έγκυρα στοιχεία.',
        'Παρακαλώ εισάγετε ένα όνομα.',
        context,
      );
      return;
    }

    if (!widget.fromQRScan &&
        (_lobbyIdController.text.isEmpty ||
            _playerNameController.text.isEmpty)) {
      showAlertDialog(
        'Μη έγκυρα στοιχεία',
        'Παρακαλώ εισάγετε ένα όνομα και το ID του δωματίου',
        context,
      );
      return;
    }

    final webSocketNotifier = ref.read(websocketProvider.notifier);
    await webSocketNotifier.createPlayer(
        _playerNameController.text, _availableColors[_selectedIndex]);

    if (widget.fromQRScan) {
      await webSocketNotifier.joinLobby(widget.lobbyId);
    } else {
      await webSocketNotifier.joinLobby(_lobbyIdController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    _availableColors = ref.read(colorsProvider);
    final response = ref.watch(websocketProvider);

    if (response is PlayerJoinFailedResponse) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAlertDialog('Μη έγκυρο δωμάτιο', 'Το δωμάτιο δε βρέθηκε', context);
        ref.read(websocketProvider.notifier).reset();
      });
    }

    if (response is PlayerJoinedResponse) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (ctx) => LobbyScreen(
              isOwner: false,
              players: response.playersInLobby,
              lobbyId: _lobbyIdController.text,
            ),
          ),
        );
        ref.read(websocketProvider.notifier).reset();
      });
    }

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(10),
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
              if (!widget.fromQRScan) const SizedBox(height: 10),
              if (!widget.fromQRScan)
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
              ),
            ],
          ),
        ),
      ),
      // todo: Add QR Scanner to join lobby
    );
  }
}
