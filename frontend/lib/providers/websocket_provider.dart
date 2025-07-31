import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geography_board_game/models/websocket_request.dart';
import 'package:geography_board_game/models/websocket_response.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:uuid/uuid.dart';

var uuid = Uuid();

class WebsocketNotifier extends StateNotifier<WebsocketResponse?> {
  late final WebSocketChannel _channel;
  final Map<String, Completer<bool>> _pendingRequests = {};

  WebsocketNotifier() : super(null) {
    // todo make this work for every network
    // _channel = WebSocketChannel.connect(Uri.parse("ws://192.168.1.230:8080"));
    // _channel = WebSocketChannel.connect(Uri.parse("ws://192.168.1.251:8080"));
    // _channel = WebSocketChannel.connect(Uri.parse("ws://localhost:8080"));
    _channel = WebSocketChannel.connect(Uri.parse("ws://91.99.53.152:8080"));

    _channel.stream.listen(
      _onEvent,
      onError: _onError,
      onDone: _onDone,
    );
  }

  void _onEvent(dynamic message) async {
    if (message == null) return;
    if (message is! String) return;

    try {
      print("Received $message");
      final parsedResponse = parseWebsocketResponse(message);
      print("Parsed response:  $parsedResponse");
      state = parsedResponse;
      final requestId = parsedResponse.requestId;
      if (_pendingRequests.containsKey(requestId)) {
        _pendingRequests[requestId]?.complete(true);
        _pendingRequests.remove(requestId);
      }
      // todo add sendping when receiving pong
      // if (parsedResponse is PongResponse) {
      //   sendPing();
      //   return;
      // }
    } catch (error) {
      print('error decoding message: $error');
    }
  }

  void _onError(dynamic error) {
    print("Got error in message: $error");
  }

  void _onDone() {
    print("Connection closed");
  }

  void reset() {
    state = null;
  }

  Future<bool> createPlayer(String name, Color color) {
    // todo: possibly make this a function and not use it hardcoded everytime
    final requestId = uuid.v4();
    final completer = Completer<bool>();
    _pendingRequests[requestId] = completer;

    final createPlayerRequest =
        CreatePlayerRequest(name: name, color: color, id: requestId);
    _channel.sink.add(jsonEncode(createPlayerRequest.toJson()));

    return completer.future.timeout(const Duration(seconds: 10), onTimeout: () {
      _pendingRequests.remove(requestId);
      throw TimeoutException('Request timed out');
    });
  }

  Future<bool> deletePlayer() {
    final requestId = uuid.v4();
    final completer = Completer<bool>();
    _pendingRequests[requestId] = completer;

    final deletePlayerRequest = DeletePlayerRequest(id: requestId);
    _channel.sink.add(jsonEncode(deletePlayerRequest.toJson()));
    return completer.future.timeout(const Duration(seconds: 10), onTimeout: () {
      _pendingRequests.remove(requestId);
      throw TimeoutException('Request timed out');
    });
  }

  Future<bool> createLobby() {
    final requestId = uuid.v4();
    final completer = Completer<bool>();
    _pendingRequests[requestId] = completer;

    final createLobbyRequest = CreateLobbyRequest(id: requestId);
    _channel.sink.add(jsonEncode(createLobbyRequest.toJson()));
    return completer.future.timeout(const Duration(seconds: 10), onTimeout: () {
      _pendingRequests.remove(requestId);
      throw TimeoutException('Request timed out');
    });
  }

  Future<bool> deleteLobby(lobbyId) {
    final requestId = uuid.v4();
    final completer = Completer<bool>();
    _pendingRequests[requestId] = completer;

    final deleteLobbyRequest =
        DeleteLobbyRequest(lobbyId: lobbyId, id: requestId);
    _channel.sink.add(jsonEncode(deleteLobbyRequest.toJson()));

    return completer.future.timeout(const Duration(seconds: 10), onTimeout: () {
      _pendingRequests.remove(requestId);
      throw TimeoutException('Request timed out');
    });
  }

  Future<bool> joinLobby(lobbyId) {
    final requestId = uuid.v4();
    final completer = Completer<bool>();
    _pendingRequests[requestId] = completer;

    final joinLobbyRequest = JoinLobbyRequest(lobbyId: lobbyId, id: requestId);
    _channel.sink.add(jsonEncode(joinLobbyRequest.toJson()));

    return completer.future.timeout(const Duration(seconds: 10), onTimeout: () {
      _pendingRequests.remove(requestId);
      throw TimeoutException('Request timed out');
    });
  }

