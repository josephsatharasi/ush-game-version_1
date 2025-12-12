import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';

class GameNumberService {
  static final GameNumberService _instance = GameNumberService._internal();
  factory GameNumberService() => _instance;
  GameNumberService._internal();

  final List<int> _announcedNumbers = [];
  final Set<int> _markedNumbers = {};
  final StreamController<int> _numberStreamController = StreamController<int>.broadcast();
  final StreamController<Set<int>> _markedNumbersController = StreamController<Set<int>>.broadcast();
  Timer? _animationTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isRunning = false;

  Stream<int> get numberStream => _numberStreamController.stream;
  Stream<Set<int>> get markedNumbersStream => _markedNumbersController.stream;
  List<int> get announcedNumbers => List.unmodifiable(_announcedNumbers);
  Set<int> get markedNumbers => Set.unmodifiable(_markedNumbers);

  void markNumber(int number) {
    _markedNumbers.add(number);
    _markedNumbersController.add(Set.from(_markedNumbers));
  }

  void unmarkNumber(int number) {
    _markedNumbers.remove(number);
    _markedNumbersController.add(Set.from(_markedNumbers));
  }

  bool isMarked(int number) => _markedNumbers.contains(number);

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
    // Removed audio and TTS - sounds should only play from main game widget
    // when backend announces numbers, not from this service
    
    _animationTimer = Timer(const Duration(milliseconds: 4200), () {
      int newNumber;
      do {
        newNumber = Random().nextInt(90) + 1;
      } while (_announcedNumbers.contains(newNumber));
      
      _announcedNumbers.add(newNumber);
      _numberStreamController.add(newNumber);
      
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
  }

  void resetGame() {
    stopGame();
    _announcedNumbers.clear();
    _markedNumbers.clear();
    _markedNumbersController.add(Set.from(_markedNumbers));
  }

  void dispose() {
    _animationTimer?.cancel();
    _audioPlayer.dispose();
    _numberStreamController.close();
    _markedNumbersController.close();
  }
}
