const WebSocket = require("ws");
const { v4: uuidv4 } = require("uuid");
const pool = require("./db");
const redis = require("./redis");

const wss = new WebSocket.Server({ port: 8080 });

// Map to store clients by player id
// todo: for now this is stored in memory, later find a better way
const clients = new Map();

wss.on("connection", async (socket) => {
  console.log("New player connected");
  const playerId = uuidv4();
  console.log("New Player id: ", playerId);
  clients.set(playerId, socket);

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
          await createLobby(socket, lobbyId, playerId, data);
          break;
        case "JOIN_LOBBY":
          await joinLobby(socket, data, playerId);
          break;
        case "DELETE_LOBBY":
          await deleteLobby(socket, data);
          break;
        case "LEAVE_LOBBY":
          await leaveLobby(socket, playerId, data);
          break;
        case "DELETE_PLAYER":
          await deletePlayer(socket, playerId, data);
          break;
        case "START_GAME":
          await startGame(socket, data);
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
    await deletePlayer(socket, playerId, { id: "123" });
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

// Creates a new player
async function deletePlayer(websocket, playerId, data) {
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

// Creates a new lobby
async function createLobby(websocket, lobbyId, playerId, data) {
  let lobbyCreatedMessage = JSON.stringify({
    type: "LOBBY_CREATED",
    lobbyId: lobbyId,
    requestId: data.id,
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

// Player joins lobby
async function joinLobby(websocket, data, playerId) {
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

// Lobby deleted when all players have left
async function deleteLobby(websocket, lobbyId) {
  try {
    await pool.query("DELETE FROM Lobby WHERE id =?", lobbyId);
    console.log("Deleted lobby: ", lobbyId);
  } catch (error) {
    console.log("Erorr deleting lobby: ", error);
  }
}

// Start game
async function startGame(websocket, data) {
  let gameId = uuidv4();
  try {
    await pool.query("INSERT INTO Game (id) VALUES (?)", gameId);

    let playersInLobbyResult = await pool.query(
      "SELECT Player.name, Player.color, Player.id FROM Player " +
        "JOIN Lobby_Player ON Player.id = Lobby_Player.player_id " +
        "JOIN Lobby ON Lobby.id = Lobby_Player.lobby_id WHERE Lobby.id =?",
      data.lobbyId
    );

    playersInLobby = playersInLobbyResult[0];

    let gameStartedMessage = JSON.stringify({
      type: "GAME_STARTED",
      playersInGame: playersInLobby,
      gameId: gameId,
      requestId: data.id,
    });

    let targetIds = new Set(playersInLobby.map((player) => player.id));
    console.log("targetIds: ", targetIds);

    for (const [playerId, websocket] of clients.entries()) {
      console.log("client id: ", playerId);
      if (targetIds.has(playerId) && websocket.readyState === websocket.OPEN) {
        await websocket.send(gameStartedMessage);
      }
    }

    console.log("sent: ", gameStartedMessage);
  } catch (error) {
    console.log("Error starting game: ", error);
  }
}
