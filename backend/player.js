const { deleteLobby } = require("./lobby");

// Creates a new player
async function createPlayer(websocket, playerId, data, pool) {
  try {
    playerName = data.name;
    playerColor = data.color;
    playerCreatedMessage = JSON.stringify({
      type: "PLAYER_CREATED",
      playerId: playerId,
      requestId: data.id,
    });

    await pool.query("INSERT INTO Player (id, name, color) VALUES (?, ?, ?)", [
      playerId,
      playerName,
      playerColor,
    ]);
    await websocket.send(playerCreatedMessage);
    console.log("sent ", playerCreatedMessage);
  } catch (error) {
    console.error("Error creating Player", error);
  }
}

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
      await deleteLobby(websocket, { lobbyId: lobbyId }, pool);
    }
  } catch (error) {
    console.error("Error deleting Player", error);
  }
}

module.exports = { createPlayer, deletePlayer };
