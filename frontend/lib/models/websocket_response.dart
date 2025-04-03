import 'dart:convert';

import 'package:geography_board_game/functions/colors.dart';
import 'package:geography_board_game/models/player.dart';

// Defines abstract class for the responses of the websocket connection
sealed class WebsocketResponse {
  final String type;
  const WebsocketResponse({required this.type});
}

class PlayerCreatedResponse extends WebsocketResponse {
  const PlayerCreatedResponse({required this.playerId})
      : super(type: 'PLAYER_CREATED');

  final String playerId;

  // convert JSON to PlayerCreatedResponse object
  factory PlayerCreatedResponse.fromJson(Map<String, dynamic> json) {
    return PlayerCreatedResponse(playerId: json['playerId']);
  }
}

class PlayerDeletedResponse extends WebsocketResponse {
  const PlayerDeletedResponse() : super(type: 'PLAYER_DELETED');
}

class LobbyCreatedResponse extends WebsocketResponse {
  const LobbyCreatedResponse({required this.lobbyId})
      : super(type: 'LOBBY_CREATED');

  final String lobbyId;

  // convert JSON to LobbyCreatedResponse object
  factory LobbyCreatedResponse.fromJson(Map<String, dynamic> json) {
    return LobbyCreatedResponse(lobbyId: json['lobbyId']);
  }
}

class PlayerJoinedResponse extends WebsocketResponse {
  const PlayerJoinedResponse({
    required this.playersInLobby,
    required this.lobbyId,
  }) : super(type: 'PLAYER_JOINED');

  final List<Player> playersInLobby;
  final String lobbyId;

  // convert JSON to PlayerJoinedResponse
  factory PlayerJoinedResponse.fromJson(Map<String, dynamic> json) {
    List<Player> playersInLobby = [];
    for (Map player in json['playersInLobby']) {
      playersInLobby.add(
        Player(
          name: player['name'],
          color: getColorFromString(player['color'])!,
        ),
      );
    }
    return PlayerJoinedResponse(
      playersInLobby: playersInLobby,
      lobbyId: json['lobbyId'],
    );
  }
}

class PlayerJoinFailedResponse extends WebsocketResponse {
  const PlayerJoinFailedResponse() : super(type: 'PLAYER_JOIN_FAILED');
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
      return PlayerDeletedResponse();
    case 'LOBBY_CREATED':
      print(json);
      return LobbyCreatedResponse.fromJson(json);
    case 'PLAYER_JOINED':
      print(json);
      return PlayerJoinedResponse.fromJson(json);
    case 'PLAYER_JOIN_FAILED':
      print(json);
      return PlayerJoinFailedResponse();
    default:
      throw Exception("Unknown message type: ${json['type']}. All Json: $json");
  }
}
