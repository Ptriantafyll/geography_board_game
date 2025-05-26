// Deletes a player
async function deletePlayer(websocket, playerId, data, pool) {
  try {
    playerDeletedMessage = JSON.stringify({
      type: "PLAYER_DELETED",
      requestId: data.id,
    });

    // get the lobby (if any) that the player was in before deleting the player
    let lobbyResult = await pool.query(
      "SELECT lobby_id FROM Lobby_Player WHERE player_id =?",
      playerId
    );

    let lobbyId = "";
    if (lobbyResult[0].length !== 0) {
      lobbyId = lobbyResult[0][0]["lobby_id"];
    }

    await pool.query("DELETE FROM Player WHERE id=?", playerId);
    await websocket.send(playerDeletedMessage);
    console.log("Deleted player ", playerId);
    console.log("Sent ", playerDeletedMessage);

    if (lobbyId === "") {
      console.log("Player had not joined any lobbies");
      return;
    }

    let playersResult = await pool.query(
      "SELECT * FROM Lobby_Player WHERE lobby_id =?",
      lobbyId
    );
    console.log("Players in ", lobbyId, ": ", playersResult);
    console.log("array is empty? ", playersResult[0].length === 0);
    if (playersResult[0].length === 0 && lobbyId !== "") {
      await deleteLobby(websocket, lobbyId);
    }
  } catch (error) {
    console.error("Error deleting Player", error);
  }
}

module.exports = deletePlayer;
