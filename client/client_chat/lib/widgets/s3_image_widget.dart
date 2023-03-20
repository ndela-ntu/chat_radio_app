import 'dart:convert';
import 'package:client_chat/helpers/s3_image.dart';
import 'package:flutter/material.dart';

class S3ImageWidget extends StatelessWidget {
  final String imageKey;

  const S3ImageWidget(this.imageKey, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: S3Image(imageKey).getBase64Image(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(
            base64Decode(snapshot.data.toString()),
            fit: BoxFit.cover,
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
