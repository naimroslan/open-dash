import 'dart:io';
import 'package:city_dashboard/features/vehicle/figma_road_artwork.dart';
import 'dart:ui' as ui;
import 'package:city_dashboard/app/theme.dart';
import 'package:city_dashboard/features/vehicle/vehicle_visualization.dart';
import 'package:city_dashboard/services/vehicle_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    final font = FontLoader('Montserrat')
      ..addFont(rootBundle.load('assets/fonts/Montserrat.ttf'));
    await font.load();
    await precacheRoadArtwork();
  });
  for (final size in [const Size(320, 360), const Size(410, 480)]) {
    testWidgets('Rear view and moving road at ${size.width.toInt()}', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final boundaryKey = GlobalKey();
      VehicleSnapshot data = const VehicleSnapshot(
        connection: VehicleConnection.demo,
        speedKmh: DemoReading(0),
      );
      bool reduced = false;
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          theme: dashboardTheme(Brightness.dark),
          home: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(disableAnimations: reduced),
                child: RepaintBoundary(
                  key: boundaryKey,
                  child: Material(
                    child: VehicleVisualization(data: data, onDetails: () {}),
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.runAsync(() async {
        final context = tester.element(find.byType(VehicleVisualization));
        await precacheImage(
          const AssetImage('assets/images/honda-city.png'),
          context,
        );
        if (!context.mounted) return;
        for (final asset in [
          'lane-127947.png',
          'lane-127948.png',
          'lane-127949.png',
          'lane-127950.png',
        ]) {
          await precacheImage(AssetImage('assets/images/$asset'), context);
        }
        await precacheImage(
          const AssetImage('assets/images/honda-city-rear.png'),
          context,
        );
      });
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byKey(const Key('parked-scene')), findsOneWidget);
      expect(find.byKey(const Key('rear-car')), findsNothing);
      update(
        () => data = const VehicleSnapshot(
          connection: VehicleConnection.demo,
          speedKmh: DemoReading(48),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.byKey(const Key('rear-car')), findsOneWidget);
      expect(find.text('SIMULATED ROAD VIEW'), findsOneWidget);
      expect(find.text('Bonnet'), findsNothing);
      Future<List<int>> pixels() async {
        final boundary =
            boundaryKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        return bytes!.buffer.asUint8List();
      }

      await tester.runAsync(() async {
        final boundary =
            boundaryKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 1);
        final rgba = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        final bytes = rgba!.buffer.asUint8List();
        var cyan = 0;
        var speedPixels = 0;
        for (var i = 0; i < bytes.length; i += 4) {
          if (bytes[i + 2] > 150 && bytes[i + 1] > 110 && bytes[i] < 100) {
            cyan++;
          }
        }
        for (var i = 0; i < size.width.toInt() * 115 * 4; i += 4) {
          if (bytes[i] > 200 && bytes[i + 1] > 200 && bytes[i + 2] > 200) {
            speedPixels++;
          }
        }
        expect(
          speedPixels,
          greaterThan(100),
          reason: 'Road artwork must not paint over the speed readout',
        );
        expect(
          cyan,
          greaterThan(30),
          reason: 'Figma cyan corridor must be visible in rendered pixels',
        );
      });
      final first = await tester.runAsync(pixels);
      await tester.pump(const Duration(milliseconds: 100));
      final second = await tester.runAsync(pixels);
      expect(
        second,
        isNot(equals(first)),
        reason: 'Road markings move between real rendered frames',
      );
      await tester.runAsync(() async {
        await Directory('test-artifacts').create(recursive: true);
        await File(
          'test-artifacts/rear-view-${size.width.toInt()}.png',
        ).writeAsBytes(second!);
      });
      update(
        () => data = const VehicleSnapshot(
          connection: VehicleConnection.demo,
          speedKmh: DemoReading(80),
        ),
      );
      await tester.pump();
      expect(find.byKey(const Key('rear-car')), findsOneWidget);
      update(() => reduced = true);
      await tester.pump(const Duration(milliseconds: 700));
      final staticFirst = await tester.runAsync(pixels);
      await tester.pump(const Duration(milliseconds: 150));
      final staticSecond = await tester.runAsync(pixels);
      expect(
        staticSecond,
        equals(staticFirst),
        reason: 'Reduced motion freezes road markings',
      );
      update(
        () => data = const VehicleSnapshot(
          connection: VehicleConnection.demo,
          speedKmh: DemoReading(0),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byKey(const Key('rear-car')), findsNothing);
      expect(find.byKey(const Key('parked-scene')), findsOneWidget);
      update(
        () => data = const VehicleSnapshot(
          connection: VehicleConnection.disconnected,
        ),
      );
      await tester.pump();
      expect(find.text('NO OBD'), findsOneWidget);
      expect(find.byKey(const Key('rear-car')), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  }
}
