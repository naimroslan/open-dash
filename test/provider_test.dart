import 'package:flutter_test/flutter_test.dart';
import 'package:city_dashboard/services/mock_vehicle_provider.dart';
import 'package:city_dashboard/services/obd_vehicle_provider.dart';
import 'package:city_dashboard/services/vehicle_data_provider.dart';

void check(bool condition, String message) {
  if (!condition) throw StateError(message);
}

void main() {
  test('Provider provenance and lifecycle', () async {
    final provider = MockVehicleDataProvider();
    final updates = <VehicleSnapshot>[];
    final subscription = provider.snapshots.listen(updates.add);
    check(
      provider.current.speedKmh is UnavailableReading,
      'No values before start',
    );
    await provider.start();
    await provider.start();
    provider.setSpeed(65);
    await Future<void>.delayed(Duration.zero);
    check(
      (provider.current.speedKmh as DemoReading<double>).value == 65,
      'Speed control',
    );
    check(
      (provider.current.rpm as DemoReading<double>).value == 2430,
      'RPM demo',
    );
    check(
      provider.current.coolantCelsius is DemoReading,
      'Coolant explicitly demo',
    );
    check(provider.current.fuelPercent is DemoReading, 'Fuel explicitly demo');
    check(provider.current.gear is UnavailableReading, 'No invented gear');
    check(
      provider.current.doors is UnavailableReading,
      'No invented door state',
    );
    check(
      provider.current.tirePressuresKpa is UnavailableReading,
      'No invented pressures',
    );
    provider.setDriving(true);
    await Future<void>.delayed(const Duration(milliseconds: 220));
    check(
      (provider.current.speedKmh as DemoReading<double>).value > 48,
      'Animated demo updates',
    );
    await provider.stop();
    check(
      provider.current.voltage is UnavailableReading,
      'Stop clears stale voltage',
    );
    final count = updates.length;
    await Future<void>.delayed(const Duration(milliseconds: 220));
    check(updates.length <= count + 1, 'Stop cancels polling');
    await provider.start();
    check(
      (provider.current.speedKmh as DemoReading<double>).value == 0,
      'Restart resets speed',
    );
    bool rejected = false;
    try {
      provider.setSpeed(double.nan);
    } on ArgumentError {
      rejected = true;
    }
    check(rejected, 'Invalid boundary value rejected');
    await provider.dispose();
    await provider.dispose();
    await subscription.cancel();
    final obd = ObdVehicleDataProvider();
    check(
      obd.current.connection == VehicleConnection.unsupported,
      'Future OBD is unavailable',
    );
    rejected = false;
    try {
      await obd.start();
    } on UnsupportedError {
      rejected = true;
    }
    check(rejected, 'Future OBD cannot claim a connection');
  });
}
