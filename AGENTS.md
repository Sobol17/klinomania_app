# Repository Guidelines

## Project Structure & Module Organization

This is a Flutter app named `klinomania`. Application startup lives in `lib/main.dart`, shared initialization in `lib/bootstrap.dart`, and app-level providers/navigation in `lib/app/app.dart`.

Source code follows a feature-first layout under `lib/src/features/<feature>/` with `data`, `domain`, and `presentation` layers. Keep API clients, storage, and theme code in `lib/src/core/`; reusable widgets and helpers belong in `lib/src/shared/`. Static assets are declared in `pubspec.yaml` and stored in `assets/icons/`, `assets/icons/navigation/`, and `assets/images/`. Platform projects live in `android/` and `ios/`. Architecture notes are in `docs/architecture.md`.

## Build, Test, and Development Commands

- `flutter pub get` installs Dart and Flutter dependencies.
- `flutter run` launches the app on the selected simulator, emulator, or device.
- `flutter analyze` runs the analyzer using `analysis_options.yaml`.
- `dart format lib test` formats Dart sources; omit `test` until that directory exists.
- `flutter test` runs unit and widget tests when `test/` is present.
- `flutter build apk` and `flutter build ios` create release builds for Android and iOS.

## Coding Style & Naming Conventions

Use standard Dart formatting: two-space indentation, trailing commas for readable multiline widget trees, and analyzer-clean code. The project uses `package:flutter_lints/flutter.yaml`; do not suppress lints without a local reason.

Name files in `snake_case.dart`. Use `PascalCase` for classes, `camelCase` for members, and feature-specific suffixes already used in the codebase: `*Controller`, `*Repository`, `*RepositoryImpl`, `*RemoteDataSource`, `*Model`, and `*Page`. Keep presentation state in feature controllers using `provider`/`ChangeNotifier` patterns unless a feature documents another approach.

## Testing Guidelines

There is currently no `test/` directory. Add tests alongside new behavior, especially for controllers, repositories, mappers, formatters, and storage/network boundaries. Prefer names like `auth_controller_test.dart` and group cases by method or user flow. Use `flutter_test` for unit and widget tests, then run `flutter test` and `flutter analyze` before submitting changes.

## Commit & Pull Request Guidelines

No local Git history is available in this checkout, so use clear imperative commit subjects such as `Add order history formatter tests` or `Fix OTP validation state`. Keep each commit focused.

Pull requests should include a short summary, testing performed, linked issue or task when available, and screenshots or screen recordings for UI changes. Note any platform-specific impact for `android/`, `ios/`, permissions, assets, or `pubspec.yaml` dependency changes.

## Security & Configuration Tips

Do not commit secrets, tokens, signing keys, or machine-specific files. Keep API configuration centralized in `lib/src/core/network/` and local persistence behind `lib/src/core/storage/` abstractions.
