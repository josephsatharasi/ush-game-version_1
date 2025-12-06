import 'package:audioplayers/audioplayers.dart';

class BackgroundMusicService {
  static final BackgroundMusicService _instance = BackgroundMusicService._internal();
  factory BackgroundMusicService() => _instance;
  BackgroundMusicService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

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

  void dispose() {
    _audioPlayer.dispose();
  }
}
