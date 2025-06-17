// Creates a new lobby
async function createLobby(websocket, lobbyId, playerId, data, pool) {
  let lobbyCreatedMessage = JSON.stringify({
    type: "LOBBY_CREATED",
    lobbyId: lobbyId,
    requestId: data.id,
    playerId: playerId,
  });

  try {
    await pool.query("INSERT INTO Lobby (id) VALUES (?)", lobbyId);

    try {
      await pool.query(
        "INSERT INTO Lobby_Player (lobby_id, player_id) VALUES (?, ?)",
        [lobbyId, playerId]
      );
      console.log("Player ", playerId, " joined lobby ", lobbyId);
      console.log("send ", lobbyCreatedMessage);
    } catch (error) {
      console.error("Error Joining lobby", error);
    }

    await websocket.send(lobbyCreatedMessage);
  } catch (error) {
    console.error("Error creating lobby", error);
  }
}

// Lobby deleted when all players have left
async function deleteLobby(websocket, data, pool) {
  try {
    await pool.query("DELETE FROM Lobby WHERE id =?", data.lobbyId);
    console.log("Deleted lobby: ", data.lobbyId);
  } catch (error) {
    console.log("Erorr deleting lobby: ", error);
  }
}

// Player joins lobby
async function joinLobby(websocket, data, 
  playerId, pool, clients) {
  try {
    await pool.query(
      "INSERT INTO Lobby_Player (lobby_id, player_id) VALUES (?, ?)",
      [data.lobbyId, playerId]
    );

    let playersInLobbyResult = await pool.query(
      "SELECT Player.name, Player.color, Player.id FROM Player " +
        "JOIN Lobby_Player ON Player.id = Lobby_Player.player_id " +
        "JOIN Lobby ON Lobby.id = Lobby_Player.lobby_id WHERE Lobby.id =?",
      data.lobbyId
    );

    playersInLobby = playersInLobbyResult[0];

    let playerJoinedMessage = JSON.stringify({
      type: "PLAYER_JOINED",
      playersInLobby: playersInLobby,
      newPlayerId: playerId,
      lobbyId: data.lobbyId,
      requestId: data.id,
    });

    console.log("Player ", playerId, " joined lobby ", data.lobbyId);
    console.log("sending: ", playerJoinedMessage);

    let targetIds = new Set(playersInLobby.map((player) => player.id));
    console.log("targetIds: ", targetIds);

    for (const [playerId, websocket] of clients.entries()) {
      console.log("client id: ", playerId);
      if (targetIds.has(playerId) && websocket.readyState === websocket.OPEN) {
        await websocket.send(playerJoinedMessage);
      }
    }
    // await websocket.send(playerJoinedMessage);
  } catch (error) {
    console.error("Error Joining lobby", error);
    let playerJoinFailedMessage = JSON.stringify({
      type: "PLAYER_JOIN_FAILED",
      requestId: data.id,
    });
    console.log("Sending: ", playerJoinFailedMessage);
    await pool.query("DELETE FROM Player WHERE id=?", playerId);
    await websocket.send(playerJoinFailedMessage);
    return;
  }
}

// player leaves lobby
async function leaveLobby(websocket, playerId, data) {
  try {
    console.log("lobby id: ", data.lobbyId);
    let playersInLobbyResult = await pool.query(
      "SELECT Player.name, Player.color, Player.id FROM Player " +
        "JOIN Lobby_Player ON Player.id = Lobby_Player.player_id " +
        "JOIN Lobby ON Lobby.id = Lobby_Player.lobby_id WHERE Lobby.id =?",
      data.lobbyId
    );

    await pool.query(
      "DELETE FROM Lobby_Player WHERE player_id =? AND lobby_id =?",
      [playerId, data.lobbyId]
    );
    console.log("Player ", playerId, " left lobby ", data.lobbyId);

    let playersInLobby = playersInLobbyResult[0];
    playersInLobby = playersInLobby.filter((player) => player.id !== playerId);

    console.log("Players in lobby: ", playersInLobby);

    if (playersInLobby.length === 0) {
      console.log("No players in lobby, now deleting");
      await deleteLobby(websocket, data.lobbyId);
      return;
    }

    let targetIds = new Set(playersInLobby.map((player) => player.id));
    console.log("targetIds: ", targetIds);

    let playerLeftLobbyMessage = JSON.stringify({
      type: "LEFT_LOBBY",
      requestId: data.id,
      playerId: playerId,
      lobbyId: data.lobbyId,
    });

    // send the message to all players  still in the lobby that a player has left
    for (const [playerId, websocket] of clients.entries()) {
      console.log("client id: ", playerId);
      if (targetIds.has(playerId) && websocket.readyState === websocket.OPEN) {
        await websocket.send(playerLeftLobbyMessage);
      }
    }
  } catch (error) {
    console.log("Erorr leaving lobby: ", error);
  }
}

module.exports = { createLobby, deleteLobby, joinLobby, leaveLobby };
