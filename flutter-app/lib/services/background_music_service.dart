import 'package:audioplayers/audioplayers.dart';

class BackgroundMusicService {
  static final BackgroundMusicService _instance = BackgroundMusicService._internal();
  factory BackgroundMusicService() => _instance;
  BackgroundMusicService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _wasPausedBySystem = false;

  Future<void> play() async {
    if (_isPlaying) return;
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource('audios/game_theme.mp3'));
    _isPlaying = true;
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _isPlaying = false;
  }

  Future<void> pause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      _wasPausedBySystem = true;
    }
  }

  Future<void> resume() async {
    if (_wasPausedBySystem) {
      await _audioPlayer.resume();
      _wasPausedBySystem = false;
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
