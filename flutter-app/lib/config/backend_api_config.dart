import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BackendApiConfig {
  static const String productionUrl = 'https://ush-game-version-1.onrender.com';
  static const String localUrl = 'http://192.168.0.22:3001';
  
  static const String baseUrl = '$productionUrl/api';
  
  static Future<Map<String, dynamic>> register({
    required String username,
    required String phone,
    required String password,
    String role = 'user',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'phone': phone,
        'password': password,
        'role': role,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Registration failed');
    }
  }
  
  static Future<Map<String, dynamic>> verifyOtp({
    required String userId,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'otp': otp,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'OTP verification failed');
    }
  }
  
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Login failed');
    }
  }
  
  static Future<void> resendOtp(String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/resend-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );
    
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to resend OTP');
    }
  }

  static Future<Map<String, dynamic>> getLiveGame() async {
    final response = await http.get(
      Uri.parse('$baseUrl/game/live'),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to get live game');
    }
  }

  static Future<Map<String, dynamic>> bookTicket({
    required String token,
    required String gameId,
    required int ticketCount,
    required String scheduledDate,
    required String weekDay,
    required String timeSlot,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/game/book'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'gameId': gameId,
        'ticketCount': ticketCount,
        'scheduledDate': scheduledDate,
        'weekDay': weekDay,
        'timeSlot': timeSlot,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Booking failed');
    }
  }

  static Future<Map<String, dynamic>> getCountdown({
    required String token,
    required String gameId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/game/$gameId/countdown'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to get countdown');
    }
  }

  static Future<Map<String, dynamic>> verifyCard({
    required String token,
    required String gameId,
    required String cardNumber,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/game/$gameId/verify-card'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'cardNumber': cardNumber}),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Card verification failed');
    }
  }

  static Future<Map<String, dynamic>> getGameStatus({
    required String token,
    required String gameId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/game/$gameId/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to get game status');
    }
  }

  static Future<Map<String, dynamic>> claimWin({
    required String token,
    required String gameId,
    required String winType,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/game/$gameId/claim-win'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'winType': winType}),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Win claim failed');
    }
  }

  static Future<Map<String, dynamic>> getGameSlotConfig({
    required String gameId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/game/$gameId/slot-config'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to get slot config');
    }
  }

  static Future<Map<String, dynamic>> getAvailableGames() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/game/available'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to get available games');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> getAllGames() async {
    try {
      print('Fetching games from: $baseUrl/admin/games/all');
      final response = await http.get(
        Uri.parse('$baseUrl/admin/games/all'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server returned ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Network error: $e');
      throw Exception('Network error: $e');
    }
  }
}
