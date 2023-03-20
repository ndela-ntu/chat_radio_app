require("dotenv").config();
const Throttle = require("throttle");
const uuid = require("uuid").v4;
const { PassThrough } = require("stream");
const AWS = require("aws-sdk");
const { S3Client, GetObjectCommand } = require("@aws-sdk/client-s3");
const { rejects } = require("assert");

const channelName = "amapiano";

module.exports = class Queue {
  constructor() {
    let credentials = {
      accessKeyId: process.env.ACCESS_KEY_ID,
      secretAccessKey: process.env.SECRET_ACCESS_KEY,
    };

    this.tracks = [];
    this.index = 0;
    this.clients = new Map();

    AWS.config.update(credentials);
    this.s3 = new AWS.S3();

    this.s3Client = new S3Client({
      region: "eu-west-1",
      credentials: credentials,
    });
  }

  current() {
    return this.tracks[this.index];
  }

  broadcast(chunk) {
    this.clients.forEach((client) => {
      client.write(chunk);
    });
  }

  addClient() {
    const id = uuid();
    const client = new PassThrough();

    this.clients.set(id, client);
    return { id, client };
  }

  removeClient(id) {
    this.clients.delete(id);
  }

  async loadTracks() {
    let filenames = await this.s3
      .listObjectsV2({
        Bucket: `server-tracks`,
        Prefix: `${channelName}/tracks/`,
        MaxKeys: 30,
      })
      .promise();

    this.tracks = filenames.Contents.map((value) => value.Key);
    this.tracks.shift();
  }

  getNextTrack() {
    if (this.index >= this.tracks.length - 1 || !this.currentTrack) {
      this.index = 0;
    } else {
      this.index = this.index + 1;
    }

    const track = this.tracks[this.index];
    this.currentTrack = track;

    return track;
  }

  pause() {
    if (!this.started() || !this.playing) return;
    this.playing = false;
    this.throttle.removeAllListeners("end");
    this.throttle.end();
  }

  resume() {
    if (!this.started() || this.playing) return;
    this.start();
  }

  started() {
    return this.stream && this.throttle && this.currentTrack;
  }

  async play(useNewTrack = false) {
    if (useNewTrack || !this.currentTrack) {
      this.getNextTrack();
      await this.loadTrackStream();
      this.start();
    } else {
      this.resume();
    }
  }

  async loadTrackStream() {
    const track = this.currentTrack;
    if (!track) return;

    const params = {
      Bucket: "server-tracks",
      Key: `${this.currentTrack}`,
    };

    const command = new GetObjectCommand(params);
    const response = await this.s3Client.send(command);

    const { Body } = response;
    this.stream = Body;
  }

  async start() {
    const track = this.currentTrack;
    if (!track) return;

    this.playing = true;
    this.throttle = new Throttle(128000 / 8);

    setInterval(() => {
      if (this.socket) {
        this.socket.emit(
          "trackInfo",
          this.stringTrackToJson(this.currentTrack)
        );
      }
    }, 7500);

    this.stream
      .pipe(this.throttle)
      .on("data", (chunk) => {
        return this.broadcast(chunk);
      })
      .on("end", async () => {
        await this.play(true);
      })
      .on("error", async () => {
        await this.play(true);
      });
  }

  setSocket(socket) {
    this.socket = socket;
  }

  stringTrackToJson(track) {
    var splitTrack = track.split("-");

    return JSON.stringify({
      title: splitTrack[1].split(".")[0].trim(),
      artist: splitTrack[0].split("/").pop().trim(),
      imageURL: "",
    });
  }

  async getAvatar(objectKey) {
    const params = {
      Bucket: "server-tracks",
      Key: "amapiano/avatar/amapiano_avatar.jpeg",
    };

    const command = new GetObjectCommand(params);

    try {
      const response = await this.s3Client.send(command);
      const byteArray = await response.Body.transformToByteArray();

      return byteArray;
    } catch (err) {
      return rejects(err);
    }
  }
};
