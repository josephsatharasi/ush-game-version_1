import 'dart:async';

class GameNumberService {
  static final GameNumberService _instance = GameNumberService._internal();
  factory GameNumberService() => _instance;
  GameNumberService._internal();

  final StreamController<int> _numberStreamController = StreamController<int>.broadcast();
  int _currentNumber = 0;
  final List<int> _announcedNumbers = [];

  Stream<int> get numberStream => _numberStreamController.stream;
  int get currentNumber => _currentNumber;
  List<int> get announcedNumbers => List.unmodifiable(_announcedNumbers);
  
  void updateCurrentNumber(int number) {
    if (_currentNumber != number && number > 0) {
      _currentNumber = number;
      if (!_announcedNumbers.contains(number)) {
        _announcedNumbers.add(number);
      }
      _numberStreamController.add(number);
    }
  }
  
  void updateAnnouncedNumbers(List<int> numbers) {
    _announcedNumbers.clear();
    _announcedNumbers.addAll(numbers);
  }

  void dispose() {
    _numberStreamController.close();
  }
}
