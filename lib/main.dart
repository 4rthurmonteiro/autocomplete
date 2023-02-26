import 'package:autocomplete/src/app.dart';
import 'package:flutter/material.dart';
import 'package:pub_api_client/pub_api_client.dart';

void main() {
  runApp(
    AutoCompleteApp(
      pubClient: PubClient(),
    ),
  );
}
