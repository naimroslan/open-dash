import 'vehicle_data_provider.dart';

/// Reserved for a verified, read-only adapter implementation. No transport yet.
final class ObdVehicleDataProvider implements VehicleDataProvider {
  @override
  VehicleSnapshot get current =>
      const VehicleSnapshot(connection: VehicleConnection.unsupported);

  @override
  Stream<VehicleSnapshot> get snapshots => Stream.value(current);

  @override
  Future<void> start() async {
    throw UnsupportedError(
      'OBD transport is not implemented. Adapter and Honda readings must be verified.',
    );
  }

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}
