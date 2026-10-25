/// Provenance belongs to each reading so mixed or missing feeds stay explicit.
sealed class VehicleReading<T> {
  const VehicleReading();
}

final class UnavailableReading<T> extends VehicleReading<T> {
  const UnavailableReading(this.reason);
  final String reason;
}

final class DemoReading<T> extends VehicleReading<T> {
  const DemoReading(this.value);
  final T value;
}

final class LiveReading<T> extends VehicleReading<T> {
  const LiveReading(this.value, {required this.sampledAt});
  final T value;
  final DateTime sampledAt;
}

enum Gear { park, reverse, neutral, drive }

enum VehicleConnection {
  demo,
  disconnected,
  connecting,
  connected,
  unsupported,
}

final class VehicleSnapshot {
  const VehicleSnapshot({
    required this.connection,
    this.speedKmh = const UnavailableReading('No speed feed'),
    this.rpm = const UnavailableReading('No engine speed feed'),
    this.coolantCelsius = const UnavailableReading('No coolant feed'),
    this.voltage = const UnavailableReading('No voltage feed'),
    this.fuelPercent = const UnavailableReading('No fuel level feed'),
    this.gear = const UnavailableReading('Gear position not verified'),
    this.doors = const UnavailableReading('Honda body data not verified'),
    this.locks = const UnavailableReading('Honda lock data not verified'),
    this.bonnet = const UnavailableReading('Bonnet sensor not verified'),
    this.boot = const UnavailableReading('Boot sensor not verified'),
    this.tirePressuresKpa = const UnavailableReading(
      'No verified pressure sensors',
    ),
  });

  final VehicleConnection connection;
  final VehicleReading<double> speedKmh;
  final VehicleReading<double> rpm;
  final VehicleReading<double> coolantCelsius;
  final VehicleReading<double> voltage;
  final VehicleReading<double> fuelPercent;
  final VehicleReading<Gear> gear;
  final VehicleReading<bool> doors;
  final VehicleReading<bool> locks;
  final VehicleReading<bool> bonnet;
  final VehicleReading<bool> boot;
  final VehicleReading<List<double>> tirePressuresKpa;
}

abstract interface class VehicleDataProvider {
  VehicleSnapshot get current;
  Stream<VehicleSnapshot> get snapshots;
  Future<void> start();
  Future<void> stop();
  Future<void> dispose();
}
