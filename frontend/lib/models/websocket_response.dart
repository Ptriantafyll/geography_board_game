import 'dart:convert';

import 'package:geography_board_game/functions/colors.dart';
import 'package:geography_board_game/models/player.dart';

// todo: make this abstract and separate the responses into files
// Defines abstract class for the responses of the websocket connection
sealed class WebsocketResponse {
  final String type;
  String get requestId;
  const WebsocketResponse({required this.type});
}

class PlayerCreatedResponse extends WebsocketResponse {
  const PlayerCreatedResponse({required this.playerId, required this.requestId})
      : super(type: 'PLAYER_CREATED');

  final String playerId;
  @override
  final String requestId;

  // convert JSON to PlayerCreatedResponse object
  factory PlayerCreatedResponse.fromJson(Map<String, dynamic> json) {
    return PlayerCreatedResponse(
        playerId: json['playerId'], requestId: json['requestId']);
  }
}

class PlayerDeletedResponse extends WebsocketResponse {
  const PlayerDeletedResponse({
    required this.requestId,
  }) : super(type: 'PLAYER_DELETED');

  @override
  final String requestId;

  factory PlayerDeletedResponse.fromJson(Map<String, dynamic> json) {
    return PlayerDeletedResponse(requestId: json['requestId']);
  }
}

class LobbyCreatedResponse extends WebsocketResponse {
  const LobbyCreatedResponse({
    required this.lobbyId,
    required this.requestId,
  }) : super(type: 'LOBBY_CREATED');

  final String lobbyId;
  @override
  final String requestId;

  // convert JSON to LobbyCreatedResponse object
  factory LobbyCreatedResponse.fromJson(Map<String, dynamic> json) {
    return LobbyCreatedResponse(
      lobbyId: json['lobbyId'],
      requestId: json['requestId'],
    );
  }
}

class LeftLobbyResponse extends WebsocketResponse {
  const LeftLobbyResponse({
    required this.lobbyId,
    required this.requestId,
    required this.playerId,
  }) : super(type: 'LEFT_LOBBY');

  final String lobbyId;
  final String playerId;
  @override
  final String requestId;

  // convert JSON to LeftLobbyResponse object
  factory LeftLobbyResponse.fromJson(Map<String, dynamic> json) {
    return LeftLobbyResponse(
      lobbyId: json['lobbyId'],
      requestId: json['requestId'],
      playerId: json['playerId'],
    );
  }
}

class GameStartedResponse extends WebsocketResponse {
  const GameStartedResponse({
    required this.requestId,
    required this.gameId,
  }) : super(type: 'GAME_STARTED');

  @override
  final String requestId;
  final String gameId;

  // convert JSON to GameStartedResponse object
  factory GameStartedResponse.fromJson(Map<String, dynamic> json) {
    return GameStartedResponse(
      requestId: json['requestId'],
      gameId: json['gameId'],
    );
  }
}

class PlayerJoinedResponse extends WebsocketResponse {
  const PlayerJoinedResponse({
    required this.playersInLobby,
    required this.lobbyId,
    required this.requestId,
    required this.newPlayerId,
  }) : super(type: 'PLAYER_JOINED');

  final List<Player> playersInLobby;
  final String lobbyId;
  @override
  final String requestId;
  final String newPlayerId;

  // convert JSON to PlayerJoinedResponse
  factory PlayerJoinedResponse.fromJson(Map<String, dynamic> json) {
    List<Player> playersInLobby = [];
    for (Map player in json['playersInLobby']) {
      playersInLobby.add(
        Player(
          name: player['name'],
          color: getColorFromString(player['color'])!,
          id: player['id'],
        ),
      );
    }
    return PlayerJoinedResponse(
      playersInLobby: playersInLobby,
      lobbyId: json['lobbyId'],
      requestId: json['requestId'],
      newPlayerId: json['newPlayerId'],
    );
  }
}

class PlayerJoinFailedResponse extends WebsocketResponse {
  const PlayerJoinFailedResponse({required this.requestId})
      : super(type: 'PLAYER_JOIN_FAILED');

  @override
  final String requestId;

  factory PlayerJoinFailedResponse.fromJson(Map<String, dynamic> json) {
    return PlayerJoinFailedResponse(requestId: json['requestId']);
  }
}

class AnswerSubmittedResponse extends WebsocketResponse {
  const AnswerSubmittedResponse({required this.requestId})
      : super(type: 'ANSWER_SUBMITTED');

  @override
  final String requestId;

  factory AnswerSubmittedResponse.fromJson(Map<String, dynamic> json) {
    return AnswerSubmittedResponse(requestId: json['requestId']);
  }
}

class PongResponse extends WebsocketResponse {
  const PongResponse({required this.requestId}) : super(type: 'PONG');
  @override
  final String requestId;

  factory PongResponse.fromJson(Map<String, dynamic> json) {
    return PongResponse(requestId: json['requestId']);
  }
}

// Parse JSON and returnthe correct response type
WebsocketResponse parseWebsocketResponse(String jsonString) {
  final Map<String, dynamic> json = jsonDecode(jsonString);

  switch (json['type']) {
    case 'PLAYER_CREATED':
      print(json);
      return PlayerCreatedResponse.fromJson(json);
    case 'PLAYER_DELETED':
      print(json);
      return PlayerDeletedResponse.fromJson(json);
    case 'LOBBY_CREATED':
      print(json);
      return LobbyCreatedResponse.fromJson(json);
    case 'PLAYER_JOINED':
      print(json);
      return PlayerJoinedResponse.fromJson(json);
    case 'LEFT_LOBBY':
      print(json);
      return LeftLobbyResponse.fromJson(json);
    case 'PLAYER_JOIN_FAILED':
      print(json);
      return PlayerJoinFailedResponse.fromJson(json);
    case 'GAME_STARTED':
      print(json);
      return GameStartedResponse.fromJson(json);
    case 'ANSWER_SUBMITTED':
      print(json);
      return AnswerSubmittedResponse.fromJson(json);
    case 'PONG':
      print(json);
      return PongResponse.fromJson(json);
    default:
      throw Exception("Unknown message type: ${json['type']}. All Json: $json");
  }
}
