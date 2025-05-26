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

module.exports = createLobby;
