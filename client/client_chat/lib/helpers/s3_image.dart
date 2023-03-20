import 'dart:convert';
import 'package:http/http.dart' as http;

const bucketName = 'server-tracks';
const avatarKey = 'amapiano/avatar/amapiano_avatar.jpeg';

class S3Image {
  final String url;

  S3Image(this.url);

  Future<http.Response> _getImage() async {
    final response = await http.get(Uri.parse("http://localhost:5000/avatar"));
    return response;
  }

  Future<String> getBase64Image() async {
    final response = await _getImage();

    final data = base64Encode(response.bodyBytes);

    return data;
  }
}
