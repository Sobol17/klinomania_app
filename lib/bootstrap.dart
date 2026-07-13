import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'src/core/storage/preferences_storage.dart';

const bool kUseApi = bool.fromEnvironment('USE_API', defaultValue: true);
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://127.0.0.1:8000',
);

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();
  final preferencesStorage = SharedPreferencesStorage(sharedPreferences);

  runApp(
    App(
      preferencesStorage: preferencesStorage,
      useApi: kUseApi,
      apiBaseUrl: kApiBaseUrl,
    ),
  );
}
