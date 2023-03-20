import 'package:client_chat/backend/models/track_info_model.dart';
import 'package:flutter/cupertino.dart';

class Channel {
  String id;
  String title;
  //String description
  int activeUsers;
  String imageURL;
  TrackInfo currentTrack;

  Channel({
    required this.id,
    required this.title,
    required this.activeUsers,
    required this.imageURL,
    required this.currentTrack,
  });

  Channel copy({
    String? id,
    String? title,
    int? activeUsers,
    String? imageURL,
    TrackInfo? currentTrack,
  }) =>
      Channel(
        id: id ?? this.id,
        title: title ?? this.title,
        activeUsers: activeUsers ?? this.activeUsers,
        imageURL: imageURL ?? this.imageURL,
        currentTrack: currentTrack ?? this.currentTrack,
      );

  static Channel invalid() => Channel(
        id: '',
        title: '',
        activeUsers: -1,
        imageURL: '',
        currentTrack: TrackInfo.invalid(),
      );
}
