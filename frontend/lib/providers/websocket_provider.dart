import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geography_board_game/models/websocket_request.dart';
import 'package:geography_board_game/models/websocket_response.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebsocketNotifier extends StateNotifier<WebsocketResponse?> {
  late final WebSocketChannel _channel;

  WebsocketNotifier() : super(null) {
    _channel = WebSocketChannel.connect(Uri.parse("ws://localhost:8080"));

    _channel.stream.listen((message) {
      if (message == null) {
        return;
      }

      try {
        final parsedResponse = parseWebsocketResponse(message);
        state = parsedResponse;
      } catch (error) {
        print('error decoding message: $error');
      }
    });
  }

  CreatePlayerRequest createPlayer(String name, Color color) {
    final createPlayerRequest = CreatePlayerRequest(name: name, color: color);
    _channel.sink.add(jsonEncode(createPlayerRequest.toJson()));
    return createPlayerRequest;
  }

  void deletePlayer() {
    final deletePlayerRequest = DeletePlayerRequest();
    _channel.sink.add(jsonEncode(deletePlayerRequest.toJson()));
  }

  createLobby() {
    final createLobbyRequest = CreateLobbyRequest();
    _channel.sink.add(jsonEncode(createLobbyRequest.toJson()));
    return createLobbyRequest;
  }

  void deleteLobby(lobbyId) {
    final deleteLobbyRequest = DeleteLobbyRequest(lobbyId: lobbyId);
    _channel.sink.add(jsonEncode(deleteLobbyRequest.toJson()));
  }

  JoinLobbyRequest joinLobby(lobbyId) {
    final joinLobbyRequest = JoinLobbyRequest(lobbyId: lobbyId);
    _channel.sink.add(jsonEncode(joinLobbyRequest.toJson()));
    return joinLobbyRequest;
  }

  void removePlayers() {}

  @override
  void dispose() {
    _channel.sink.close(status.normalClosure);
    super.dispose();
  }
}

final websocketProvider =
    StateNotifierProvider<WebsocketNotifier, WebsocketResponse?>(
  (ref) => WebsocketNotifier(),
);
