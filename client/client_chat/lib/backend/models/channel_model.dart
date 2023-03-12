import 'package:flutter/cupertino.dart';

class Channel {
  String id;
  String title;
  //String description
  int activeUsers;
  String imageURL;

  Channel({
    required this.id,
    required this.title,
    required this.activeUsers,
    required this.imageURL,
  });

  static Channel invalid() => Channel(
        id: '',
        title: '',
        activeUsers: -1,
        imageURL: '',
      );
}
