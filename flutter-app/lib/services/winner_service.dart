import 'package:shared_preferences/shared_preferences.dart';
import '../config/backend_api_config.dart';
import '../models/winner.dart';
import '../models/win_type.dart';
import 'package:flutter/material.dart';


class WinnerService {
  static final WinnerService _instance = WinnerService._internal();
  factory WinnerService() => _instance;
  WinnerService._internal();

  Future<Map<String, dynamic>> claimWin({
    required String gameId,
    required WinType winType,
    required String cardNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token == null) {
      throw Exception('Not authenticated');
    }

    return await BackendApiConfig.claimWin(
      token: token,
      gameId: gameId,
      winType: winType.apiValue,
      cardNumber: cardNumber,
    );
  }

  Future<List<Winner>> getWinners(String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await BackendApiConfig.getWinners(
      token: token,
      gameId: gameId,
    );

    final List<dynamic> winnersJson = response['winners'] ?? [];
    return winnersJson.map((json) => Winner.fromJson(json)).toList();
  }

  Future<Winner?> getHousieWinner(String gameId) async {
    final winners = await getWinners(gameId);
    try {
      return winners.firstWhere((w) => w.winType == 'HOUSIE');
    } catch (e) {
      return null;
    }
  }

  Future<List<Winner>> getUserCoupons() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await BackendApiConfig.getMyCoupons(token: token);
    final List<dynamic> couponsJson = response['coupons'] ?? [];
    return couponsJson.map((json) => Winner.fromJson(json)).toList();
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
