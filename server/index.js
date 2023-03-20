require("dotenv").config();
const express = require("express");
const http = require("http");
const Queue = require("./queue.js");
const IOServer = require("socket.io").Server;
const cors = require("cors");

const PORT = process.env.PORT || 5000;
const app = express();
const server = http.createServer(app);
const queue = new Queue();

const corsOptions = {
  origin: "http://localhost:5000",
  optionsSuccessStatus: 200,
};

app.use(cors(corsOptions));

const io = new IOServer(server, {
  cors: {
    origin: "*",
  },
});

(async () => {
  await queue.loadTracks();

  io.on("connection", (socket) => {
    console.log(`User ${socket.id} connected`);
    queue.setSocket(socket);
    socket.emit("connected", true);
    queue.play();

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

  //'http://bbcmedia.ic.llnwd.net/stream/bbcmedia_radio1xtra_mf_p'
  app.get("/stream", (req, res) => {
    const { id, client } = queue.addClient();

    res
      .set({
        "Content-Type": "audio/mp3",
        "Transfer-Encoding": "chunked",
      })
      .status(200);

    client.pipe(res);

    req.on("close", () => {
      queue.removeClient(id);
    });
  });

  app.get("/avatar", async (req, res) => {
    try {
      const s3Data = await queue.getAvatar("amapiano_avatar.jpeg");
      console.log(s3Data);
      res.set({ "Content-Type": "image/jpeg" }).status(200);
      res.write(s3Data, "binary");
      res.end(null, "binary");
    } catch (err) {
      console.log(err);
      res.status(500).send("Error getting object from S3");
    }
  });

  app.get("/status", (req, res) => {
    res.send("Server is running");
  });

  server.listen(PORT, () => {
    console.log(`Server running on port: ${PORT}`);
  });
})();

/*
app.get("/activeUsers/:channelTitle", (req, res) => {
 
  const namespace = io.of('/namespace-1');
  const channel = namespace.adapter.rooms.get(channelTitle);
  const activeUsers = channel ? channel.size : 0;

  res.send({
    'activeUsers': activeUsers
  });
});*/
