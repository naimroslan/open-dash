# Verification, Flutter 0.5.0

Verified on 25 October 2026 using Flutter 3.47.8, Dart 3.13.7, Android SDK 36, Android Gradle Plugin 9.1.0, Gradle 9.3.1, and Android NDK 28.2.13676358.

## Completed

- Dart formatting completed for all library and test files.
- `flutter analyze --no-pub` completed with no findings.
- `flutter test --no-pub` passed all five tests: provider lifecycle/provenance, dashboard behavior at 800 × 480 and 1024 × 600, and rear-view motion checks at both vehicle-panel sizes.
- Provider checks confirm demo-only telemetry, unsupported body/gear/tire readings, speed validation, animated demo samples, stop/reset behavior, safe repeated lifecycle calls, and an OBD provider that refuses to claim support.
- Widget checks exercise the dock, settings, demo speed, clearing values when demo is off, Phone panel, media state and track changes, destination text entry, Apps panel, and layout error collection.
- Driving-view checks compare actual rendered frames to confirm road motion and a static scene under reduced motion. They also count cyan pixels in the actual rendered scene to verify that the Figma corridor is visible, and confirm that the road artwork does not obscure the speed readout. They verify rear-view entry at moving demo speed, return to the stationary view at zero, and unavailable-data behavior. The dashboard tests also activate the real demo-drive toggle.
- Widget tests render the actual Flutter interface with its vehicle asset and fonts. Both target-size captures were visually inspected and the car geometry adjusted to fit.
- `flutter build apk --release --target-platform android-arm64 --no-pub` completed successfully.
- `flutter build web --release --no-web-resources-cdn --no-pub` completed successfully. The web build config confirms `useLocalCanvasKit: true`.
- APK signature verification completed successfully. Application ID is `my.city.dashboard`, version is 0.5.0, version code is 5, minimum SDK is 26, target SDK is 35, and launcher activity is `my.city.city_dashboard.MainActivity`.
- Figma design context and a screenshot were inspected for the selected composition and its sidebar, media, dock, navigation, status, and map components. The reference screenshot is not a runtime asset. For version 0.5.0, the additional sidebar node 193:6741 and its exact lane/light layer exports were inspected and used.

## Limits of this evidence

The widget tests inject a test media controller. They verify player interaction wiring, not native audio output or decoder behavior. The production media controller uses just_audio with actual bundled WAV files. Native audio must be tested on an Android device or through the web preview.

Widget rendering uses the offline schematic and does not prove online tile loading or browser/Android location permissions. Those runtime paths have explicit loading and failure states but still require platform testing.

No Android emulator, physical Android device, AI box, or factory head unit was run. No frame-rate benchmark was recorded. The native Mac target was not built, and CocoaPods was not installed. The browser bundle was compiled but no preview server was started.

Flutter's SVG renderer reports an unsupported filter in a Figma navigation icon. Its underlying paths render; its optional shadow does not. Source SVGs were retained unchanged. Android dependencies report Java source/target compatibility and deprecation notices; these did not prevent release compilation.
