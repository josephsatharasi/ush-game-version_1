import 'package:flutter/material.dart';
import 'background_music_service.dart';
import 'game_service.dart';

class AppLifecycleService extends WidgetsBindingObserver {
  static final AppLifecycleService _instance = AppLifecycleService._internal();
  factory AppLifecycleService() => _instance;
  AppLifecycleService._internal();

  final BackgroundMusicService _musicService = BackgroundMusicService();
  final GameService _gameService = GameService();

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // App goes to background - pause music and game
        _musicService.pause();
        _gameService.pausePolling();
        break;
        
      case AppLifecycleState.resumed:
        // App comes to foreground - resume music and game
        _musicService.resume();
        _gameService.resumePolling();
        break;
        
      case AppLifecycleState.detached:
        // App is being terminated
        _musicService.stop();
        _gameService.stopPolling();
        break;
        
      case AppLifecycleState.hidden:
        // App is hidden but still running
        _musicService.pause();
        break;
    }
  }
}