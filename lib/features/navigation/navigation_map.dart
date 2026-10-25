import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../widgets/dashboard_icon.dart';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' show LatLng;

const previewCenter = LatLng(3.139, 101.6869);

class NavigationMap extends StatefulWidget {
  const NavigationMap({
    super.key,
    required this.onNavigate,
    required this.media,
    this.networkEnabled = true,
  });
  final VoidCallback onNavigate;
  final Widget media;
  final bool networkEnabled;
  @override
  State<NavigationMap> createState() => _NavigationMapState();
}

class _NavigationMapState extends State<NavigationMap> {
  final controller = MapController();
  LatLng center = previewCenter;
  bool located = false, locating = false;
  String status = 'Preview location · no GPS';
  bool tilesLoaded = false, tileError = false;
  void _tileState(bool loaded) {
    if ((loaded && tilesLoaded) || (!loaded && tileError)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          if (loaded) {
            tilesLoaded = true;
          } else {
            tileError = true;
          }
        });
      }
    });
  }

  Future<void> _location() async {
    setState(() {
      locating = true;
      status = 'Requesting device location…';
    });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw StateError('Location is turned off on this device');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        throw StateError('Location blocked. Enable it in device settings.');
      }
      if (permission == LocationPermission.denied) {
        throw StateError('Location permission denied · preview retained');
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      if (!mounted) return;
      setState(() {
        center = LatLng(position.latitude, position.longitude);
        located = true;
        status = 'Device location · one-time fix';
      });
      controller.move(center, 14);
    } catch (error) {
      if (mounted) {
        setState(
          () => status = error is StateError
              ? error.message.toString()
              : 'Location unavailable · preview retained',
        );
      }
    } finally {
      if (mounted) setState(() => locating = false);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _SchematicPainter(dark))),
        if (widget.networkEnabled)
          Positioned.fill(
            child: FlutterMap(
              mapController: controller,
              options: const MapOptions(
                initialCenter: previewCenter,
                initialZoom: 13,
                minZoom: 3,
                maxZoom: 18,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'my.city.dashboard',
                  tileBuilder: (context, image, tile) {
                    if (tile.loadError) _tileState(false);
                    if (tile.loadFinishedAt != null && !tile.loadError) {
                      _tileState(true);
                    }
                    return ColorFiltered(
                      colorFilter: ColorFilter.matrix(
                        dark
                            ? const [
                                -.21,
                                -.5,
                                -.07,
                                0,
                                220,
                                -.21,
                                -.5,
                                -.07,
                                0,
                                230,
                                -.21,
                                -.5,
                                -.07,
                                0,
                                242,
                                0,
                                0,
                                0,
                                1,
                                0,
                              ]
                            : const [
                                .4,
                                .4,
                                .2,
                                0,
                                0,
                                .4,
                                .4,
                                .2,
                                0,
                                0,
                                .4,
                                .4,
                                .2,
                                0,
                                0,
                                0,
                                0,
                                0,
                                1,
                                0,
                              ],
                      ),
                      child: image,
                    );
                  },
                  errorTileCallback: (_, _, _) => _tileState(false),
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: center,
                      width: 32,
                      height: 32,
                      child: const Icon(
                        Icons.navigation,
                        size: 28,
                        color: Color(0xffd43b43),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        if (!widget.networkEnabled)
          const Center(
            child: Icon(Icons.navigation, size: 28, color: Color(0xffd43b43)),
          ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 31,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'CITY',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  located ? 'LOCATION FIX' : 'MAP PREVIEW',
                  style: const TextStyle(color: Colors.white70, fontSize: 8),
                ),
                const Spacer(),
                const _MalaysiaClock(),
              ],
            ),
          ),
        ),
        Positioned(
          top: 39,
          left: 12,
          child: FilledButton.tonalIcon(
            onPressed: widget.onNavigate,
            icon: const DashboardIcon('imgGroup', size: 20),
            label: const Row(
              children: [
                Text('Navigate', style: TextStyle(fontSize: 12)),
                SizedBox(width: 26),
                Icon(Icons.chevron_right, size: 19),
              ],
            ),
            style: FilledButton.styleFrom(
              backgroundColor: dark ? const Color(0xee000000) : Colors.white,
              foregroundColor: dark ? Colors.white70 : Colors.black87,
              minimumSize: const Size(160, 44),
            ),
          ),
        ),
        Positioned(
          top: 40,
          right: 12,
          child: Column(
            children: [
              _MapButton(
                label: locating ? 'Locating' : 'Use device location',
                icon: locating ? Icons.hourglass_top : Icons.my_location,
                onTap: locating ? null : _location,
              ),
              const SizedBox(height: 8),
              _MapButton(
                label: 'Zoom in',
                icon: Icons.add,
                onTap: () {
                  if (widget.networkEnabled) {
                    controller.move(
                      controller.camera.center,
                      (controller.camera.zoom + .5).clamp(3, 18),
                    );
                  }
                },
              ),
              _MapButton(
                label: 'Zoom out',
                icon: Icons.remove,
                onTap: () {
                  if (widget.networkEnabled) {
                    controller.move(
                      controller.camera.center,
                      (controller.camera.zoom - .5).clamp(3, 18),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        Positioned(
          left: 14,
          right: 65,
          bottom: 107,
          child: Text(
            status,
            maxLines: 2,
            style: TextStyle(
              fontSize: 9,
              color: dark ? Colors.white70 : Colors.black87,
              backgroundColor: dark
                  ? const Color(0xcc101317)
                  : const Color(0xddffffff),
            ),
          ),
        ),
        Positioned(left: 10, right: 10, bottom: 20, child: widget.media),
        Positioned(
          bottom: 3,
          left: 8,
          right: 8,
          child: Row(
            children: [
              if (!tilesLoaded)
                Expanded(
                  child: Text(
                    tileError
                        ? 'Tiles unavailable · schematic'
                        : widget.networkEnabled
                        ? 'Loading map tiles…'
                        : 'Offline schematic · not navigation',
                    style: const TextStyle(fontSize: 7),
                  ),
                ),
              const Spacer(),
              const Text(
                '© OpenStreetMap contributors',
                style: TextStyle(fontSize: 7),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton({required this.label, required this.icon, this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).brightness == Brightness.dark
        ? const Color(0xee070707)
        : Colors.white,
    shape: const CircleBorder(),
    child: IconButton(
      tooltip: label,
      onPressed: onTap,
      icon: Icon(icon, size: 21),
    ),
  );
}

class _MalaysiaClock extends StatefulWidget {
  const _MalaysiaClock();
  @override
  State<_MalaysiaClock> createState() => _MalaysiaClockState();
}

class _MalaysiaClockState extends State<_MalaysiaClock> {
  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: Stream.periodic(const Duration(seconds: 30)),
    builder: (_, _) {
      final now = DateTime.now().toUtc().add(const Duration(hours: 8));
      return Text(
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} MYT',
        style: const TextStyle(fontSize: 9, color: Colors.white70),
      );
    },
  );
}

class _SchematicPainter extends CustomPainter {
  _SchematicPainter(this.dark);
  final bool dark;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(
      dark ? const Color(0xff10171f) : const Color(0xffd9e0e2),
      BlendMode.src,
    );
    final road = Paint()
      ..color = dark ? const Color(0xff273444) : const Color(0xffb8c3cd)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final water = Paint()
      ..color = dark ? const Color(0xff174253) : const Color(0xffa8c8d5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16;
    canvas.drawPath(
      Path()
        ..moveTo(size.width * .8, 0)
        ..cubicTo(
          size.width * .4,
          size.height * .4,
          size.width * .9,
          size.height * .5,
          size.width * .5,
          size.height,
        ),
      water,
    );
    for (var i = 0; i < 8; i++) {
      final y = size.height * i / 7;
      canvas.drawPath(
        Path()
          ..moveTo(0, y)
          ..lineTo(size.width * .35, y + 35)
          ..lineTo(size.width * .7, y - 45)
          ..lineTo(size.width, y + 20),
        road,
      );
      final x = size.width * i / 7;
      canvas.drawPath(
        Path()
          ..moveTo(x, 0)
          ..lineTo(x - 35, size.height * .3)
          ..lineTo(x + 20, size.height * .7)
          ..lineTo(x - 20, size.height),
        road,
      );
    }
  }

  @override
  bool shouldRepaint(_SchematicPainter oldDelegate) => oldDelegate.dark != dark;
}
