import 'dart:async';
import 'dart:math' as math;

import 'vehicle_data_provider.dart';

final class MockVehicleDataProvider implements VehicleDataProvider {
  final _controller = StreamController<VehicleSnapshot>.broadcast();
  Timer? _timer;
  bool _disposed = false;
  bool _driving = false;
  double _elapsed = 0;
  double _speed = 0;
  VehicleSnapshot _current = const VehicleSnapshot(
    connection: VehicleConnection.disconnected,
  );

  @override
  VehicleSnapshot get current => _current;
  @override
  Stream<VehicleSnapshot> get snapshots => _controller.stream;

  @override
  Future<void> start() async {
    if (_disposed) throw StateError('Provider is disposed');
    if (_timer != null) return;
    _publish();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!_driving) return;
      _elapsed += .1;
      _speed = 48 + math.sin(_elapsed / 8) * 12;
      _publish();
    });
  }

  void setDriving(bool enabled) {
    if (_disposed) throw StateError('Provider is disposed');
    _driving = enabled;
    _speed = enabled ? 48 : 0;
    if (_timer != null) _publish();
  }

  void setSpeed(double speedKmh) {
    if (!speedKmh.isFinite || speedKmh < 0 || speedKmh > 120) {
      throw ArgumentError.value(speedKmh, 'speedKmh', 'Expected 0–120');
    }
    if (_disposed) throw StateError('Provider is disposed');
    _driving = false;
    _speed = speedKmh;
    if (_timer != null) _publish();
  }

  void _publish() {
    _current = VehicleSnapshot(
      connection: VehicleConnection.demo,
      speedKmh: DemoReading(_speed),
      rpm: DemoReading(_speed == 0 ? 800 : 1000 + _speed * 22),
      coolantCelsius: const DemoReading(86),
      voltage: const DemoReading(13.8),
      fuelPercent: const DemoReading(62),
      // Even the mock does not imply Honda gear/body compatibility.
    );
    _controller.add(_current);
  }

  @override
  Future<void> stop() async {
    if (_disposed) return;
    _timer?.cancel();
    _timer = null;
    _driving = false;
    _speed = 0;
    _current = const VehicleSnapshot(
      connection: VehicleConnection.disconnected,
    );
    _controller.add(_current);
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    await stop();
    _disposed = true;
    await _controller.close();
  }
}
