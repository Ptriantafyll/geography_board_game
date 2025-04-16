import 'package:flutter/material.dart';
import 'package:geography_board_game/functions/colors.dart';

// todo: separate requests into files

// CREATE_PLAYER request
class CreatePlayerRequest {
  const CreatePlayerRequest({
    required this.id,
    required this.name,
    required this.color,
  });

  final String type = 'CREATE_PLAYER';
  final String id;
  final String name;
  final Color color;

  // convert CreatePlayerRequest object to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'id': id,
      'name': name,
      'color': getStringFromColor(color)!.toUpperCase(),
    };
  }
}

// CREATE_LOBBY request
class CreateLobbyRequest {
  const CreateLobbyRequest({required this.id});

  final String type = 'CREATE_LOBBY';
  final String id;

  // convert CreateLobbyRequest object to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'id': id,
    };
  }
}

// JOIN_LOBBY request
class JoinLobbyRequest {
  const JoinLobbyRequest({
    required this.lobbyId,
    required this.id,
  });

  final String type = 'JOIN_LOBBY';
  final String lobbyId;
  final String id;

  // convert joinLobbyRequest object to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'lobbyId': lobbyId,
      'id': id,
    };
  }
}

// DELETE_LOBBY request
class DeleteLobbyRequest {
  const DeleteLobbyRequest({
    required this.lobbyId,
    required this.id,
  });

  final String type = 'DELETE_LOBBY';
  final String lobbyId;
  final String id;

  // convert DeleteLobbyRequest object to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'lobbyId': lobbyId,
      'id': id,
    };
  }
}

// LEAVE_LOBBY request
class LeaveLobbyRequest {
  const LeaveLobbyRequest({
    required this.lobbyId,
    required this.id,
  });

  final String type = 'LEAVE_LOBBY';
  final String lobbyId;
  final String id;

  // convert LeaveLobbyRequest object to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'lobbyId': lobbyId,
      'id': id,
    };
  }
}

// START_GAME request
class StartGameRequest {
  const StartGameRequest({
    required this.lobbyId,
    required this.id,
  });

  final String type = 'START_GAME';
  final String lobbyId;
  final String id;

  // convert StartGameRequest object to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'lobbyId': lobbyId,
      'id': id,
    };
  }
}

// DELETE_PLAYER request
class DeletePlayerRequest {
  const DeletePlayerRequest({required this.id});

  final String type = 'DELETE_PLAYER';
  final String id;

  // convert DeleteLobbyRequest object to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'id': id,
    };
  }
}

// SHOW_QUESTION request
class ShowQuestionRequest {
  const ShowQuestionRequest({
    required this.id,
    required this.gameId,
  });

  final String type = 'SHOW_QUESTION';
  final String gameId;
  final String id;

  // convert DeleteLobbyRequest object to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'id': id,
      'gameId': gameId,
    };
  }
}

// SUBMIT_ANSWER request
class SubmitAnswerRequest {
  const SubmitAnswerRequest({
    required this.id,
    required this.answer,
    required this.gameId,
  });

  final String type = 'SUBMIT_ANSWER';
  final double answer;
  final String gameId;
  final String id;

  // convert DeleteLobbyRequest object to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'id': id,
      'answer': answer,
      'gameId': gameId,
    };
  }
}

// PING request
class PingRequest {
  const PingRequest({required this.id});

  final String type = 'PING';
  final String id;

  // convert PingRequest object to JSON
  Map<String, dynamic> toJson() {
    return {'type': type, 'id': id};
  }
}
