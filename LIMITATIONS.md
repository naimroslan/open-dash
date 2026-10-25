# Integration boundaries

## Vehicle data

`MockVehicleDataProvider` emits speed, RPM, coolant temperature, voltage, and fuel level as `DemoReading`. The screen labels demo readings. Turning it off clears the values; pausing the Android activity stops the provider. Gear, doors, locks, bonnet, boot, and tire pressures stay `UnavailableReading` even in demo mode.

`ObdVehicleDataProvider` is a future implementation point. Starting it raises `UnsupportedError`. It cannot claim a connection and sends no commands. There is no Bluetooth, BLE, Wi-Fi, or USB adapter implementation, supported-PID scan, or live Honda data in this release. Read-only diagnostics are the only intended future scope.

A live reading type carries a timestamp, and the telemetry formatter hides values older than three seconds. No live feed is currently connected.

## Factory Honda systems

The app has no camera, CAN bus, climate, lock, or vehicle-control interface. Reverse camera and LaneWatch switching belong to the Honda head unit. Their correct takeover while an AI box is connected has not been established. Original audio, steering-wheel buttons, return to the Honda interface, and boot/shutdown behavior must be tested on the exact box and head unit.

No AI box has been selected, purchased, or validated. Carlinkit and Ottocast candidates from the brief remain unverified. RM300–RM600 is the stated hardware budget, not a verified product price. Do not infer compatibility from the APK build.

## Map, phone, and media

The map uses OpenStreetMap tiles and shows a labeled fixed preview point until a user-requested location fix succeeds. It has no embedded routing, ETA, traffic, or turn guidance. Search hands off to another maps application. The fixed one-time location does not track a moving car. Tile outages leave a schematic rather than a fabricated map. No bulk tile download or prefetch is implemented.

The device's location is used locally to recenter the map. Tile requests reveal the viewed area to the tile provider. No analytics are added by this application.

The media player plays two local original synthesized tracks. It does not control iPhone audio, Apple Music, or Spotify. App shortcuts launch installed Android apps, or their web versions on Mac/web. Hardware audio routing and steering-wheel playback controls are not implemented.

Phone is a setup/help panel. Wi-Fi and Bluetooth buttons open Android settings. Calls, contacts, notifications, and an iOS companion app are not implemented. The iPhone supplies optional hotspot internet; it does not render the dashboard.

## Visuals and deployment

The stationary and rear-view Honda images are generated illustrative cutouts, not official Honda assets or 3D meshes. The moving road and faint vehicle ahead are decorative simulations tied only to demo speed. The small vehicle does not represent detected traffic. It does not detect lanes, nearby traffic, road curvature, or obstacles. Cosmetic trim details can differ. It does not open real or animated vehicle doors. The design follows the supplied Figma composition with explicit Honda adaptations, not a literal copy of unsupported Tesla controls.

Flutter renders the dashboard. Hardware frame rate, touch latency, screen density, GPS, native audio, Android app launches, and factory display takeover need emulator/device testing. Widget tests and desktop renders do not establish those facts.

The release APK is ARM64 and development-signed. Native Mac sources are included; the native Mac build was not validated and CocoaPods was absent on the build machine. Browser preview is the available Mac test route. Custom launcher replacement and boot auto-start are not enabled.
