# Attribution

## Design and icons

The composition and selected navigation, vehicle, phone, volume, playback, and expansion icons are adapted from the user-supplied [Tesla Model 3 (Community) Figma resource](https://www.figma.com/design/naHdaQSkjaDtYL7dUVwS4B/Tesla-Model-3--Community-?node-id=194046-39585). Credit belongs to the original resource's creators, identified by that source file. The file was inspected through Figma's design-to-code integration on 25 October 2026.

The adaptation replaces the vehicle with a Honda, changes proportions for smaller screens, substitutes app panels for unsupported Tesla controls, replaces the map content with actual Malaysian map tiles, and replaces commercial album artwork and recordings with original demo audio. The local `assets/icons/img*.svg` files are exports from that resource. Some SVG shadow filters are unsupported by Flutter's SVG renderer; the underlying icon paths render without those shadows.

Figma's [free Community file licensing guidance](https://help.figma.com/hc/en-us/articles/360042296374-Figma-Community-copyright-and-licensing) specifies [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) for free Community files. Preserve the original creator credits and any additional source-file notices when distributing an adaptation. This package does not include Tesla car images, the reference map image, or commercial album covers.

## Other assets

- `assets/images/honda-city.png` and `honda-city-rear.png`: AI-generated illustrative white Honda City Hatchback cutouts created for this project. It is not an official Honda render.
- `assets/audio/night-drive.wav` and `after-hours.wav`: original synthesized demo audio created for this project. No external recordings are used.
- Montserrat variable font: Google Fonts' Montserrat distribution, licensed under SIL Open Font License 1.1. Copyright and license are retained in `assets/fonts/OFL.txt`. Source: https://github.com/google/fonts/tree/main/ofl/montserrat.
- Map data: © OpenStreetMap contributors, https://www.openstreetmap.org/copyright. Online tiles use https://tile.openstreetmap.org under the public tile policy at https://operations.osmfoundation.org/policies/tiles/.
- Offline schematic: original simplified diagram, not geographical guidance.
- Flutter Material icons: supplied by Flutter's Material icon font. Package and platform dependency licenses are available through Flutter's generated license registry.

Honda, City, Tesla, Model 3, Google Maps, Waze, and Spotify remain the names and marks of their owners. This independent app is not affiliated with those brands.

The driving corridor in version 0.5.0 follows the additional user-supplied [Figma sidebar reference](https://www.figma.com/design/0PhR8D7ZPVCkIASH6SA0Xz/Tesla-Model-3--Community-?node-id=193-6741). The `assets/images/lane-*.png` files are exports of its lane and lighting vector layers, retained unmodified and composited in Flutter. The Honda images replace its Tesla vehicles.
