import 'package:flutter/material.dart';

import '../../services/vehicle_data_provider.dart';
import '../../widgets/telemetry_display.dart';
import 'driving_scene.dart';

class VehicleVisualization extends StatefulWidget {
  const VehicleVisualization({
    super.key,
    required this.data,
    required this.onDetails,
  });
  final VehicleSnapshot data;
  final VoidCallback onDetails;
  @override
  State<VehicleVisualization> createState() => _VehicleVisualizationState();
}

class _VehicleVisualizationState extends State<VehicleVisualization>
    with SingleTickerProviderStateMixin {
  bool tires = false;
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  void _view(bool value) {
    setState(() => tires = value);
    if (MediaQuery.disableAnimationsOf(context)) {
      _motion.value = value ? 1 : 0;
    } else {
      value ? _motion.forward() : _motion.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).hintColor;
    final demo = widget.data.connection == VehicleConnection.demo;
    final speed = switch (widget.data.speedKmh) {
      DemoReading(:final value) when value.isFinite && value > 0 => value,
      _ => 0.0,
    };
    final moving = demo && speed > 0;
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CITY  HATCHBACK',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.4,
                    color: text,
                  ),
                ),
                Text(
                  demo ? 'DEMO' : 'NO OBD',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.3,
                    color: demo ? const Color(0xffe86b70) : text,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          Text(
            readingText(widget.data.speedKmh),
            key: const Key('speed'),
            style: const TextStyle(
              fontSize: 64,
              height: 1,
              fontWeight: FontWeight.w400,
              letterSpacing: -2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
            child: Row(
              children: [
                Text('Gear —', style: TextStyle(color: text, fontSize: 10)),
                const Spacer(),
                Text('km/h', style: TextStyle(color: text, fontSize: 10)),
                const Spacer(),
                Text(
                  demo ? 'Simulated' : 'Unavailable',
                  style: TextStyle(color: text, fontSize: 9),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Stack(
              children: [
                Divider(height: 2, color: Theme.of(context).dividerColor),
                Center(
                  child: Container(
                    width: 22,
                    height: 3,
                    decoration: BoxDecoration(
                      color: demo ? const Color(0xffd43b43) : text,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 500),
              reverseDuration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 350),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: .96, end: 1).animate(animation),
                  child: child,
                ),
              ),
              child: moving
                  ? DrivingScene(
                      key: const ValueKey('driving'),
                      speedKmh: speed,
                    )
                  : LayoutBuilder(
                      key: const Key('parked-scene'),
                      builder: (context, bounds) => Stack(
                        children: [
                          Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    onPressed: () => _view(false),
                                    child: Text(
                                      'Vehicle',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: tires
                                            ? text
                                            : Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => _view(true),
                                    child: Text(
                                      'Tires',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: tires
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.onSurface
                                            : text,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned.fill(
                            top: 40,
                            bottom: 26,
                            child: AnimatedBuilder(
                              animation: _motion,
                              builder: (context, child) => Transform.translate(
                                offset: Offset(0, _motion.value * 5),
                                child: Transform.scale(
                                  scale:
                                      (bounds.maxHeight < 220 ? 1.15 : .95) -
                                      _motion.value * .12,
                                  child: child,
                                ),
                              ),
                              child: Image.asset(
                                'assets/images/honda-city.png',
                                fit: BoxFit.contain,
                                semanticLabel:
                                    'Illustrative white Honda City Hatchback',
                              ),
                            ),
                          ),
                          if (!tires) ...[
                            Positioned(
                              left: 12,
                              top: bounds.maxHeight * .27,
                              child: _Callout(
                                'Bonnet',
                                onTap: widget.onDetails,
                              ),
                            ),
                            Positioned(
                              right: 15,
                              top: bounds.maxHeight * .16,
                              child: _Callout('Boot', onTap: widget.onDetails),
                            ),
                          ] else ...[
                            for (final alignment in [
                              const Alignment(-.8, .2),
                              const Alignment(.65, -.2),
                              const Alignment(-.3, -.35),
                              const Alignment(.5, .6),
                            ])
                              Align(
                                alignment: alignment,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    '— kPa',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ),
                              ),
                          ],
                          Positioned(
                            bottom: 0,
                            left: 8,
                            right: 8,
                            child: Text(
                              tires
                                  ? 'Pressure sensors unavailable'
                                  : 'Doors & locks · unavailable',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 9, color: text),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: TelemetryDisplay(data: widget.data),
          ),
          TextButton(
            onPressed: widget.onDetails,
            child: Text(
              'Vehicle information  ›',
              style: TextStyle(fontSize: 10, color: text),
            ),
          ),
        ],
      ),
    );
  }
}

class _Callout extends StatelessWidget {
  const _Callout(this.label, {required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(4),
    child: Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 9, color: Theme.of(context).hintColor),
          ),
          const SizedBox(height: 3),
          const Text('Unavailable', style: TextStyle(fontSize: 9)),
          const SizedBox(height: 4),
          Container(
            width: 1,
            height: 24,
            color: Theme.of(context).dividerColor,
          ),
        ],
      ),
    ),
  );
}
