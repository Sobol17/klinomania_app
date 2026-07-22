import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app/app.dart';
import 'firebase_options.dart';
import 'src/core/storage/preferences_storage.dart';

const bool kUseApi = bool.fromEnvironment('USE_API', defaultValue: true);
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://186.246.11.247',
);

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();
  final preferencesStorage = SharedPreferencesStorage(sharedPreferences);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    App(
      preferencesStorage: preferencesStorage,
      useApi: kUseApi,
      apiBaseUrl: kApiBaseUrl,
    ),
  );
}
