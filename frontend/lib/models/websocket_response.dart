import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geography_board_game/functions/colors.dart';
import 'package:geography_board_game/models/player.dart';
import 'package:geography_board_game/models/question.dart';

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
    required this.playerId,
  }) : super(type: 'LOBBY_CREATED');

  final String lobbyId;
  @override
  final String requestId;
  final String playerId;

  // convert JSON to LobbyCreatedResponse object
  factory LobbyCreatedResponse.fromJson(Map<String, dynamic> json) {
    return LobbyCreatedResponse(
      lobbyId: json['lobbyId'],
      requestId: json['requestId'],
      playerId: json['playerId'],
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

class QuestionShownResponse extends WebsocketResponse {
  const QuestionShownResponse({
    required this.requestId,
    required this.question,
  }) : super(type: 'QUESTION_SHOWN');

  @override
  final String requestId;
  final GameQuestion question;

  factory QuestionShownResponse.fromJson(Map<String, dynamic> json) {
    final gameQuestion = GameQuestion(
      icon: Icon(Icons.question_mark),
      questionText: json['question']['text'],
      questionAnswer: double.parse(json['question']['answer']),
    );

    return QuestionShownResponse(
      requestId: json['requestId'],
      question: gameQuestion,
    );
  }
}

class AnswerSubmittedResponse extends WebsocketResponse {
  const AnswerSubmittedResponse({
    required this.requestId,
    required this.playersWithAnswers,
    required this.playersAnswered,
  }) : super(type: 'ANSWER_SUBMITTED');

  @override
  final String requestId;
  final Map<String, String> playersWithAnswers;
  final Map<String, bool> playersAnswered;

  factory AnswerSubmittedResponse.fromJson(Map<String, dynamic> json) {
    // todo: maybe remove the temp maps and make the other maps <String, dynamic>
    Map<String, dynamic> tempPlayersAnswered = json['playersAnswered'];
    Map<String, bool> tempPlayersAnswered2 = {};

    tempPlayersAnswered.forEach((playerid, hasAnswered) {
      print(playerid);
      print(hasAnswered);
      tempPlayersAnswered2[playerid] = hasAnswered;
    });

    Map<String, dynamic> tempPlayersWithAnswers = json['playersWithAnswers'];
    Map<String, String> tempPlayersWithAnswers2 = {};

    tempPlayersWithAnswers.forEach((playerid, answer) {
      print(playerid);
      print(answer);
      tempPlayersWithAnswers2[playerid] = answer;
    });

    return AnswerSubmittedResponse(
      requestId: json['requestId'],
      playersAnswered: tempPlayersAnswered2,
      playersWithAnswers: tempPlayersWithAnswers2,
    );
  }
}

class PlayerAnsweredResponse extends WebsocketResponse {
  const PlayerAnsweredResponse({
    required this.requestId,
    required this.playerAnswered,
  }) : super(type: 'PLAYER_ANSWERED');

  @override
  final String requestId;
  final String playerAnswered;

  factory PlayerAnsweredResponse.fromJson(Map<String, dynamic> json) {
    return PlayerAnsweredResponse(
      requestId: json['requestId'],
      playerAnswered: json['playerAnswered'],
    );
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
    case 'QUESTION_SHOWN':
      print(json);
      return QuestionShownResponse.fromJson(json);
    case 'ANSWER_SUBMITTED':
      print(json);
      return AnswerSubmittedResponse.fromJson(json);
    case 'PLAYER_ANSWERED':
      print(json);
      return PlayerAnsweredResponse.fromJson(json);
    case 'PONG':
      print(json);
      return PongResponse.fromJson(json);
    default:
      throw Exception("Unknown message type: ${json['type']}. All Json: $json");
  }
}
