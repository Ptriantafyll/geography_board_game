// Player joins lobby
async function joinLobby(websocket, data, playerId, pool) {
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

module.exports = joinLobby;
