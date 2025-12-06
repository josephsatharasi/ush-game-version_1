import 'dart:async';

class SplashScreenModel {
  // Simulated auth check. Replace with real implementation later.
  Future<bool> isLoggedIn() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    return false; // TODO: wire to persisted auth state
  }
}
