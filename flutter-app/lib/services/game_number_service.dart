import 'dart:async';

class GameNumberService {
  static final GameNumberService _instance = GameNumberService._internal();
  factory GameNumberService() => _instance;
  GameNumberService._internal();

  final StreamController<int> _numberStreamController = StreamController<int>.broadcast();
  int _currentNumber = 0;

  Stream<int> get numberStream => _numberStreamController.stream;
  int get currentNumber => _currentNumber;
  
  void updateCurrentNumber(int number) {
    if (_currentNumber != number && number > 0) {
      _currentNumber = number;
      _numberStreamController.add(number);
    }
  }

  void dispose() {
    _numberStreamController.close();
  }
}
