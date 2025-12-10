
import 'package:flutter/material.dart';
import 'package:ush_app/widgets/loction_header.dart';
import 'package:ush_app/app_state/game_state_manager.dart';
import 'package:ush_app/app_state/game_tilt/scratch_reward_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NextGameScreeniWidget extends StatefulWidget {
  final String? winnerUsername;
  final String? winnerUserId;
  
  const NextGameScreeniWidget({
    super.key,
    this.winnerUsername,
    this.winnerUserId,
  });

  @override
  State<NextGameScreeniWidget> createState() => _NextGameScreeniWidgetState();
}

class _NextGameScreeniWidgetState extends State<NextGameScreeniWidget> with SingleTickerProviderStateMixin {
  int _currentPage = 0;
  final int _totalPages = 3;
  final Set<int> _selectedNumbers = {
    3, 7, 12, 18, 27,      // First line
    31, 36, 42, 48, 57,    // Second line
    61, 66, 72, 78, 87     // Third line
  }; // All Housi numbers
  final GameStateManager _gameState = GameStateManager();
  
  // Add state for screen management
  bool _showGameOver = false;
  bool _showYouWon = false;
  bool _showWinner = false;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _gameState.markAsVisited('HOUSI');
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100),
    );
    _checkIfUserWon();

  }

  Future<void> _checkIfUserWon() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    
    if (userId != null && widget.winnerUserId == userId) {
      _startWinSequence();
    } else {
      _startLoseSequence();
    }
  }

  void _startWinSequence() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _showGameOver = true);
        Future.delayed(Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _showGameOver = false;
              _showYouWon = true;
            });
            Future.delayed(Duration(seconds: 1), () {
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScratchRewardScreen(),
                  ),
                );
              }
            });
          }
        });
      }
    });
  }

  void _startLoseSequence() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _showGameOver = true);
        Future.delayed(Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _showGameOver = false;
              _showWinner = true;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          if (_showGameOver) _buildGameOverScreen(),
          if (_showYouWon) _buildYouWonScreen(),
          if (_showWinner) _buildWinnerScreen(),
          // Main content
          Column(
            children: [
              AppHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.arrow_back, size: 20),
                                SizedBox(width: 8),
                                Text('GO BACK', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        _buildNumberGridCard(),
                      
                        SizedBox(height: 12),
                        _buildGameTypeButtons(),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


Widget _buildNumberGridCard() {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 12),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
        
            GestureDetector(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Text(
                  'Numbers',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
                SizedBox(height: 200),
      // code for NExt winner
     Center(
  child: RichText(
    textAlign: TextAlign.center,
    text: TextSpan(
      children: [
        TextSpan(
          text: 'Next time You\nwill be the ',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        TextSpan(
          text: 'Winner',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.yellow, // 🔥 Yellow color for "Winner"
          ),
        ),
      ],
    ),
  ),
),
SizedBox(height: 80),

      ],
    ),
  );
}
  Widget _buildNumberButton(int number) {
    final isSelected = _selectedNumbers.contains(number);
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Color(0xFFE91E63) : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: isSelected ? Color(0xFFE91E63) : Colors.white, width: 2),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Center(
        child: Text(
          number.toString(),
          style: TextStyle(
            color: isSelected ? Colors.white : Color(0xFFE91E63),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildGameTypeButtons() {
    return Column(
      children: [
        Row(
          children: [
            Text(
  'Card Numbers',
  textAlign: TextAlign.left,
  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
),
          ],
        ),           SizedBox(height: 10),   Row(
          children: [
            Expanded(child: _buildGameButton('FIRST LINE', '1')),
            SizedBox(width: 10),
            Expanded(child: _buildGameButton('SECOND LINE', '2')),
            SizedBox(width: 10),
            Expanded(child: _buildGameButton('THIRD LINE', '3')),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildGameButton('JALDHI', '5')),
            SizedBox(width: 10),
            Expanded(child: _buildGameButton('HOUSI', null)),
          ],
        ),
      ],
    );
  }

  Widget _buildGameButton(String name, String? number) {
    // All buttons are dark gray and disabled except HOUSI which navigates to game over
    bool isHousi = name == 'HOUSI';
    
    return GestureDetector(
      onTap: null,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: isHousi ? Colors.white : Colors.transparent, width: 3),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                name,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (number != null)
              Positioned(
                left: 12,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Text(
                    number,
                    style: TextStyle(
                      color: Colors.grey[700]!.withValues(alpha: 0.3),
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            // Add "OVER" text for HOUSI button
            if (isHousi)
              Positioned(
                left: 12,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Text(
                    'OVER',
                    style: TextStyle(
                      color: Colors.grey[700]!.withValues(alpha: 0.3),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
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
                crossAxisAlignment: CrossAxisAlignment.center,
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
                    widget.winnerUsername ?? 'Unknown',
                    style: TextStyle(
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