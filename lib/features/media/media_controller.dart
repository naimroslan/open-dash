import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

abstract class DashboardMedia extends ChangeNotifier {
  bool get playing;
  bool get ready;
  String? get error;
  String get title;
  Duration get position;
  Duration get duration;
  double get volume;
  Future<void> initialize();
  Future<void> toggle();
  Future<void> next();
  Future<void> previous();
  Future<void> seek(Duration position);
  Future<void> setVolume(double volume);
  Future<void> pause();
}

class LocalMediaController extends DashboardMedia {
  final _player = AudioPlayer();
  final _tracks = ['night-drive', 'after-hours'];
  int _index = 0;
  bool _ready = false;
  String? _error;
  @override
  bool get playing => _player.playing;
  @override
  bool get ready => _ready;
  @override
  String? get error => _error;
  @override
  String get title => _index == 0 ? 'Night drive' : 'After hours';
  @override
  Duration get position => _player.position;
  @override
  Duration get duration => _player.duration ?? Duration.zero;
  @override
  double get volume => _player.volume;
  bool _disposed = false;
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  Future<void> initialize() async {
    _player.positionStream.listen((_) => _notify());
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _player.pause();
        _player.seek(Duration.zero);
      }
      _notify();
    });
    _player.errorStream.listen((event) {
      _error = 'Audio unavailable. Try another track.';
      _notify();
    });
    await _player.setVolume(.45);
    await _load();
  }

  Future<void> _load() async {
    _ready = false;
    _error = null;
    _notify();
    try {
      await _player.setAsset('assets/audio/${_tracks[_index]}.wav');
      _ready = true;
    } catch (_) {
      _error = 'Could not load demo audio. Tap next to retry.';
    }
    _notify();
  }

  @override
  Future<void> toggle() async {
    try {
      if (!_ready) {
        await _load();
        if (!_ready) return;
      }
      if (playing) {
        await _player.pause();
      } else {
        _player.play().catchError((Object e) {
          _error = 'Audio playback unavailable';
          _notify();
        });
      }
    } catch (_) {
      _error = 'Audio playback unavailable';
      _notify();
    }
  }

  @override
  Future<void> next() async {
    final resume = playing;
    await _player.pause();
    _index = (_index + 1) % _tracks.length;
    await _load();
    if (resume && _ready) toggle();
  }

  @override
  Future<void> previous() async {
    if (position.inSeconds > 3) {
      await seek(Duration.zero);
    } else {
      await next();
    }
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);
  @override
  Future<void> setVolume(double volume) =>
      _player.setVolume(volume.clamp(0, 1));
  @override
  Future<void> pause() => _player.pause();
  @override
  void dispose() {
    _disposed = true;
    _player.dispose();
    super.dispose();
  }
}
