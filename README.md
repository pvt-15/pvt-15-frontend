# Skogsjakten — Frontend

The Flutter client for **Skogsjakten** ("The Forest Hunt"), a gamified nature‑education app. Players log in, identify plants and animals from photos, play bingo and quizzes, go on treasure hunts (*skattjakter*), complete daily challenges and collect badges.

This repository contains only the Flutter app. It talks to the [Skogsjakten backend](https://github.com/pvt-15/pvt-15-backend) over HTTPS.

## Features

- Account creation and login with email/password, plus **Sign in with Google**
- Photo‑based species identification using the device camera
- Bingo (easy / medium / hard), quizzes and treasure hunts
- Daily challenges and a personal library (animals, plants, daily finds, medals)
- Profile management, profile pictures and gamification (points, levels, badges)
- Runs on Android, iOS, Web, Windows, macOS and Linux from a single codebase

## Requirements

- [Flutter SDK](https://docs.flutter.dev/get-started/install) with Dart SDK **3.11.4** or newer
- A running instance of the [Skogsjakten backend](https://github.com/pvt-15/pvt-15-backend) (the app defaults to the hosted instance at `https://group-6-15.pvt.dsv.su.se`)
- Platform tooling for whichever target you build:
  - **Android:** Android Studio + an emulator or a physical device
  - **iOS / macOS:** Xcode and CocoaPods (`sudo gem install cocoapods`)
  - **Web:** Chrome (or another supported browser)

Verify your setup with:

```bash
flutter doctor
```

## Installation

Clone the repository and fetch dependencies:

```bash
git clone https://github.com/pvt-15/pvt-15-frontend.git
cd pvt-15-frontend
flutter pub get
```

## Configuration

A few things are configured directly in the source rather than through environment files.

### Backend URL

The backend base URL (`https://group-6-15.pvt.dsv.su.se`) is referenced from the service classes under `lib/services/` and several screens under `lib/screens/`. To point the app at a different backend (for example a locally running instance), search for that host and replace it:

```bash
grep -rl "group-6-15.pvt.dsv.su.se" lib
```

The backend is split into three context paths that the app expects to be reachable under the same host:

| Path prefix        | Backend service   |
| ------------------ | ----------------- |
| `/auth-service`    | authentication, users |
| `/storage-service` | image upload / storage |
| `/badges`, `/challenges`, `/pictures`, `/quiz` | app service (root) |

### Google Sign‑In

Google Sign‑In uses a server client ID defined in `lib/screens/login/login.dart`:

```dart
String serverClientId = '<your-server-client-id>.apps.googleusercontent.com';
```

This must match the Google OAuth client configured in the backend. On Android you also need the matching `google-services` / SHA‑1 setup, and on iOS the URL scheme in `ios/Runner`. See the [google_sign_in package docs](https://pub.dev/packages/google_sign_in) for platform setup.

## Usage

Run the app on a connected device or emulator:

```bash
flutter run
```

Pick a specific target with `-d`:

```bash
flutter devices          # list available targets
flutter run -d chrome    # web
flutter run -d android   # an Android device/emulator
```

### Building release artifacts

```bash
flutter build apk        # Android APK
flutter build appbundle  # Android App Bundle (Play Store)
flutter build ios        # iOS (requires Xcode signing)
flutter build web         # Web bundle in build/web
```

### App launcher icons

Icons are generated from `assets/maskot_skogstroll.png` via `flutter_launcher_icons`. Regenerate them after changing the source image:

```bash
dart run flutter_launcher_icons
```

## Project structure

```
lib/
├── main.dart                 # App entry point, theme, initial route logic
├── Authorization/            # User model
├── models/                   # Data models (e.g. treasure hunt)
├── services/                 # Backend calls, session/token storage, camera, uploads
├── screens/                  # UI: login, home, bingo, quiz, library, profile, …
└── widgets/                  # Shared widgets (e.g. navigation bar)
assets/                       # Fonts, mascot images, icons
android/ ios/ web/ macos/ linux/ windows/   # Platform projects
test/                         # Widget tests
```

On launch, `main.dart` checks for a stored, still‑valid token and opens the home screen if the user is already signed in; otherwise it shows the login screen.

## Testing

```bash
flutter test
```

Lint/analyze the code with:

```bash
flutter analyze
```

## Troubleshooting

- **`flutter pub get` fails** — confirm your Dart SDK is 3.11.4+ (`flutter --version`).
- **Login or data calls fail** — make sure the backend is reachable and the configured host is correct; check the device has network access to it.
- **Google Sign‑In fails** — verify the `serverClientId`, that it matches the backend's Google client, and that platform OAuth setup (SHA‑1 / URL scheme) is complete.
- **iOS build issues** — from `ios/` run `pod install`, then build again.

## Contributing

1. Create a branch for your change.
2. Run `flutter analyze` and `flutter test` before opening a pull request.
3. Open a pull request describing what changed and why. For larger changes, open an issue first to discuss.

## Related

- Backend: https://github.com/pvt-15/pvt-15-backend