  Future<bool> leaveLobby(lobbyId) {
    final requestId = uuid.v4();
    final completer = Completer<bool>();
    _pendingRequests[requestId] = completer;

    final leaveLobbyRequest = LeaveLobbyRequest(
      lobbyId: lobbyId,
      id: requestId,
    );
    _channel.sink.add(jsonEncode(leaveLobbyRequest.toJson()));

    return completer.future.timeout(const Duration(seconds: 10), onTimeout: () {
      _pendingRequests.remove(requestId);
      throw TimeoutException('Request timed out');
    });
  }

  Future<bool> showQuestion(gameId) {
    final requestId = uuid.v4();
    final completer = Completer<bool>();
    _pendingRequests[requestId] = completer;

    final showQuestionRequest = ShowQuestionRequest(
      id: requestId,
      gameId: gameId,
    );
    _channel.sink.add(jsonEncode(showQuestionRequest.toJson()));

    return completer.future.timeout(const Duration(seconds: 10), onTimeout: () {
      _pendingRequests.remove(requestId);
      throw TimeoutException('Request timed out');
    });
  }

  Future<bool> startGame(lobbyId) {
    final requestId = uuid.v4();
    final completer = Completer<bool>();
    _pendingRequests[requestId] = completer;

    final startGameRequest = StartGameRequest(
      lobbyId: lobbyId,
      id: requestId,
    );
    _channel.sink.add(jsonEncode(startGameRequest.toJson()));

    return completer.future.timeout(const Duration(seconds: 10), onTimeout: () {
      _pendingRequests.remove(requestId);
      throw TimeoutException('Request timed out');
    });
  }

  Future<bool> leaveGame(gameId) {
    final requestId = uuid.v4();
    final completer = Completer<bool>();
    _pendingRequests[requestId] = completer;

    final leaveGameRequest = LeaveGameRequest(
      gameId: gameId,
      id: requestId,
    );
    _channel.sink.add(jsonEncode(leaveGameRequest.toJson()));

    return completer.future.timeout(const Duration(seconds: 10), onTimeout: () {
      _pendingRequests.remove(requestId);
      throw TimeoutException('Request timed out');
    });
  }

  Future<bool> submitAnswer(answer, gameId) {
    final requestId = uuid.v4();
    final completer = Completer<bool>();
    _pendingRequests[requestId] = completer;

    final submitAnswerRequest = SubmitAnswerRequest(
      answer: answer,
      id: requestId,
      gameId: gameId,
    );
    _channel.sink.add(jsonEncode(submitAnswerRequest.toJson()));

    return completer.future.timeout(const Duration(seconds: 10), onTimeout: () {
      _pendingRequests.remove(requestId);
      throw TimeoutException('Request timed out');
    });
  }

  Future<bool> showAnswers(gameId) {
    final requestId = uuid.v4();
    final completer = Completer<bool>();
    _pendingRequests[requestId] = completer;

    final showAnswersRequest = ShowAnswersRequest(
      id: requestId,
      gameId: gameId,
    );
    _channel.sink.add(jsonEncode(showAnswersRequest.toJson()));

    return completer.future.timeout(const Duration(seconds: 10), onTimeout: () {
      _pendingRequests.remove(requestId);
      throw TimeoutException('Request timed out');
    });
  }

  Future<bool> showScores(gameId) {
    final requestId = uuid.v4();
    final completer = Completer<bool>();
    _pendingRequests[requestId] = completer;

    final showScoresRequest = ShowScoresRequest(
      id: requestId,
      gameId: gameId,
    );
    _channel.sink.add(jsonEncode(showScoresRequest.toJson()));

    return completer.future.timeout(const Duration(seconds: 10), onTimeout: () {
      _pendingRequests.remove(requestId);
      throw TimeoutException('Request timed out');
    });
  }

  Future<bool> sendPing() async {
    final requestId = uuid.v4();
    final completer = Completer<bool>();
    _pendingRequests[requestId] = completer;
    final pingRequest = PingRequest(id: requestId);

    _channel.sink.add(jsonEncode(pingRequest.toJson()));
    return completer.future.timeout(const Duration(seconds: 10), onTimeout: () {
      _pendingRequests.remove(requestId);
      throw TimeoutException('Request timed out');
    });
  }

  @override
  void dispose() {
    _channel.sink.close(status.normalClosure);
    _pendingRequests.clear();
    super.dispose();
  }
}

final websocketProvider =
    StateNotifierProvider<WebsocketNotifier, WebsocketResponse?>(
  (ref) => WebsocketNotifier(),
);
