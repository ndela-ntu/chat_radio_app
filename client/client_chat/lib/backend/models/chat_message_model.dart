import 'package:client_chat/backend/models/user_model.dart';
import 'package:client_chat/helpers/message_type.dart';

class ChatMessage {
  User user;
  String channelTitle;
  String messageContent;
  MessageType messageType;
  DateTime time;

  ChatMessage({
    required this.user,
    required this.channelTitle,
    required this.messageContent,
    required this.messageType,
    required this.time,
  });

  static ChatMessage fromJson(Map<String, dynamic> json) => ChatMessage(
      user: User.fromJson(json['user']),
      channelTitle: json['channelTitle'] as String,
      messageContent: json['messageContent'] as String,
      messageType: json['messageType'] == 'sender'
          ? MessageType.sender
          : MessageType.recipient,
      time: DateTime.parse(json['time'] as String));

  Map<String, dynamic> toJson() => <String, dynamic>{
        'user': user.toJson(),
        'channelTitle': channelTitle,
        'messageContent': messageContent,
        'messageType': messageType.name,
        'time': time.toString(),
      };
}
