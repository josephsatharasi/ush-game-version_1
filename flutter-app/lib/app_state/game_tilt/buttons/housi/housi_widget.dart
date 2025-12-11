
import 'package:flutter/material.dart';
import 'package:ush_app/widgets/loction_header.dart';
import 'package:ush_app/widgets/animated_jar_widget.dart';
import 'package:ush_app/app_state/game_state_manager.dart';
import 'package:ush_app/app_state/game_tilt/winner_screen.dart';
import 'package:ush_app/services/game_number_service.dart';
import 'package:ush_app/services/winner_service.dart';
import 'package:ush_app/models/win_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameTiltHousiWidget extends StatefulWidget {
  const GameTiltHousiWidget({super.key});

  @override
  State<GameTiltHousiWidget> createState() => _GameTiltHousiWidgetState();
}

class _GameTiltHousiWidgetState extends State<GameTiltHousiWidget> with SingleTickerProviderStateMixin {
  int _currentPage = 0;
  final int _totalPages = 3;
  final Set<int> _selectedNumbers = {
    3, 7, 12, 18, 27,      // First line
    31, 36, 42, 48, 57,    // Second line
    61, 66, 72, 78, 87     // Third line
  }; // All Housi numbers
  final GameStateManager _gameState = GameStateManager();
  
  String? _winnerUsername;
  String? _winnerUserId;
  bool _isClaimingWin = false;

  @override
  void initState() {
    super.initState();
    _gameState.markAsVisited('HOUSI');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
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
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: _buildNumberGridCard(),
                    ),
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
    );
  }


Widget _buildNumberGridCard() {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 12),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/student_offer.png',
              width: 180,
              height: 100,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 180,
                  height: 100,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange, width: 2),
                  ),
                  child: Image.asset(
                    'assets/images/student_offer.png', 
                    width: 180,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/fam-playground', arguments: 'HOUSI');
              },
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
        AnimatedJarWidget(),
        SizedBox(height: 12),
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
      onTap: isHousi ? () async {
        if (_isClaimingWin) return;
        
        setState(() => _isClaimingWin = true);
        try {
          GameNumberService().stopGame();
        } catch (e) {
          print('Error stopping game: $e');
        }
        
        try {
          final prefs = await SharedPreferences.getInstance();
          final gameId = prefs.getString('gameId');
          final cardNumber = prefs.getString('cardNumber');
          
          if (gameId != null && cardNumber != null) {
            final winnerService = WinnerService();
            await winnerService.claimWin(
              gameId: gameId,
              winType: WinType.HOUSIE,
              cardNumber: cardNumber,
            );
            
            final winner = await winnerService.getHousieWinner(gameId);
            if (winner != null) {
              setState(() {
                _winnerUsername = winner.username ?? 'Unknown';
                _winnerUserId = winner.userId;
              });
            }
          }
        } catch (e) {
          print('Error claiming win: $e');
        } finally {
          setState(() => _isClaimingWin = false);
        }
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WinnerScreen(
                winnerUsername: _winnerUsername ?? 'Unknown',
                winnerUserId: _winnerUserId ?? '',
              ),
            ),
          );
        }
      } : null,
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
}