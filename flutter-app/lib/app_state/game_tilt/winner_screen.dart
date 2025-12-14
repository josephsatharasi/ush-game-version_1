import 'package:flutter/material.dart';
import 'package:ush_app/widgets/loction_header.dart';
import 'package:ush_app/app_state/game_tilt/scratch_reward_screen.dart';
import 'package:ush_app/app_state/game_tilt/motivation_screen.dart';
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
  bool _showMotivation = false;
  bool _isUserWinner = false;
  bool _isPartialWinner = false;
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
      
      // Fetch game status to get housie winner
      final response = await BackendApiConfig.getGameStatus(
        token: token,
        gameId: gameId,
      );
      
      debugPrint('🎮 Game Status Response: $response');
      
      final housieWinner = response['housieWinner'];
      
      if (housieWinner != null && housieWinner['userId'] != null) {
        final winnerUserId = housieWinner['userId'];
        
        // Fetch winner's user details to get username
        String winnerName = 'Unknown';
        try {
          final userResponse = await BackendApiConfig.getUserById(
            token: token,
            userId: winnerUserId,
          );
          winnerName = userResponse['username'] ?? 'Unknown';
        } catch (e) {
          debugPrint('⚠️ Failed to fetch winner username: $e');
          winnerName = housieWinner['cardNumber'] ?? 'Unknown';
        }
        
        // Check if user won any partial prizes
        final firstLineCompleted = prefs.getBool('firstLineCompleted') ?? false;
        final secondLineCompleted = prefs.getBool('secondLineCompleted') ?? false;
        final thirdLineCompleted = prefs.getBool('thirdLineCompleted') ?? false;
        final jaldhiCompleted = prefs.getBool('jaldhiCompleted') ?? false;
        
        setState(() {
          _isUserWinner = userId == winnerUserId;
          _isPartialWinner = firstLineCompleted || secondLineCompleted || thirdLineCompleted || jaldhiCompleted;
          _winnerUsername = winnerName;
        });
        
        debugPrint('🏆 Housie Winner: $_winnerUsername (${_isUserWinner ? "You" : "Other"})');
        debugPrint('🎯 Partial Winner: $_isPartialWinner');
        _startSequence();
      } else {
        debugPrint('⚠️ No housie winner found');
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
    // CASE 1: Housie Winner (Main Winner)
    if (_isUserWinner) {
      setState(() => _showYouWon = true);
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ScratchRewardScreen()),
          );
        }
      });
      return;
    }
    
    // CASE 2 & 3: Show Winner Announcement first
    setState(() => _showWinner = true);
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showWinner = false;
          _showMotivation = true;
        });
        
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            setState(() => _showMotivation = false);
            
            // CASE 2: Partial Winners - show coupon scratch
            if (_isPartialWinner) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ScratchRewardScreen()),
              );
            } else {
              // CASE 3: Losers - go to home
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            }
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
          
          if (_showYouWon) _buildYouWonScreen(),
          if (_showWinner) _buildWinnerScreen(),
          if (_showMotivation) MotivationScreen(),
        ],
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
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