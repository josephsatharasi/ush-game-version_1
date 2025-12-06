import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';

class GameNumberService {
  static final GameNumberService _instance = GameNumberService._internal();
  factory GameNumberService() => _instance;
  GameNumberService._internal();

  final List<int> _announcedNumbers = [];
  final StreamController<int> _numberStreamController = StreamController<int>.broadcast();
  Timer? _animationTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isRunning = false;

  Stream<int> get numberStream => _numberStreamController.stream;
  List<int> get announcedNumbers => List.unmodifiable(_announcedNumbers);

  Future<void> initialize() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  void startGame() {
    if (_isRunning) return;
    _isRunning = true;
    _announceNextNumber();
  }

  void _announceNextNumber() {
    _audioPlayer.play(AssetSource('audios/jar_shaking.mp3'));
    
    _animationTimer = Timer(const Duration(milliseconds: 4200), () {
      _audioPlayer.stop();
      
      int newNumber;
      do {
        newNumber = Random().nextInt(90) + 1;
      } while (_announcedNumbers.contains(newNumber));
      
      _announcedNumbers.add(newNumber);
      _numberStreamController.add(newNumber);
      _flutterTts.speak(newNumber.toString());
      
      Timer(const Duration(seconds: 4), () {
        if (_isRunning) {
          _announceNextNumber();
        }
      });
    });
  }

  void stopGame() {
    _isRunning = false;
    _animationTimer?.cancel();
    _audioPlayer.stop();
  }

  void resetGame() {
    stopGame();
    _announcedNumbers.clear();
  }

  void dispose() {
    _animationTimer?.cancel();
    _audioPlayer.dispose();
    _numberStreamController.close();
  }
}
