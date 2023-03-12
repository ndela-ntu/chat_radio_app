import 'dart:convert';

import 'package:client_chat/backend/models/chat_message_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  SocketService(this.serverUrl);

  final String serverUrl;
  IO.Socket? _socket;

  Future<void> connect(Function(bool) isConnected) async {
    _socket = IO.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket!.connect();
    _socket!.on('connected', (connected) {
      isConnected(connected);
    });
  }

  void sendMessage(ChatMessage message) {
    if (_socket != null) {
      _socket!.emit('chat_message', jsonEncode(message.toJson()));
    }
  }

  void listenForMessages(Function(ChatMessage) onMessageReceived) {
    if (_socket != null) {
      _socket!.on('message', (data) {
        final chatMessage =
            ChatMessage.fromJson(jsonDecode(data) as Map<String, dynamic>);

        onMessageReceived(chatMessage);
      });
    }
  }

  void joinChannel(String channelName) {
    _socket!.emit('joinChannel', channelName);
  }

  void leaveChannel(String channelName) {
    _socket!.emit('leaveChannel', channelName);
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
    }
  }
}
