const express = require("express");
const app = express();
const http = require("http").createServer(app);
const io = require("socket.io")(http);
//const namespace = io.of('/namespace-1');


http.listen(3000, () => {
  console.log("Server started on port 3000");
});

app.get("/", (req, res) => {
  res.send("Server is running");
});

/*app.get("/activeUsers/:channelTitle", (req, res) => {
  const channel = namespace.adapter.rooms.get(channelTitle);
  const activeUsers = channel ? channel.size : 0;

  res.send({
    'activeUsers': activeUsers
  });
});*/

io.on("connection", (socket) => {
  console.log(`User ${socket.id} connected`);
  socket.emit('connected', true);

  socket.on("joinChannel", (channelName) => {
    socket.join(channelName);
    console.log(`User ${socket.id} joined channel: ${channelName}`);
  });

  socket.on("chat_message", (data) => {
    var chat_message = JSON.parse(data);

    console.log(chat_message);

    socket.to(chat_message.channelTitle).emit(
      "message",
      JSON.stringify({
        ...chat_message,
        messageType: "recipient",
      })
    );
  });

  socket.on("leaveChannel", (channelName) => {
    socket.leave(channelName);
    console.log(`User ${socket.id} left channel: ${channelName}`);
  });

  socket.on("disconnect", () => {
    console.log(`User ${socket.id} disconnected`);
  });
});


