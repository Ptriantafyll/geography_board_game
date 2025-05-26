const WebSocket = require("ws");
const { v4: uuidv4 } = require("uuid");
const pool = require("./db");
const redis = require("./redis");
const createPlayer = require("./create_player");
const deletePlayer = require("./delete_player");
const createLobby = require("./create_lobby");
const joinLobby = require("./join_lobby");
const leaveLobby = require("./leave_lobby");

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
          await joinLobby(socket, data, playerId, pool);
          break;
        case "DELETE_LOBBY":
          await deleteLobby(socket, data);
          break;
        case "LEAVE_LOBBY":
          await leaveLobby(socket, playerId, data, pool);
          break;
        case "DELETE_PLAYER":
          await deletePlayer(socket, playerId, data, pool);
          break;
        case "SHOW_QUESTION":
          await showQuestion(socket, data);
          break;
        case "START_GAME":
          await startGame(socket, data);
          break;
        case "SUBMIT_ANSWER":
          await submitAnswer(socket, playerId, data);
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
  try {
    let gameId = uuidv4();
    await pool.query("INSERT INTO Game (id) VALUES (?)", gameId);

    let playersInLobbyResult = await pool.query(
      "SELECT Player.name, Player.color, Player.id FROM Player " +
        "JOIN Lobby_Player ON Player.id = Lobby_Player.player_id " +
        "JOIN Lobby ON Lobby.id = Lobby_Player.lobby_id WHERE Lobby.id =?",
      data.lobbyId
    );

    let playersInLobby = playersInLobbyResult[0];
    console.log("players in lobby: ", playersInLobby);

    for (player of playersInLobby) {
      console.log("player: ", player);
      await pool.query(
        "INSERT INTO Game_Player (game_id, player_id) VALUES (?,?)",
        [gameId, player.id]
      );
      redis.hset(`game:${gameId}:scores`, player.id, 0);
      // creates scores in redis
      console.log("set score 0 for plaer: ", player.id);
    }

    let gameStartedMessage = JSON.stringify({
      type: "GAME_STARTED",
      gameId: gameId,
      requestId: data.id,
    });

    let targetIds = new Set(playersInLobby.map((player) => player.id));
    console.log("targetIds: ", targetIds);

    // todo: make this a function (broadcast?) that takes a lobby/game id
    // todo: and sends a message to all players
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

// submit answer
async function submitAnswer(websocket, playerId, data) {
  // 1. get answer
  let answer = data.answer;
  let gameId = data.gameId;
  // store answer into redis
  await redis.hset(`game:${gameId}:answers`, playerId, answer);

  // 2. get players' answers from redis using gameId
  let answers = await redis.hgetall(`game:${gameId}:answers`);
  console.log("answers before delete: ", answers);

  //  i. get players from sql db (Game_Player will need data.gameId)
  let playersInGameResult = await pool.query(
    "SELECT Player.name, Player.color, Player.id FROM Player " +
      "JOIN Game_Player ON Player.id = Game_Player.player_id " +
      "JOIN Game ON Game.id = Game_Player.game_id WHERE Game.id =?",
    gameId
  );
  let playersInGame = playersInGameResult[0];

  //  ii. create object {} with players
  let playersAnswered = {};
  let playersWithAnswers = {};
  for (let playerInGame of playersInGame) {
    //  iii. "playerID": true/false if answered/not anwered yet (compare with answers from redis)
    let playerHasAnswered = playerInGame.id in answers;
    playersAnswered[playerInGame.id] = playerHasAnswered;

    if (playerInGame.id in answers) {
      // iv. "playerID": answer
      playersWithAnswers[playerInGame.id] = answers[playerInGame.id];
    }
  }

  // 3. respond to player that answered with type "ANSWER_SUBMITTED" and with an array with the players that have answered
  let playerSubmitAnswerMessage = JSON.stringify({
    type: "ANSWER_SUBMITTED",
    playersAnswered: playersAnswered,
    playersWithAnswers: playersWithAnswers,
    requestId: data.id,
  });

  await websocket.send(playerSubmitAnswerMessage);
  console.log("sent: ", playerSubmitAnswerMessage);

  // 4. notify all other players that this player has answered
  let playerAnsweredMessage = JSON.stringify({
    type: "PLAYER_ANSWERED",
    playerAnswered: playerId,
    answer: answer,
    requestId: data.id,
  });

  let targetIds = new Set(playersInGame.map((player) => player.id));
  console.log("targetIds: ", targetIds);

  for (const [player_Id, websocket] of clients.entries()) {
    if (player_Id === playerId) continue;

    if (targetIds.has(player_Id) && websocket.readyState === websocket.OPEN) {
      await websocket.send(playerAnsweredMessage);
    }
  }

  // clear all answers from redis after all players have submitted
  console.log("players with answers: ", playersWithAnswers);
  console.log(
    "players with answers length: ",
    Object.keys(playersWithAnswers).length
  );
  console.log("players in game: ", playersInGame);
  console.log("players in game length: ", playersInGame.length);

  if (Object.keys(playersWithAnswers).length === playersInGame.length) {
    await redis.del(`game:${gameId}:answers`);
    console.log(
      "All players have answered this round. Deleting answers from redis"
    );
  }
}

async function showQuestion(websocket, data) {
  let gameId = data.gameId;

  let numOfQuestionsResult = await pool.query("SELECT COUNT(id) FROM Question");
  let numOfQuestions = numOfQuestionsResult[0][0]["COUNT(id)"];
  let questionId = getRandomInt(numOfQuestions);

  let questionResult = await pool.query(
    "SELECT text, answer FROM Question WHERE id=?",
    questionId
  );

  let questionToSend = {
    text: questionResult[0][0]["text"],
    answer: questionResult[0][0]["answer"].toString(),
  };
  // {
  //   text: "How tall is mount everest? (in meters)",
  //   answer: "8849.0",
  // };

  // 2. get all players in the game
  let playersInGameResult = await pool.query(
    "SELECT Player.name, Player.color, Player.id FROM Player " +
      "JOIN Game_Player ON Player.id = Game_Player.player_id " +
      "JOIN Game ON Game.id = Game_Player.game_id WHERE Game.id =?",
    gameId
  );
  let playersInGame = playersInGameResult[0];

  // 3. send message to all players with the question
  let showQuestionMessage = JSON.stringify({
    type: "QUESTION_SHOWN",
    question: questionToSend,
    requestId: data.id,
  });
  console.log("sending: ", showQuestionMessage);

  let targetIds = new Set(playersInGame.map((player) => player.id));
  console.log("targetIds: ", targetIds);

  for (const [playerId, websocket] of clients.entries()) {
    console.log("client id: ", playerId);
    if (targetIds.has(playerId) && websocket.readyState === websocket.OPEN) {
      await websocket.send(showQuestionMessage);
    }
  }
}

async function updateScores(websocket, data) {
  // 1. get scores from request
  // 2. update scores in redis to add 1 to the round winner
}

function getRandomInt(max) {
  return Math.floor(Math.random() * max) + 1;
}
