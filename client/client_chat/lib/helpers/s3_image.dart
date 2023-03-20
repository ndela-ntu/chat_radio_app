import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:aws_s3_api/s3-2006-03-01.dart';

const bucketName = 'server-tracks';
const avatarKey = 'amapiano/avatar/amapiano_avatar.jpeg';

class S3Image {
  final String url;
  final S3 _client = S3(
    region: 'eu-west-1',
    credentials: AwsClientCredentials(
      accessKey: 'AKIAW6NI2VNC5JSPBTPQ',
      secretKey: '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',
    ),
  );

  S3Image(this.url);

  Future<http.Response> _getImage() async {
    final response = await http.get(Uri.parse("http://localhost:5000/avatar"));
    return response;
  }

  Future<String> getBase64Image() async {
    final response = await _getImage();

    final data = base64Encode(response.bodyBytes);
    /*GetObjectOutput response = await _client
        .getObject(
      bucket: bucketName,
      key: avatarKey,
    )
        .then((value) => value, onError: () {
      print('Ran into an error');
    });

    Uint8List imageData = response.body!;

    return base64Encode(imageData);*/

    return data;
  }
}
