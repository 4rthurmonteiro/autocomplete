import 'package:autocomplete/src/app.dart';
import 'package:autocomplete/src/packages/local_storage_persistence.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:pub_api_client/pub_api_client.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    AutoCompleteApp(
      pubClient: PubClient(),
      localStoragePersistence: LocalStoragePersistence(),
      eventBus: EventBus(),
    ),
  );
}
