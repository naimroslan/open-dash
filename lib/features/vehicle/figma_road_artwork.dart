import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<List<ui.Image>>? _cachedArtwork;
List<ui.Image>? _loadedArtwork;

Future<List<ui.Image>> precacheRoadArtwork() => _cachedArtwork ??=
    Future.wait([
      for (final name in [
        'lane-127947.png',
        'lane-127948.png',
        'lane-127949.png',
        'lane-127950.png',
      ])
        _decode(name),
    ]).then((images) {
      _loadedArtwork = images;
      return images;
    });

Future<ui.Image> _decode(String name) async {
  final data = await rootBundle.load('assets/images/$name');
  final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
  final frame = await codec.getNextFrame();
  codec.dispose();
  return frame.image;
}

class FigmaRoadArtwork extends StatelessWidget {
  const FigmaRoadArtwork({super.key});
  @override
  Widget build(BuildContext context) => FutureBuilder<List<ui.Image>>(
    future: precacheRoadArtwork(),
    builder: (context, snapshot) => CustomPaint(
      painter: _ArtworkPainter(_loadedArtwork ?? snapshot.data ?? const []),
      child: const SizedBox.expand(),
    ),
  );
}

class _ArtworkPainter extends CustomPainter {
  _ArtworkPainter(this.images);
  final List<ui.Image> images;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xff0e0e0e),
    );
    const geometry = [
      (.50, .62, .20),
      (.49, .62, .20),
      (.56, .76, .14),
      (.77, .80, .10),
    ];
    for (var i = 0; i < images.length; i++) {
      final image = images[i];
      final slot = geometry[i];
      final destination = Rect.fromLTWH(
        size.width * (1 - slot.$1) / 2,
        size.height * slot.$3,
        size.width * slot.$1,
        size.height * slot.$2,
      );
      // Figma's exports carry a dark matte. Lighten preserves the bright lane
      // and spotlight layers while keeping their shared background at #0e0e0e.
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        destination,
        Paint()
          ..blendMode = BlendMode.lighten
          ..filterQuality = FilterQuality.medium,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ArtworkPainter oldDelegate) =>
      oldDelegate.images != images;
}
