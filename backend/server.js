const WebSocket = require("ws");
const { v4: uuidv4 } = require("uuid");
const pool = require("./db");
const redis = require("./redis");

const wss = new WebSocket.Server({ port: 8080 });

wss.on("connection", async (socket) => {
  console.log("New player connected");
  const playerId = uuidv4();

  socket.on("message", async (message) => {
    try {
      const data = JSON.parse(message);
      console.log("received: %s", data);

      switch (data.type) {
        case "CREATE_PLAYER":
          await createPlayer(socket, playerId, data);
          break;
        case "CREATE_LOBBY":
          const lobbyId = uuidv4();
          await createLobby(socket, lobbyId);
          break;
        case "JOIN_LOBBY":
          await joinLobby(socket, data, playerId);
          break;
        case "DELETE_LOBBY":
          await deleteLobby(socket, data);
          break;
        default:
          socket.send(
            JSON.stringify({ type: "ERROR", message: "Unknown action" })
          );
          break;
      }
    } catch (error) {
      console.error("❌ Error processing message:", error);
      socket.send(JSON.stringify({ type: "ERROR", message: error.message }));
    }
  });

  socket.on("close", async () => {
    await deletePlayer(socket, playerId);
    console.log(`Player ${playerId} disconnected`);
  });
});

console.log("Web socket server is running");

// Creates a new player
async function createPlayer(websocket, playerId, data) {
  try {
    playerName = data.name;
    playerColor = data.color;
    playerCreatedMessage = JSON.stringify({
      type: "PLAYER_CREATED",
    });

    await pool.query("INSERT INTO Player (id, name, color) VALUES (?, ?, ?)", [
      playerId,
      playerName,
      playerColor,
    ]);
    await websocket.send(JSON.stringify({ playerCreatedMessage }));
  } catch (error) {
    console.error("Error creating Player", error);
  }
}

// Creates a new player
async function deletePlayer(websocket, playerId) {
  try {
    playerDeletedMessage = JSON.stringify({
      type: "PLAYER_DELETED",
    });

    await pool.query("DELETE FROM Player WHERE id=?", playerId);
    await websocket.send(JSON.stringify({ playerDeletedMessage }));
    console.log("Deleted player ", playerId);
  } catch (error) {
    console.error("Error deleting Player", error);
  }
}

// Creates a new lobby
async function createLobby(websocket, lobbyId) {
  lobbyCreatedMessage = JSON.stringify({
    type: "LOBBY_CREATED",
    lobbyId: lobbyId,
  });

  try {
    await pool.query("INSERT INTO Lobby (id) VALUES (?)", lobbyId);

    try {
      await pool.query(
        "INSERT INTO Lobby_Player (lobby_id, player_id) VALUES (?, ?)",
        [lobbyId, playerId]
      );
      console.log("Player ", playerId, " joined lobby ", lobbyId);
    } catch (error) {
      console.error("Error Joining lobby", error);
    }

    await websocket.send(lobbyCreatedMessage);
  } catch (error) {
    console.error("Error creating lobby", error);
  }
}

// Player joins lobby
async function joinLobby(websocket, data, playerId) {
  try {
    await pool.query(
      "INSERT INTO Lobby_Player (lobby_id, player_id) VALUES (?, ?)",
      [data.lobbyId, playerId]
    );

    playersInLobby = await pool.query(
      "SELECT Player.name, Player.color FROM Player JOIN Lobby_Player ON Player.id = Lobby_Player.player_id JOIN Lobby ON Lobby.id = Lobby_Player.lobby_id WHERE Lobby.id = ?",
      data.lobbyId
    );

    playerJoinedMessage = JSON.stringify({
      type: "PLAYER_JOINED",
      playersInLobby: playersInLobby[0],
    });

    console.log("Player ", playerId, " joined lobby ", data.lobbyId);
    await websocket.send(playerJoinedMessage);
  } catch (error) {
    // console.error("Error Joining lobby", error);
    playerJoinedMessage = JSON.stringify({
      type: "PLAYER_JOIN_FAILED",
    });
    console.log("Sending: ", playerJoinedMessage);
    await websocket.send(playerJoinedMessage);
  }
}

// Lobby deleted when all players have left
async function deleteLobby(websocket, data) {}
