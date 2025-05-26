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

module.exports = createPlayer;
