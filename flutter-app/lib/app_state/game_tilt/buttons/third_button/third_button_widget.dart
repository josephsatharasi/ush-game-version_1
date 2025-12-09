import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ush_app/widgets/loction_header.dart';
import 'package:ush_app/widgets/animated_jar_widget.dart';
import 'package:ush_app/config/backend_api_config.dart';
import 'package:ush_app/services/game_number_service.dart';
import 'package:ush_app/app_state/game_state_manager.dart';

class GameTiltThirdButtonWidget extends StatefulWidget {
  const GameTiltThirdButtonWidget({super.key});

  @override
  State<GameTiltThirdButtonWidget> createState() => _GameTiltThirdButtonWidgetState();
}

class _GameTiltThirdButtonWidgetState extends State<GameTiltThirdButtonWidget> {
  int _currentPage = 0;
  final int _totalPages = 3;
  final Set<int> _selectedNumbers = {};
  final Set<int> _markedNumbers = {};
  final GameStateManager _gameState = GameStateManager();

  @override
  void initState() {
    super.initState();
    _gameState.markAsVisited('THIRD LINE');
    _markedNumbers.addAll(GameNumberService().markedNumbers);
    _loadThirdLineNumbers();
  }

  Future<void> _loadThirdLineNumbers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token != null) {
        final result = await BackendApiConfig.getMyBookings(token: token);
        final bookingsList = result['bookings'] as List;
        
        if (bookingsList.isNotEmpty) {
          final booking = bookingsList.first;
          final generatedNumbers = booking['generatedNumbers'] as List?;
          
          if (generatedNumbers != null && generatedNumbers.isNotEmpty) {
            final firstTicket = generatedNumbers[0] as Map<String, dynamic>;
            final thirdLine = (firstTicket['thirdLine'] as List?)?.cast<int>() ?? [];
            if (mounted) {
              setState(() {
                _selectedNumbers.clear();
                _selectedNumbers.addAll(thirdLine);
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to load third line numbers: $e');
    }
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
    );
  }

  Widget _buildNumberGridCard() {

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 12),
      
      child: Column(
        children: [
             // Student offer banner and Numbers button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Student offer banner
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
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('OFFERS FOR', 
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                  Text('STUDENT', 
                                      style: TextStyle(
                                          fontSize: 20, 
                                          fontWeight: FontWeight.bold, 
                                          color: Color(0xFFF59E0B))),
                                  Text('ONLY 50 RS', 
                                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            );
                          },
                        ),
                        // Numbers button
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/fam-playground', arguments: 'THIRD LINE');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3A8A),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Text(
                              'Numbers',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                    AnimatedJarWidget(),
                    const SizedBox(height: 12),
        ],
      ),
    );
  }
  Widget _buildNumberButton(int number) {
    final isSelected = _selectedNumbers.contains(number);
    final isMarked = _markedNumbers.contains(number);
    return Container(
      decoration: BoxDecoration(
        color: isMarked ? Color(0xFFE91E63) : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: isMarked ? Color(0xFFE91E63) : Colors.white, width: 2),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Center(
        child: Text(
          number.toString(),
          style: TextStyle(
            color: isMarked ? Colors.white : Color(0xFFE91E63),
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
            Expanded(child: _buildGameButton('FIRST LINE', Color(0xFF1E40AF), '1', false)),
            SizedBox(width: 10),
            Expanded(child: _buildGameButton('SECOND LINE', Color(0xFFDC2626), '2', false)),
            SizedBox(width: 10),
            Expanded(child: _buildGameButton('THIRD LINE', Color(0xFF059669), '3', true)),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildGameButton('JALDHI', Color(0xFFF59E0B), '5', false)),
            SizedBox(width: 10),
            Expanded(child: _buildGameButton('HOUSI', Color(0xFF9F1239), null, false)),
          ],
        ),
      ],
    );
  }

  Widget _buildGameButton(String name, Color color, String? number, bool isSelected) {
    bool isVisited = _gameState.isVisited(name);
    
    return GestureDetector(
      onTap: () {
        if (name == 'FIRST LINE') {
          Navigator.pushNamed(context, '/game-tilt-first');
        } else if (name == 'SECOND LINE') {
          Navigator.pushNamed(context, '/game-tilt-second');
        } else if (name == 'JALDHI') {
          Navigator.pushNamed(context, '/game-tilt-jaldhi');
        } else if (name == 'HOUSI') {
          Navigator.pushNamed(context, '/game-tilt-housi');
        }
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isVisited ? Colors.grey : color,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: isSelected ? Colors.white : Colors.transparent, width: 3),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
        ),
        child: Stack(
          children: [
            Center(child: Text(name, style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))),
            if (number != null)
              Positioned(
                left: 12,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Text(number, style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 50, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
