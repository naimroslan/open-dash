# Run, build, and test Open Dash

## Run on your Mac before buying hardware

Install Flutter using the [official installation guide](https://docs.flutter.dev/install).

From the project directory, with Flutter on your PATH:

```sh
flutter pub get
flutter run -d chrome
```

This starts Flutter's local preview server. Run this command yourself. Open browser developer tools and choose an 800 × 480 or 1024 × 600 landscape viewport.

For a prebuilt browser preview, extract the web preview archive, then run this command from the extracted directory:

```sh
python3 -m http.server 8080
```

Open `http://localhost:8080` in Chrome. A Flutter web build must be served over HTTP; opening its index file directly is not supported. Geolocation requires localhost or HTTPS. The web preview includes Flutter's web engine locally. Map tiles and external app links require internet.

You can also run the native Mac target with `flutter run -d macos`. Xcode is installed on the development machine, but CocoaPods was not found and the native Mac build was not validated. If Flutter requests CocoaPods, install it with:

```sh
brew install cocoapods
```

## Test the dashboard

- Tap every bottom-dock icon to open its panel. The dock remains visible.
- Open Settings, enable Demo telemetry, then enable Animate demo drive. Close the panel to see the rear-view Honda in a cyan lane corridor with soft lighting and subtle forward motion.
- A manual demo speed above zero also opens the driving view. Set it to zero or turn demo off to return to the stationary view.
- The road and faint car ahead are labeled as a simulated scene. It does not detect lanes, vehicles, or obstacles. System reduced-motion keeps the driving scene static.
- Tap Tires to see unknown pressure values, then Vehicle to return to the car callouts.
- Press Play in the media strip. It plays original local demo audio. Next switches tracks, and the Media panel provides seeking and player volume.
- Tap Navigate and search a destination. Android opens an external maps app; Mac and web open Google Maps.
- Tap the location button on the map to request a one-time device location fix. Denied, blocked, disabled, and timeout states retain the labeled preview location.
- Open Phone for hotspot setup guidance and Android Wi-Fi/Bluetooth settings links. No phone data is embedded.

The clock uses Malaysia time. The initial marker is a fixed Kuala Lumpur preview location, not a live vehicle position.

## Build and install Android

Install Android Studio, SDK Platform 36, Build Tools 36, and NDK `28.2.13676358`. Flutter can download required build components. Check the setup with `flutter doctor -v` and configure the Android SDK path if necessary:

```sh
flutter config --android-sdk "$HOME/Library/Android/sdk"
flutter pub get
flutter build apk --release --target-platform android-arm64
```

The APK is `build/app/outputs/flutter-apk/app-release.apk`. This evaluation release uses Android's development signing key. Create and configure your own signing key before distribution. Application ID is `my.city.dashboard`; version code is 5.

The supplied APK targets ARM64 Android AI boxes and requires Android 8.0 or newer. On an x86 Android emulator, build a debug APK for that emulator instead:

```sh
flutter devices
flutter run -d DEVICE_ID
```

Start the emulator yourself in Android Studio Device Manager, then run the command. Or install on an ARM64 device with USB debugging enabled:

```sh
adb install -r build/app/outputs/flutter-apk/app-release.apk
adb shell am start -n my.city.dashboard/my.city.city_dashboard.MainActivity
```

The app requests internet and optional foreground location access. It requests no camera, microphone, contacts, call, Bluetooth, or OBD permissions. Location is requested only when you tap its map button.

## Project structure

- `lib/app`: Flutter app and appearance.
- `lib/features/dashboard`: screen composition and panel interactions.
- `lib/features/vehicle`: stationary and rear-view Honda scenes, speed-linked road painter, and unavailable body callouts.
- `lib/features/navigation`: interactive map, location handling, and offline schematic.
- `lib/features/media`: local playback controller and map-side media strip.
- `lib/services`: vehicle reading types, mock provider, and future OBD provider.
- `lib/widgets`: persistent dock, Figma icons, and compact telemetry.
- `android`: native host and allowlisted Android app/settings handoff.
- `web`, `macos`: generated Flutter platform targets.
- `test`: provider and widget behavior checks, including both target resolutions.

Run verification with:

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

`pubspec.lock` records the resolved package versions. Flutter 3.47.8 and Dart 3.13.7 were used for this build.

See `LIMITATIONS.md`, `DESIGN.md`, and `THIRD_PARTY.md` for integration boundaries and attribution.
