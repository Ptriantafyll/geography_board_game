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

module.exports = leaveLobby;
