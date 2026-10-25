import 'package:flutter/material.dart';

import '../services/vehicle_data_provider.dart';

String readingText(VehicleReading<double> reading, {int decimals = 0}) =>
    switch (reading) {
      DemoReading(:final value) => value.toStringAsFixed(decimals),
      LiveReading(:final value, :final sampledAt) =>
        DateTime.now().difference(sampledAt).inSeconds > 3
            ? '—'
            : value.toStringAsFixed(decimals),
      UnavailableReading() => '—',
    };
String provenance(VehicleReading reading) => switch (reading) {
  DemoReading() => 'DEMO',
  LiveReading() => 'LIVE',
  UnavailableReading() => 'Unavailable',
};

class TelemetryDisplay extends StatelessWidget {
  const TelemetryDisplay({
    super.key,
    required this.data,
    this.expanded = false,
  });
  final VehicleSnapshot data;
  final bool expanded;
  @override
  Widget build(BuildContext context) {
    final items = <(String, VehicleReading<double>, String, int)>[
      ('Engine', data.rpm, 'rpm', 0),
      ('12V supply', data.voltage, 'V', 1),
      ('Coolant', data.coolantCelsius, '°C', 0),
      if (expanded) ('Fuel', data.fuelPercent, '%', 0),
    ];
    return Row(
      children: [
        for (final item in items)
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${readingText(item.$2, decimals: item.$4)} ${item.$3}',
                  style: TextStyle(fontSize: expanded ? 18 : 14),
                ),
                const SizedBox(height: 5),
                Text(
                  item.$1,
                  style: TextStyle(
                    fontSize: 9,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  provenance(item.$2),
                  style: TextStyle(
                    fontSize: 7,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
