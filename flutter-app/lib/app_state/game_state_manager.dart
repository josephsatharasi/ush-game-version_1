class GameStateManager {
  static final GameStateManager _instance = GameStateManager._internal();
  factory GameStateManager() => _instance;
  GameStateManager._internal();

  final Set<String> _visitedScreens = {};

  void markAsVisited(String screenName) {
    _visitedScreens.add(screenName);
  }

  bool isVisited(String screenName) {
    return _visitedScreens.contains(screenName);
  }

  void reset() {
    _visitedScreens.clear();
  }

  Set<String> get visitedScreens => Set.from(_visitedScreens);
}
