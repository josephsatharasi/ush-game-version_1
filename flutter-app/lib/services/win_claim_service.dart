import 'package:shared_preferences/shared_preferences.dart';
import '../config/backend_api_config.dart';

class WinClaimService {
  static final WinClaimService _instance = WinClaimService._internal();
  factory WinClaimService() => _instance;
  WinClaimService._internal();

  Future<Map<String, dynamic>> claimWin(String winType, String cardNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final gameId = prefs.getString('gameId');
    
    if (token == null || gameId == null) {
      throw Exception('Not authenticated or no active game');
    }

    return await BackendApiConfig.claimWin(
      token: token,
      gameId: gameId,
      winType: winType,
      cardNumber: cardNumber,
    );
  }

  Future<bool> canClaimWin(String winType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final gameId = prefs.getString('gameId');
      
      if (token == null || gameId == null) return false;

      final status = await BackendApiConfig.getGameStatus(
        token: token,
        gameId: gameId,
      );

      final winnerFields = {
        'FIRST_LINE': 'firstLineWinner',
        'SECOND_LINE': 'secondLineWinner',
        'THIRD_LINE': 'thirdLineWinner',
        'JALDI': 'jaldiWinner',
        'HOUSIE': 'housieWinner',
      };

      final field = winnerFields[winType];
      if (field == null) return false;

      return status[field] == null;
    } catch (e) {
      return false;
    }
  }
}
