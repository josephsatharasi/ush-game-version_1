import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class GameTiltModel {
  String? selectedCardType;
  int currentNumber = 0;
  List<int> announcedNumbers = [];
  int remainingNumbers = 0;
  String gameStatus = 'WAITING';
  Map<String, dynamic>? winners;
  
  // Line status tracking - starts as false, only set to true when claimed
  bool firstLineCompleted = false;
  bool secondLineCompleted = false;
  bool thirdLineCompleted = false;
  bool jaldhiCompleted = false;
  bool housiCompleted = false;
  
  // User's ticket numbers
  List<int> firstLineNumbers = [];
  List<int> secondLineNumbers = [];
  List<int> thirdLineNumbers = [];
  List<int> allTicketNumbers = [];

  List<Map<String, dynamic>> cardTypes = [];

  void selectCardType(String type) {
    debugPrint('🃏 MODEL: Card type selected - $type (was: $selectedCardType)');
    selectedCardType = type;
  }

  void updateCardTypes(List<Map<String, dynamic>> types) {
    cardTypes = types;
    debugPrint('📊 MODEL: Card types updated from backend: ${types.length} types');
  }

  void updateFromAnnouncedNumbers(Map<String, dynamic> data) {
    final oldCurrentNumber = currentNumber;
    final oldAnnouncedCount = announcedNumbers.length;
    final oldRemaining = remainingNumbers;
    
    currentNumber = data['currentNumber'] ?? 0;
    announcedNumbers = (data['announcedNumbers'] as List?)?.cast<int>() ?? [];
    remainingNumbers = data['remaining'] ?? 0;
    
    debugPrint('📊 MODEL: Updated from announced numbers API');
    debugPrint('📊 MODEL: Current number: $oldCurrentNumber → $currentNumber');
    debugPrint('📊 MODEL: Announced count: $oldAnnouncedCount → ${announcedNumbers.length}');
    debugPrint('📊 MODEL: Remaining: $oldRemaining → $remainingNumbers');
    debugPrint('📊 MODEL: Announced numbers: $announcedNumbers');
  }

  void updateFromGameStatus(Map<String, dynamic> data) {
    final oldStatus = gameStatus;
    final oldCurrentNumber = currentNumber;
    final oldAnnouncedCount = announcedNumbers.length;
    final oldHasWinners = hasWinners;
    
    gameStatus = data['status'] ?? 'WAITING';
    currentNumber = data['currentNumber'] ?? 0;
    announcedNumbers = (data['announcedNumbers'] as List?)?.cast<int>() ?? [];
    winners = {
      'firstLineWinner': data['firstLineWinner'],
      'secondLineWinner': data['secondLineWinner'],
      'thirdLineWinner': data['thirdLineWinner'],
      'jaldiWinner': data['jaldiWinner'],
      'housieWinner': data['housieWinner'],
    };
    
    debugPrint('📊 MODEL: Updated from game status API');
    debugPrint('📊 MODEL: Game status: $oldStatus → $gameStatus');
    debugPrint('📊 MODEL: Current number: $oldCurrentNumber → $currentNumber');
    debugPrint('📊 MODEL: Announced count: $oldAnnouncedCount → ${announcedNumbers.length}');
    debugPrint('📊 MODEL: Has winners: $oldHasWinners → $hasWinners');
    if (hasWinners) {
      debugPrint('📊 MODEL: Winners: $winners');
    }
  }

  bool get isGameLive => gameStatus == 'LIVE';
  bool get hasCurrentNumber => currentNumber > 0;
  bool get hasWinners => winners != null && winners!.values.any((winner) => winner != null);
  
  void loadTicketNumbers(Map<String, dynamic> ticket) {
    firstLineNumbers = (ticket['firstLine'] as List?)?.cast<int>() ?? [];
    secondLineNumbers = (ticket['secondLine'] as List?)?.cast<int>() ?? [];
    thirdLineNumbers = (ticket['thirdLine'] as List?)?.cast<int>() ?? [];
    allTicketNumbers = [...firstLineNumbers, ...secondLineNumbers, ...thirdLineNumbers];
    debugPrint('📋 MODEL: Loaded ticket - 1st: $firstLineNumbers, 2nd: $secondLineNumbers, 3rd: $thirdLineNumbers');
  }
  
  bool checkLineCompletion(String lineType) {
    List<int> lineNumbers = [];
    switch (lineType) {
      case 'FIRST LINE':
        lineNumbers = firstLineNumbers;
        break;
      case 'SECOND LINE':
        lineNumbers = secondLineNumbers;
        break;
      case 'THIRD LINE':
        lineNumbers = thirdLineNumbers;
        break;
    }
    
    if (lineNumbers.isEmpty) return false;
    return lineNumbers.every((num) => announcedNumbers.contains(num));
  }
  
  bool checkJaldhiCompletion() {
    // Jaldi: Any ONE complete line (first, second, or third)
    if (allTicketNumbers.isEmpty) return false;
    
    final firstComplete = firstLineNumbers.isNotEmpty && 
                         firstLineNumbers.every((num) => announcedNumbers.contains(num));
    final secondComplete = secondLineNumbers.isNotEmpty && 
                          secondLineNumbers.every((num) => announcedNumbers.contains(num));
    final thirdComplete = thirdLineNumbers.isNotEmpty && 
                         thirdLineNumbers.every((num) => announcedNumbers.contains(num));
    
    return firstComplete || secondComplete || thirdComplete;
  }
  
  bool checkHousiCompletion() {
    if (allTicketNumbers.isEmpty) return false;
    return allTicketNumbers.every((num) => announcedNumbers.contains(num));
  }
}
