import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/backend_api_config.dart';

class GameService {
  static final GameService _instance = GameService._internal();
  factory GameService() => _instance;
  GameService._internal();

  Timer? _statusTimer;
  final _gameStatusController = StreamController<Map<String, dynamic>>.broadcast();
  bool _isPaused = false;
  
  Stream<Map<String, dynamic>> get gameStatusStream => _gameStatusController.stream;

  Future<void> startPolling() async {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(Duration(seconds: 2), (_) => _fetchGameStatus());
  }

  Future<void> _fetchGameStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final gameId = prefs.getString('gameId');
      
      if (token != null && gameId != null) {
        final status = await BackendApiConfig.getGameStatus(
          token: token,
          gameId: gameId,
        );
        _gameStatusController.add(status);
      }
    } catch (e) {
      // Silently fail
    }
  }

  void stopPolling() {
    _statusTimer?.cancel();
    _isPaused = false;
  }

  void pausePolling() {
    _statusTimer?.cancel();
    _isPaused = true;
  }

  void resumePolling() {
    if (_isPaused) {
      _isPaused = false;
      startPolling();
    }
  }

  void dispose() {
    _statusTimer?.cancel();
    _gameStatusController.close();
  }
}
