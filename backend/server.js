const WebSocket = require("ws");
const { v4: uuidv4 } = require("uuid");

const wss = new WebSocket.Server({ port: 8080 });

wss.on("connection", (socket) => {
  const playerId = uuidv4();
  console.log(`Player ${playerId} connected`);

  socket.on("message", (message) => {
    const data = JSON.parse(message);

    console.log("received: %s", data);
    socket.send("something");
    console.log("sent something");

    if (data.type === "CREATE_LOBBY") {
    }

    if (data.type === "JOIN_LOBBY") {
    }

    if (data.type === "LEAVE_LOBBY") {
    }
  });

  socket.on("close", () => {
    console.log(`Player ${playerId} disconnected`);
  });
});

console.log("Web socket server is running");
