import 'package:flutter/cupertino.dart';

class User {
  String name;
  String imageURL;

  User({
    required this.name,
    required this.imageURL,
  });

  static User invalid() => User(
        name: '',
        imageURL: '',
      );

  static User fromJson(Map<String, dynamic> json) => User(
        name: json['name'] as String,
        imageURL: json['imageURL'] as String,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'imageURL': imageURL,
      };
}
