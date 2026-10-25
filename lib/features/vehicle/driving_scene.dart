import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'figma_road_artwork.dart';

class DrivingScene extends StatefulWidget {
  const DrivingScene({super.key, required this.speedKmh});
  final double speedKmh;
  @override
  State<DrivingScene> createState() => _DrivingSceneState();
}

class _DrivingSceneState extends State<DrivingScene>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final Ticker _ticker = createTicker(_tick);
  final ValueNotifier<double> _distance = ValueNotifier(0);
  Duration? _previous;
  bool _foreground = true;

  void _tick(Duration elapsed) {
    final previous = _previous;
    _previous = elapsed;
    if (previous == null) return;
    final seconds = ((elapsed - previous).inMicroseconds / 1000000).clamp(
      0,
      .1,
    );
    _distance.value =
        (_distance.value + seconds * widget.speedKmh / 3.6) % 1200;
  }

  void _syncTicker() {
    final run =
        _foreground &&
        TickerMode.valuesOf(context).enabled &&
        !MediaQuery.disableAnimationsOf(context) &&
        widget.speedKmh > 0;
    if (run && !_ticker.isActive) {
      _previous = null;
      _ticker.start();
    } else if (!run && _ticker.isActive) {
      _ticker.stop();
      _previous = null;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTicker();
  }

  @override
  void didUpdateWidget(DrivingScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTicker();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _syncTicker();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _distance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Simulated driving visualization, not lane or obstacle detection',
    child: RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, size) {
          final compact = size.maxHeight < 220;
          return Stack(
            key: const Key('driving-scene'),
            children: [
              const Positioned.fill(
                child: RepaintBoundary(child: FigmaRoadArtwork()),
              ),
              Positioned.fill(
                child: CustomPaint(
                  key: const Key('moving-road'),
                  painter: RoadPainter(
                    distance: _distance,
                    dark: Theme.of(context).brightness == Brightness.dark,
                  ),
                ),
              ),
              Align(
                alignment: const Alignment(0, -.64),
                child: Opacity(
                  opacity: .3,
                  child: SizedBox(
                    height: size.maxHeight * .13,
                    width: size.maxWidth * .10,
                    child: Image.asset(
                      'assets/images/honda-city-rear.png',
                      key: const Key('demo-lead-car'),
                      fit: BoxFit.contain,
                      semanticLabel:
                          'Illustrative demo vehicle, not detected traffic',
                    ),
                  ),
                ),
              ),
              Align(
                alignment: const Alignment(0, .9),
                child: SizedBox(
                  height: size.maxHeight * .72,
                  width: size.maxWidth * .48,
                  child: Image.asset(
                    'assets/images/honda-city-rear.png',
                    key: const Key('rear-car'),
                    fit: BoxFit.contain,
                    semanticLabel:
                        'White Honda City Hatchback viewed from behind',
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 8,
                right: 8,
                child: Text(
                  'SIMULATED ROAD VIEW',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: compact ? 7 : 8,
                    letterSpacing: 1.3,
                    color: const Color(0xffb3b5ba),
                  ),
                ),
              ),
              Positioned(
                bottom: 4,
                left: 6,
                right: 6,
                child: Text(
                  'No lane or obstacle detection',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: compact ? 7 : 8,
                    color: const Color(0xffb3b5ba),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

/// Distance in metres keeps dash motion continuous when the speed changes.
class RoadPainter extends CustomPainter {
  RoadPainter({required this.distance, required this.dark})
    : super(repaint: distance);
  final ValueListenable<double> distance;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final horizon = size.height * .20;
    final bottom = size.height * .82;
    final center = size.width / 2;
    Offset project(double lane, double depth) {
      final perspective = depth * depth;
      return Offset(
        center + lane * size.width * (.052 + perspective * .19),
        horizon + perspective * (bottom - horizon),
      );
    }

    final corridor = Path()
      ..moveTo(project(-1, 0).dx, horizon)
      ..lineTo(project(1, 0).dx, horizon)
      ..lineTo(project(1, 1).dx, bottom)
      ..lineTo(project(-1, 1).dx, bottom)
      ..close();
    canvas.save();
    canvas.clipPath(corridor);
    final phase = (distance.value / 12) % 1;
    for (var i = 0; i < 4; i++) {
      final depth = (i + phase) / 4;
      final point = project(0, depth);
      final halfWidth = (project(1, depth).dx - center);
      final band = Rect.fromCenter(
        center: point,
        width: halfWidth * 2,
        height: 2 + depth * 12,
      );
      canvas.drawRect(
        band,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.white.withValues(alpha: .025 + depth * .018),
              Colors.transparent,
            ],
          ).createShader(band),
      );
    }
    canvas.restore();
    const background = Color(0xff0e0e0e);
    for (final top in [true, false]) {
      final rect = Rect.fromLTWH(
        0,
        top ? size.height * .10 : size.height * .70,
        size.width,
        size.height * (top ? .18 : .22),
      );
      canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: top
                ? [background, background.withValues(alpha: 0)]
                : [background.withValues(alpha: 0), background],
          ).createShader(rect),
      );
    }
  }

  @override
  bool shouldRepaint(RoadPainter oldDelegate) =>
      oldDelegate.dark != dark || oldDelegate.distance != distance;
}
