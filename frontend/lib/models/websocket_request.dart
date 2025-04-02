import 'package:flutter/material.dart';
import 'package:geography_board_game/functions/colors.dart';

// CREATE_PLAYER request
class CreatePlayerRequest {
  const CreatePlayerRequest({
    required this.name,
    required this.color,
  });

  final String type = 'CREATE_PLAYER';
  final String name;
  final Color color;

  // convert CreatePlayerRequest object to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'name': name,
      'color': getStringFromColor(color)!.toUpperCase(),
    };
  }
}

// CREATE_LOBBY request
class CreateLobbyRequest {
  const CreateLobbyRequest();

  final String type = 'CREATE_LOBBY';

  // convert CreateLobbyRequest object to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
    };
  }
}

// JOIN_LOBBY request
class JoinLobbyRequest {
  const JoinLobbyRequest({
    required this.lobbyId,
  });

  final String type = 'JOIN_LOBBY';
  final String lobbyId;

  // convert CreatePlayerRequest object to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'lobbyId': lobbyId,
    };
  }
}

// DELETE_LOBBY request
class DeleteLobbyRequest {
  const DeleteLobbyRequest({
    required this.lobbyId,
  });

  final String type = 'DELETE_LOBBY';
  final String lobbyId;

  // convert CreatePlayerRequest object to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'lobbyId': lobbyId,
    };
  }
}

// DELETE_PLAYER request
class DeletePlayerRequest {
  const DeletePlayerRequest();

  final String type = 'DELETE_PLAYER';

  // convert CreatePlayerRequest object to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
    };
  }
}
