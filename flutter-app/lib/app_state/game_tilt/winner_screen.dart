import 'package:flutter/material.dart';
import 'package:ush_app/widgets/loction_header.dart';
import 'package:ush_app/app_state/game_tilt/scratch_reward_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/backend_api_config.dart';

class WinnerScreen extends StatefulWidget {
  final String? winnerUsername;
  final String? winnerUserId;
  
  const WinnerScreen({
    super.key,
    this.winnerUsername,
    this.winnerUserId,
  });

  @override
  State<WinnerScreen> createState() => _WinnerScreenState();
}

class _WinnerScreenState extends State<WinnerScreen> with SingleTickerProviderStateMixin {
  bool _showGameOver = false;
  bool _showYouWon = false;
  bool _showWinner = false;
  bool _isUserWinner = false;
  String _winnerUsername = 'Unknown';

  @override
  void initState() {
    super.initState();
    _fetchWinnerAndCheck();
  }

  Future<void> _fetchWinnerAndCheck() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final token = prefs.getString('token');
      final gameId = prefs.getString('gameId');
      
      if (token == null || gameId == null) {
        _navigateToHome();
        return;
      }
      
      // Fetch game status to get all winners
      final response = await BackendApiConfig.getGameStatus(
        token: token,
        gameId: gameId,
      );
      
      debugPrint('🎮 Game Status Response: $response');
      
      // Check all win types in priority order
      final winTypes = [
        {'key': 'housieWinner', 'label': 'Housie'},
        {'key': 'jaldiWinner', 'label': 'Jaldi'},
        {'key': 'firstLineWinner', 'label': 'First Line'},
        {'key': 'secondLineWinner', 'label': 'Second Line'},
        {'key': 'thirdLineWinner', 'label': 'Third Line'},
      ];
      
      Map<String, dynamic>? winnerData;
      String winType = '';
      
      for (var type in winTypes) {
        final winner = response[type['key']];
        if (winner != null && winner['userId'] != null) {
          winnerData = winner;
          winType = type['label']!;
          break;
        }
      }
      
      if (winnerData != null) {
        final winnerUserId = winnerData['userId'];
        final cardNumber = winnerData['cardNumber'] ?? 'Unknown';
        final isCurrentUserWinner = userId == winnerUserId;
        
        // Fetch winner's username from backend
        String displayName = 'Card: $cardNumber';
        if (!isCurrentUserWinner) {
          try {
            final winnersResponse = await BackendApiConfig.getWinners(
              token: token,
              gameId: gameId,
            );
            final winners = winnersResponse['winners'] as List;
            final winnerInfo = winners.firstWhere(
              (w) => w['userId'] == winnerUserId,
              orElse: () => null,
            );
            if (winnerInfo != null && winnerInfo['username'] != null) {
              displayName = winnerInfo['username'];
            }
          } catch (e) {
            debugPrint('⚠️ Failed to fetch winner username: $e');
          }
        }
        
        setState(() {
          _isUserWinner = isCurrentUserWinner;
          _winnerUsername = displayName;
        });
        
        debugPrint('🏆 $winType Winner: $_winnerUsername (${_isUserWinner ? "You" : "Other"})');
        _startSequence();
      } else {
        debugPrint('⚠️ No winner found');
        _navigateToHome();
      }
    } catch (e) {
      debugPrint('❌ Failed to fetch winner: $e');
      _navigateToHome();
    }
  }
  
  void _navigateToHome() {
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
      );
    }
  }

  void _startSequence() {
    // Show Game Over first
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _showGameOver = true);
        
        // Then show appropriate screen
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _showGameOver = false;
              if (_isUserWinner) {
                _showYouWon = true;
                // Navigate to coupon screen after showing "You Won"
                Future.delayed(Duration(seconds: 2), () {
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScratchRewardScreen(),
                      ),
                    );
                  }
                });
              } else {
                _showWinner = true;
                // Navigate to home after showing winner
                Future.delayed(Duration(seconds: 3), () {
                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (route) => false,
                    );
                  }
                });
              }
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              AppHeader(),
              Expanded(
                child: Container(
                  color: Colors.grey[100],
                  child: Center(
                    child: Text(
                      'Game Completed',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          if (_showGameOver) _buildGameOverScreen(),
          if (_showYouWon) _buildYouWonScreen(),
          if (_showWinner) _buildWinnerScreen(),
        ],
      ),
    );
  }

  Widget _buildGameOverScreen() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 25,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Game',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Over',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Image.asset(
                  'assets/images/numberBox2.png',
                  width: 100,
                  height: 100,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Image.asset(
                  'assets/images/numberBox1.png',
                  width: 100,
                  height: 100,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYouWonScreen() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 25,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'You',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Won',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Image.asset(
                  'assets/images/winEmoji.png',
                  width: 100,
                  height: 100,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 3,
                child: Image.asset(
                  'assets/images/coinsBag.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Image.asset(
                  'assets/images/numberBox1.png',
                  width: 100,
                  height: 100,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWinnerScreen() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 25,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Winner',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _winnerUsername,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Next time You\nwill be the Winner',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Image.asset(
                  'assets/images/winEmoji.png',
                  width: 100,
                  height: 100,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Image.asset(
                  'assets/images/numberBox1.png',
                  width: 100,
                  height: 100,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}