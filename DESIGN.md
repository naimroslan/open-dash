# Figma adaptation

Primary reference: [Tesla Model 3 (Community)](https://www.figma.com/design/naHdaQSkjaDtYL7dUVwS4B/Tesla-Model-3--Community-?node-id=194046-39585).

The original frame is 1920 × 1200. Its vehicle sidebar is 580 pixels wide, its map begins at x=580, its bottom toolbar occupies y=1080–1200, and its media strip sits over the lower map at x=593, y=914. The Flutter implementation keeps this composition and uses a 40% vehicle panel for readability on the smaller Honda display. Screen targets are 800 × 480 and 1024 × 600 CSS/logical pixels, not confirmed factory display resolutions.

Inspected Figma nodes:

- `194046:39585`: driving/navigation composition.
- `194046:39587`: sidebar, centered speed, gear strip, telemetry divider, vehicle area.
- `194046:41090`: media strip with title, progress, playback, and expansion.
- `194046:39596`: persistent bottom toolbar.
- `194046:39594`: Navigate overlay.
- `194046:39588`: map-side status strip.
- `194046:39586`: dark map composition.

The UI uses Montserrat, a near-black vehicle background, a dark media surface, restrained red accents, and a black dock. Sheet transitions use Flutter animations rather than WebView styling. System reduced-motion disables sheet animation. Vehicle/Tires transitions change the scale and position of the illustrative render.

Honda adaptations are deliberate. The vehicle image is the generated white City Hatchback cutout from the earlier revision. Tesla's climate, seat heater, defroster, charging, Autopilot, speed-limit, and battery-range controls have been omitted. Dock slots contain functional dashboard panels. Gear and body data stay unavailable. Actual Kuala Lumpur map tiles replace the reference's US map artwork. Original synthesized audio replaces the reference's commercial track and album art.

This is not a rotatable 3D model or a Tesla vehicle-control implementation. Bonnet and boot callouts open vehicle information and report unavailable data. No vehicle command is sent.

## Driving view, version 0.4.0

Positive simulated speed changes the stationary cutout to a centered rear-view Honda on a perspective road. Zero or unavailable speed returns to the stationary composition. A 500ms crossfade with a small scale change connects the scenes. The road is labeled simulated and has no obstacle indicators, cruise controls, or detected-lane claims.

A Flutter ticker integrates simulated speed into distance. The road painter uses that distance to advance its dashed markings toward the viewer while keeping the Honda centered. Speed changes preserve the road phase. The ticker stops when the app is inactive, ticker mode is disabled, or the OS requests reduced motion. Only the custom-painted road repaints each frame; the car remains a separate static image.

## Figma corridor refinement, version 0.5.0

The updated reference is [Sidebar 193:6741](https://www.figma.com/design/0PhR8D7ZPVCkIASH6SA0Xz/Tesla-Model-3--Community-?node-id=193-6741). Its narrow cyan corridor, black fade, low rear-car placement, and soft spotlight replace the previous wide gray multi-lane road. The four lane and spotlight layers are local unmodified exports of backing nodes `497:127947`, `497:127948`, `497:127949`, and `497:127950`. They are composited with a lighten blend to preserve their shared dark matte. Native motion adds subtle traveling light bands without adding dashed lane markings.

A faint small Honda represents an illustrative demo vehicle ahead. It is part of the explicitly simulated scene, not a detected vehicle. The main Honda remains centered and larger in the foreground. The readout and telemetry retain their existing honest source labels; unsupported Tesla warning lights, steering controls, cruise settings, and speed-limit claims are omitted.
