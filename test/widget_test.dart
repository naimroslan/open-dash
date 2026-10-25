import 'dart:io';
import 'package:city_dashboard/features/vehicle/figma_road_artwork.dart';
import 'dart:ui' as ui;
import 'package:city_dashboard/app/theme.dart';
import 'package:city_dashboard/features/dashboard/dashboard_screen.dart';
import 'package:city_dashboard/features/media/media_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class TestMedia extends DashboardMedia {
  bool _playing = false;
  int track = 0;
  double _volume = .45;
  @override
  bool get playing => _playing;
  @override
  bool get ready => true;
  @override
  String? get error => null;
  @override
  String get title => track == 0 ? 'Night drive' : 'After hours';
  @override
  Duration get position => Duration.zero;
  @override
  Duration get duration => const Duration(seconds: 24);
  @override
  double get volume => _volume;
  @override
  Future<void> initialize() async {}
  @override
  Future<void> toggle() async {
    _playing = !_playing;
    notifyListeners();
  }

  @override
  Future<void> next() async {
    track = 1 - track;
    notifyListeners();
  }

  @override
  Future<void> previous() => next();
  @override
  Future<void> seek(Duration position) async {}
  @override
  Future<void> setVolume(double value) async {
    _volume = value;
    notifyListeners();
  }

  @override
  Future<void> pause() async {
    _playing = false;
    notifyListeners();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final loader = FontLoader('Montserrat')
      ..addFont(rootBundle.load('assets/fonts/Montserrat.ttf'));
    await loader.load();
    await precacheRoadArtwork();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });
  for (final size in [const Size(800, 480), const Size(1024, 600)]) {
    testWidgets(
      'Dashboard behavior at ${size.width.toInt()}x${size.height.toInt()}',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final media = TestMedia();
        final repaint = GlobalKey();
        await tester.pumpWidget(
          MaterialApp(
            theme: dashboardTheme(Brightness.dark),
            home: RepaintBoundary(
              key: repaint,
              child: DashboardScreen(
                dark: true,
                onThemeChanged: (_) {},
                media: media,
                networkEnabled: false,
              ),
            ),
          ),
        );
        await tester.runAsync(() async {
          for (final asset in [
            'lane-127947.png',
            'lane-127948.png',
            'lane-127949.png',
            'lane-127950.png',
          ]) {
            await precacheImage(
              AssetImage('assets/images/$asset'),
              tester.element(find.byType(DashboardScreen)),
            );
          }
          await precacheImage(
            const AssetImage('assets/images/honda-city-rear.png'),
            tester.element(find.byType(DashboardScreen)),
          );
          await precacheImage(
            const AssetImage('assets/images/honda-city.png'),
            tester.element(find.byType(DashboardScreen)),
          );
        });
        await tester.pump(const Duration(milliseconds: 700));
        expect(tester.takeException(), isNull);
        expect(find.text('DEMO'), findsAtLeastNWidgets(1));
        expect(find.text('Gear —'), findsOneWidget);
        expect(find.text('800 rpm'), findsOneWidget);
        await tester.runAsync(() async {
          final boundary =
              repaint.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 1);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final dir = Directory('test-artifacts');
          await dir.create(recursive: true);
          await File(
            '${dir.path}/flutter-dashboard-${size.width.toInt()}x${size.height.toInt()}.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
        });
        await tester.tap(find.byKey(const ValueKey('dock-settings')));
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.text('Demo telemetry'), findsOneWidget);
        final slider = tester.widget<Slider>(
          find.byKey(const Key('demo-speed')),
        );
        slider.onChanged!(65);
        await tester.pump();
        expect(find.text('65'), findsOneWidget);
        await tester.pump(const Duration(milliseconds: 700));
        expect(find.byKey(const Key('rear-car')), findsOneWidget);
        slider.onChanged!(0);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 700));
        expect(find.byKey(const Key('rear-car')), findsNothing);
        final animate = tester.widget<SwitchListTile>(
          find.widgetWithText(SwitchListTile, 'Animate demo drive'),
        );
        animate.onChanged!(true);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 700));
        expect(find.byKey(const Key('rear-car')), findsOneWidget);
        await tester.tap(find.byTooltip('Close panel'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 700));
        await tester.runAsync(() async {
          final boundary =
              repaint.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 1);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            'test-artifacts/flutter-driving-${size.width.toInt()}x${size.height.toInt()}.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
        });
        await tester.tap(find.byKey(const ValueKey('dock-settings')));
        await tester.pump(const Duration(milliseconds: 400));

        final sourceSwitch = tester.widget<SwitchListTile>(
          find.widgetWithText(SwitchListTile, 'Demo telemetry'),
        );
        sourceSwitch.onChanged!(false);
        await tester.pump();
        expect(find.text('NO OBD'), findsOneWidget);
        expect(find.text('800 rpm'), findsNothing);
        await tester.tap(find.byTooltip('Close panel'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.tap(find.byKey(const ValueKey('dock-phone')));
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.text('iPhone 16 Pro'), findsOneWidget);
        expect(find.text('Open Wi-Fi settings'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('dock-music')));
        await tester.pump(const Duration(milliseconds: 400));
        await tester.tap(find.byTooltip('Play audio').last);
        await tester.pump();
        expect(media.playing, isTrue);
        await tester.tap(find.byTooltip('Next track').last);
        await tester.pump();
        expect(find.text('After hours'), findsNWidgets(2));
        await tester.tap(find.byKey(const ValueKey('dock-navigation')));
        await tester.pump(const Duration(milliseconds: 400));
        await tester.enterText(find.byKey(const Key('destination')), 'KLCC');
        expect(find.text('KLCC'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('dock-apps')));
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.text('Google Maps'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.pump();
        media.dispose();
      },
    );
  }
}
