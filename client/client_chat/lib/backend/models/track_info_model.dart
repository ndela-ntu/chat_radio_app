import 'package:client_chat/backend/models/user_model.dart';
import 'package:client_chat/helpers/message_type.dart';

class TrackInfo {
  String title;
  String artist;
  String imageURL;

  TrackInfo({
    required this.title,
    required this.artist,
    required this.imageURL,
  });

  static TrackInfo fromJson(Map<String, dynamic> json) => TrackInfo(
        title: json['title'] as String,
        artist: json['artist'] as String,
        imageURL: json['imageURL'] as String,
      );

  static TrackInfo invalid() =>
      TrackInfo(title: 'Track_Title', artist: 'Track_Artist', imageURL: '');

  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'artist': artist,
        'imageURL': imageURL,
      };
}
