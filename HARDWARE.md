# AI box validation

No candidate has been tested with the exact Honda unit. The stated budget is RM300–RM600; this project does not establish current prices or endorse a purchase.

| Candidate from the brief | Status |
| --- | --- |
| Carlinkit TBox Plus, proposed 6GB/128GB or 8GB/128GB | Compatibility, actual configuration, and price unverified |
| Carlinkit TBox Ambient, proposed 8GB/128GB | Compatibility, actual configuration, and price unverified |
| Ottocast OttoAibox P3 | Compatibility, actual configuration, and price unverified |

Before buying, ask the seller to confirm the exact device/firmware supports the factory wired CarPlay interface in a Malaysian 2023 Honda City Hatchback V. Obtain confirmation that it permits custom APK installation, full-screen apps, optional launcher or auto-start configuration, and a usable Bluetooth/BLE interface for third-party adapters. Obtain the return policy for this specific combination if incompatible.

After installation, evaluate while parked:

1. Confirm the app fills the screen and all buttons respond accurately. Record the Android logical viewport and density; 800 × 480 and 1024 × 600 are development targets.
2. Confirm you can return to the box launcher and original Honda interface.
3. Activate reverse and confirm the factory reverse camera takes over. Return to normal display.
4. Activate LaneWatch and confirm its factory view takes over and returns normally.
5. Play local demo audio, open an installed maps app, return to the dashboard, and check the expected audio pause.
6. Test supported steering-wheel controls and factory volume behavior. The dashboard's volume slider controls its own player.
7. Check ignition power-off/on behavior, sleep, startup, and USB reconnection. No custom auto-start is enabled by this APK.
8. Connect the iPhone hotspot and test map tiles. Test the map with location denied before granting location access.
9. Inspect animation frame pacing on the actual device. Desktop/widget tests do not predict its thermal or graphics performance.

OBD comes after the box is validated. Choose an adapter whose Android transport is usable by third-party applications. Verify speed, RPM, coolant, voltage, and fuel support with the actual car before implementing live polling. Keep diagnostic access read-only. Door, lock, bonnet, boot, gear, and pressure data require separate validation and remain unavailable in this release.
