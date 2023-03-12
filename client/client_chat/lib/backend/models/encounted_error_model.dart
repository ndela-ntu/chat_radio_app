import 'package:flutter/cupertino.dart';

class EncountedError {
  String description;

  EncountedError({
    required this.description,
  });

  bool isValid() => description != '';

  static EncountedError none() => EncountedError(description: '');
}
