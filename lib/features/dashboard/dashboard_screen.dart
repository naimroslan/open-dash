import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/mock_vehicle_provider.dart';
import '../../services/vehicle_data_provider.dart';
import '../../widgets/bottom_dock.dart';
import '../../widgets/telemetry_display.dart';
import '../vehicle/vehicle_visualization.dart';
import '../navigation/navigation_map.dart';
import '../media/media_controller.dart';
import '../media/media_strip.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.dark,
    required this.onThemeChanged,
    this.media,
    this.networkEnabled = true,
  });
  final bool dark;
  final ValueChanged<bool> onThemeChanged;
  final DashboardMedia? media;
  final bool networkEnabled;
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  final mock = MockVehicleDataProvider();
  VehicleDataProvider get vehicleProvider => mock;
  final destination = TextEditingController();
  late final DashboardMedia media = widget.media ?? LocalMediaController();
  DashboardTab? tab;
  bool demoEnabled = true, driving = false;
  static const native = MethodChannel('my.city.dashboard/device');
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    mock.start();
    media.initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    mock.dispose();
    if (widget.media == null) media.dispose();
    destination.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (demoEnabled) mock.start();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      media.pause();
      mock.stop();
      driving = false;
    }
  }

  void message(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(text), duration: const Duration(seconds: 3)),
      );
    }
  }

  void select(DashboardTab value) =>
      setState(() => tab = tab == value ? null : value);
  bool get android =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  Future<void> launchApp(String app) async {
    try {
      if (android) {
        final opened = await native.invokeMethod<bool>('launch', {'app': app});
        if (opened != true) message('App not installed on this device');
      } else {
        final url = {
          'maps': 'https://www.google.com/maps',
          'waze': 'https://www.waze.com/live-map',
          'spotify': 'https://open.spotify.com/',
        }[app];
        if (url == null ||
            !await launchUrl(
              Uri.parse(url),
              mode: LaunchMode.externalApplication,
            )) {
          message('Could not open app');
        }
      }
    } catch (_) {
      message('App unavailable on this device');
    }
  }

  Future<void> settings(String page) async {
    if (!android) {
      message('Android device settings are available in the APK');
      return;
    }
    try {
      final opened = await native.invokeMethod<bool>('settings', {
        'page': page,
      });
      if (opened != true) message('Settings page unavailable on this device');
    } catch (_) {
      message('Could not open device settings');
    }
  }

  Future<void> navigate(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      message('Enter a destination');
      return;
    }
    final web = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': q,
    });
    try {
      if (android &&
          await launchUrl(
            Uri.parse('geo:0,0?q=${Uri.encodeComponent(q)}'),
            mode: LaunchMode.externalApplication,
          )) {
        return;
      }
      if (!await launchUrl(web, mode: LaunchMode.externalApplication)) {
        message('No maps app available');
      }
    } catch (_) {
      message('Navigation unavailable. Install a maps app.');
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: tab == null,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) setState(() => tab = null);
    },
    child: Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, bounds) {
            final leftWidth =
                bounds.maxWidth * (bounds.maxWidth < 700 ? .38 : .4);
            return Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                        width: leftWidth,
                        child: RepaintBoundary(
                          child: StreamBuilder<VehicleSnapshot>(
                            stream: vehicleProvider.snapshots,
                            initialData: vehicleProvider.current,
                            builder: (_, data) => VehicleVisualization(
                              data: data.data!,
                              onDetails: () => select(DashboardTab.vehicle),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ClipRect(
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: RepaintBoundary(
                                  child: NavigationMap(
                                    networkEnabled: widget.networkEnabled,
                                    onNavigate: () =>
                                        select(DashboardTab.navigation),
                                    media: MediaStrip(
                                      media: media,
                                      onExpand: () =>
                                          select(DashboardTab.music),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: IgnorePointer(
                                  ignoring: tab == null,
                                  child: AnimatedSwitcher(
                                    duration:
                                        MediaQuery.disableAnimationsOf(context)
                                        ? Duration.zero
                                        : const Duration(milliseconds: 320),
                                    reverseDuration:
                                        MediaQuery.disableAnimationsOf(context)
                                        ? Duration.zero
                                        : const Duration(milliseconds: 220),
                                    switchInCurve: Curves.easeOutCubic,
                                    switchOutCurve: Curves.easeInCubic,
                                    transitionBuilder: (child, animation) =>
                                        FadeTransition(
                                          opacity: animation,
                                          child: SlideTransition(
                                            position: Tween(
                                              begin: const Offset(0, .06),
                                              end: Offset.zero,
                                            ).animate(animation),
                                            child: child,
                                          ),
                                        ),
                                    child: tab == null
                                        ? const SizedBox.shrink(
                                            key: ValueKey('closed'),
                                          )
                                        : _panel(tab!),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                BottomDock(
                  selected: tab,
                  onSelect: select,
                  onVolume: () => select(DashboardTab.music),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
  Widget _panel(DashboardTab value) => Padding(
    key: ValueKey(value),
    padding: const EdgeInsets.fromLTRB(10, 34, 10, 0),
    child: Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 12,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          GestureDetector(
            onVerticalDragEnd: (details) {
              if ((details.primaryVelocity ?? 0) > 150) {
                setState(() => tab = null);
              }
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 5, 6, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(switch (value) {
                      DashboardTab.vehicle => 'Vehicle',
                      DashboardTab.music => 'Media',
                      DashboardTab.navigation => 'Navigate',
                      DashboardTab.phone => 'Phone',
                      DashboardTab.apps => 'Applications',
                      DashboardTab.settings => 'Settings',
                    }, style: const TextStyle(fontSize: 20)),
                  ),
                  IconButton(
                    tooltip: 'Close panel',
                    onPressed: () => setState(() => tab = null),
                    icon: const Icon(Icons.close, size: 21),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
              child: switch (value) {
                DashboardTab.vehicle => _vehiclePanel(),
                DashboardTab.music => _mediaPanel(),
                DashboardTab.navigation => _navigationPanel(),
                DashboardTab.phone => _phonePanel(),
                DashboardTab.apps => _appsPanel(),
                DashboardTab.settings => _settingsPanel(),
              },
            ),
          ),
        ],
      ),
    ),
  );
  Widget note(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Text(
      text,
      style: TextStyle(
        color: Theme.of(context).hintColor,
        fontSize: 11,
        height: 1.6,
      ),
    ),
  );
  Widget row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 10, color: Theme.of(context).hintColor),
          ),
        ),
      ],
    ),
  );
  Widget _vehiclePanel() => StreamBuilder<VehicleSnapshot>(
    stream: vehicleProvider.snapshots,
    initialData: vehicleProvider.current,
    builder: (_, snapshot) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Honda City Hatchback V', style: TextStyle(fontSize: 16)),
        note('2023 · Malaysia · 1.5L petrol · CVT'),
        row(
          'Data connection',
          demoEnabled ? 'DEMO · simulated' : 'Unavailable · no OBD',
        ),
        const Divider(),
        TelemetryDisplay(data: snapshot.data!, expanded: true),
        const SizedBox(height: 14),
        row('Gear position', 'Unavailable · not verified'),
        row('Doors / locks', 'Unavailable'),
        row('Bonnet / boot', 'Unavailable'),
        row('Tire pressure', 'No verified sensor feed'),
        note(
          'Factory camera, LaneWatch, steering-wheel controls, and climate remain outside this app. Actual display takeover requires AI box testing.',
        ),
      ],
    ),
  );
  Widget _settingsPanel() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      note(
        'City Dashboard 0.5.0 · Flutter\nNo OBD adapter or vehicle connection configured.',
      ),
      SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        title: const Text('Demo telemetry', style: TextStyle(fontSize: 13)),
        value: demoEnabled,
        onChanged: (value) async {
          setState(() {
            demoEnabled = value;
            driving = false;
          });
          if (value) {
            await mock.start();
          } else {
            await mock.stop();
          }
        },
      ),
      SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        title: const Text('Animate demo drive', style: TextStyle(fontSize: 13)),
        value: driving,
        onChanged: demoEnabled
            ? (value) {
                setState(() => driving = value);
                mock.setDriving(value);
              }
            : null,
      ),
      note('Set demo speed'),
      StreamBuilder<VehicleSnapshot>(
        stream: vehicleProvider.snapshots,
        initialData: vehicleProvider.current,
        builder: (_, snapshot) {
          final speed = switch (snapshot.data!.speedKmh) {
            DemoReading(:final value) => value,
            _ => 0.0,
          };
          return Slider(
            key: const Key('demo-speed'),
            min: 0,
            max: 120,
            value: speed.clamp(0, 120),
            label: '${speed.round()} km/h',
            onChanged: demoEnabled
                ? (value) {
                    setState(() => driving = false);
                    mock.setSpeed(value);
                  }
                : null,
          );
        },
      ),
      SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        title: const Text('Dark appearance', style: TextStyle(fontSize: 13)),
        value: widget.dark,
        onChanged: widget.onThemeChanged,
      ),
      note(
        'Every demo reading is labeled. Gear and body sensors remain unavailable. The future OBD provider has no transport implementation and sends no commands.',
      ),
      OutlinedButton(
        onPressed: () => settings('general'),
        child: const Text('Android device settings'),
      ),
    ],
  );
  Widget _mediaPanel() => ListenableBuilder(
    listenable: media,
    builder: (_, _) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(media.title, style: const TextStyle(fontSize: 22)),
        note(
          media.error ??
              'Original synthesized demo audio · plays on this device',
        ),
        Slider(
          min: 0,
          max: media.duration.inMilliseconds > 0
              ? media.duration.inMilliseconds.toDouble()
              : 1,
          value: media.position.inMilliseconds.toDouble().clamp(
            0,
            media.duration.inMilliseconds > 0
                ? media.duration.inMilliseconds.toDouble()
                : 1,
          ),
          onChanged: media.ready
              ? (value) => media.seek(Duration(milliseconds: value.round()))
              : null,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: 'Previous track',
              onPressed: media.previous,
              icon: const Icon(Icons.skip_previous),
            ),
            IconButton(
              tooltip: media.playing ? 'Pause audio' : 'Play audio',
              onPressed: media.toggle,
              icon: Icon(media.playing ? Icons.pause : Icons.play_arrow),
            ),
            IconButton(
              tooltip: 'Next track',
              onPressed: media.next,
              icon: const Icon(Icons.skip_next),
            ),
          ],
        ),
        note('Player volume'),
        Slider(
          key: const Key('player-volume'),
          min: 0,
          max: 1,
          value: media.volume,
          onChanged: media.setVolume,
        ),
        OutlinedButton(
          onPressed: () => launchApp('spotify'),
          child: const Text('Open Spotify'),
        ),
        note(
          'This player does not control iPhone playback or Spotify. Those integrations require separate support.',
        ),
      ],
    ),
  );
  Widget _navigationPanel() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      note(
        'Search opens an external maps app. Embedded routing, ETA, traffic, and turn guidance are not implemented.',
      ),
      Row(
        children: [
          Expanded(
            child: TextField(
              key: const Key('destination'),
              controller: destination,
              maxLength: 250,
              decoration: const InputDecoration(
                hintText: 'Destination',
                counterText: '',
              ),
              onSubmitted: navigate,
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () => navigate(destination.text),
            child: const Text('Go'),
          ),
        ],
      ),
      const SizedBox(height: 12),
      for (final place in [
        'KLCC, Kuala Lumpur',
        'KL Sentral, Kuala Lumpur',
        'Petaling Jaya, Selangor',
        'Kuala Lumpur International Airport',
      ])
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.place_outlined, size: 20),
          title: Text(place, style: const TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => navigate(place),
        ),
      note(
        'Use the map location button to request a one-time device fix. Without permission, the marker stays at the labeled Kuala Lumpur preview point.',
      ),
    ],
  );
  Widget _phonePanel() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Icon(Icons.phone_iphone, size: 42),
      const SizedBox(height: 12),
      const Text('iPhone 16 Pro', style: TextStyle(fontSize: 20)),
      note(
        'Use Personal Hotspot to give the Android box internet access. Connect the box in Android Wi-Fi settings.',
      ),
      OutlinedButton(
        onPressed: () => settings('wifi'),
        child: const Text('Open Wi-Fi settings'),
      ),
      const SizedBox(height: 8),
      OutlinedButton(
        onPressed: () => settings('bluetooth'),
        child: const Text('Open Bluetooth settings'),
      ),
      note(
        'No phone is connected to this app. Calls, notifications, contacts, and Apple Music are not embedded. Pairing support depends on the AI box and factory system.',
      ),
    ],
  );
  Widget _appsPanel() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      note(
        'Android shortcuts require the corresponding app installed on the AI box. Desktop and web open the web versions.',
      ),
      for (final item in [
        ('maps', 'Google Maps', Icons.map_outlined),
        ('waze', 'Waze', Icons.navigation_outlined),
        ('spotify', 'Spotify', Icons.music_note),
      ])
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(item.$3),
          title: Text(item.$2),
          trailing: const Icon(Icons.open_in_new, size: 18),
          onTap: () => launchApp(item.$1),
        ),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.settings_outlined),
        title: const Text('Device settings'),
        onTap: () => settings('general'),
      ),
      note(
        'Launcher replacement and boot auto-start are not enabled. Their behavior must be checked on the chosen AI box.',
      ),
    ],
  );
}
