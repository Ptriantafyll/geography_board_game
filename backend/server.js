const WebSocket = require("ws");
const { v4: uuidv4 } = require("uuid");
const pool = require("./db");
const redis = require("./redis");

const { createPlayer, deletePlayer } = require("./player");
const { createLobby, deleteLobby, joinLobby, leaveLobby } = require("./lobby");
const {
  startGame,
  submitAnswer,
  showQuestion,
  updateScores,
} = require("./game");

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
          await createPlayer(socket, playerId, data, pool);
          break;
        case "CREATE_LOBBY":
          const lobbyId = uuidv4();
          await createLobby(socket, lobbyId, playerId, data, pool);
          break;
        case "JOIN_LOBBY":
          await joinLobby(socket, data, playerId, pool, clients);
          break;
        case "DELETE_LOBBY":
          await deleteLobby(socket, data, pool);
          break;
        case "LEAVE_LOBBY":
          await leaveLobby(socket, playerId, data, pool);
          break;
        case "DELETE_PLAYER":
          await deletePlayer(socket, playerId, data, pool);
          break;
        case "SHOW_QUESTION":
          await showQuestion(socket, data, pool, clients);
          break;
        case "START_GAME":
          await startGame(socket, data, pool, redis, clients);
          break;
        case "SUBMIT_ANSWER":
          await submitAnswer(socket, playerId, data, pool, redis, clients);
          break;
        case "UPDATE_SCORES":
          await submitAnswer(socket, playerId, data);
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
    await deletePlayer(socket, playerId, { id: "123" }, pool);
    console.log(`Player ${playerId} disconnected`);
  });
});

console.log("Web socket server is running");
