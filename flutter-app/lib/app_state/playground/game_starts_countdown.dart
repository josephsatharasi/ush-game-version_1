import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/loction_header.dart';
import '../../services/game_number_service.dart';
import '../../services/background_music_service.dart';
import '../../config/backend_api_config.dart';
import '../game_tilt/game_tilt_widget.dart';
class GameStartsCountdown extends StatefulWidget {
  const GameStartsCountdown({super.key});

  @override
  State<GameStartsCountdown> createState() => _GameStartsCountdownState();
}

class _GameStartsCountdownState extends State<GameStartsCountdown> {
  String? selectedCardType;
  late Timer _countdownTimer;
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 5;
  bool _countdownComplete = false;
  final TextEditingController _cardNumberController = TextEditingController();
  String _generatedNumbers = '';
  String _cardNumber = '';

  @override
  void initState() {
    super.initState();
    BackgroundMusicService().play();
    _loadGameData();
  }

  Future<void> _loadGameData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final gameId = prefs.getString('gameId');
      
      if (token != null && gameId != null) {
        // Load countdown
        final countdown = await BackendApiConfig.getCountdown(
          token: token,
          gameId: gameId,
        );
        
        // Load user bookings to get generated numbers
        try {
          final bookings = await BackendApiConfig.getMyBookings(token: token);
          final bookingsList = bookings['bookings'] as List;
          
          if (bookingsList.isNotEmpty) {
            final latestBooking = bookingsList.first;
            final generatedNumbers = latestBooking['generatedNumbers'] as List?;
            final cardNumbers = latestBooking['cardNumbers'] as List?;
            
            if (generatedNumbers != null && generatedNumbers.isNotEmpty) {
              await prefs.setString('generatedNumbers', generatedNumbers[0]);
              if (mounted) {
                setState(() {
                  _generatedNumbers = generatedNumbers[0];
                });
              }
            }
            if (cardNumbers != null && cardNumbers.isNotEmpty) {
              await prefs.setString('cardNumber', cardNumbers[0]);
              if (mounted) {
                setState(() {
                  _cardNumber = cardNumbers[0];
                });
              }
            }
          }
        } catch (e) {
          debugPrint('Failed to load bookings: $e');
        }
        
        if (mounted) {
          final timeRemaining = countdown['timeRemaining'] ?? 0;
          setState(() {
            _hours = timeRemaining ~/ 3600;
            _minutes = (timeRemaining % 3600) ~/ 60;
            _seconds = timeRemaining % 60;
          });
          _startCountdown();
        }
      } else {
        _startCountdown();
      }
    } catch (e) {
      _startCountdown();
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else if (_minutes > 0) {
          _minutes--;
          _seconds = 59;
        } else if (_hours > 0) {
          _hours--;
          _minutes = 59;
          _seconds = 59;
        } else {
          _countdownTimer.cancel();
          _countdownComplete = true;
        }
      });
    });
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    _cardNumberController.dispose();
    super.dispose();
  }

  String _padZero(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF9CA3AF),
      body: Stack(
        children: [
          Column(
            children: [
              AppHeader(),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        // Numbers button
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                            decoration: BoxDecoration(
                              color: Color(0xFF1E3A8A),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Text(
                              'Numbers',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        SizedBox(height: 35),
                        // Game Card - Countdown or Started UI
                        if (!_countdownComplete)
                          GestureDetector(
                            onTap: () {
                             // Navigator.pushNamed(context, '/famjar-tilt');
                            },
                            child: Container(
                              width: 290,
                              height: 290,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF1E40AF),
                                    Color(0xFF3B82F6),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black45,
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Top right ticket - numbers: 1, 11, 29, 13, 9
                               // TOP-RIGHT ticket
Positioned(
  top: -20,     // adjust vertically
  right: -10,    // adjust horizontally
  child: Image.asset(
                                      'assets/images/Group 322.png',
                                      width: 110,
                                      height: 110,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 110,
                                          height: 110,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(18),
                                          ),
                                        );
                                      },
                                    ),
),

// BOTTOM-RIGHT larger ticket
Positioned(
  top: 10,     // push down slightly
  right: -10,  // move slightly outside the card
  child: Image.asset(
                                      'assets/images/Group 264.png',
                                      width: 110,
                                      height: 110,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 110,
                                          height: 110,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(18),
                                          ),
                                        );
                                      },
                                    ),
),

                                // Decorative hourglass / time image at bottom-left (overlapping)
                                Positioned(
                                  bottom: 12,
                                  //top:0,
                                  left: -7,
                                  child: Transform.rotate(
                                    angle: -0.1,
                                    child: Image.asset(
                                      'assets/images/44 1.png',
                                      width: 110,
                                      height: 120,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 110,
                                          height: 110,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(18),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                // Center content: title + "Starts in" timer
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Game',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 30,
                                          fontWeight: FontWeight.w900,
                                          height: 1.05,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        'Starts in',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      // Timer row (static look like screenshot)
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          // Hours box
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              _padZero(_hours),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            ':',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          // Minutes box
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              _padZero(_minutes),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            ':',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          // Seconds box
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              _padZero(_seconds),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            ),
                          )
                        else
                          // Game Started UI
                          GestureDetector(
                            onTap: () {
                             // Navigator.pushNamed(context, '/famjar-tilt');
                            },
                            child: Container(
                              width: 290,
                              height: 290,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF1E40AF),
                                    Color(0xFF3B82F6),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black45,
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                                                // Top right ticket
                                Positioned(
                                  top: -30,
                                  left: 2,
                                  child: Image.asset(
                                     'assets/images/topsideleft.png',
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 110,
                                        height: 110,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                // Bottom right ticket
                                Positioned(
                                  top: 7,
                                  right: 0,
                                  child: Image.asset(
                                    'assets/images/topSideright.png',
                                    width: 110,
                                    height: 110,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 110,
                                        height: 110,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                      );
                                    },
                                  ),
),

                                // Center content: Game Started
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(width: 1,height: 50,),
                                      Text(
                                        'Game',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 35,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(width: 50,),
                                      Text(
                                        'Started',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 35,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      GestureDetector(
                                        onTap: () {
                                          print(_cardNumberController.text);
                                          print(_cardNumberController.text.isNotEmpty);
                                          if (_cardNumberController.text.isNotEmpty) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => const GameTiltWidget()),
                                            );
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: SizedBox(
                                            width: 140,
                                            child: TextField(
  controller: _cardNumberController,
  textAlign: TextAlign.center,
  keyboardType: TextInputType.number,
  maxLength: 5,
  obscureText: true,
  obscuringCharacter: 'x',

  onChanged: (value) async {
    if (value.length == 5) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final gameId = prefs.getString('gameId');
      final storedCardNumbers = prefs.getString('cardNumber');
      final generatedNumbers = prefs.getString('generatedNumbers');
      
      // Validate card number matches stored card
      if (storedCardNumbers != null && value != storedCardNumbers) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Card number does not match your booking'),
              backgroundColor: Colors.red,
            ),
          );
        }
        _cardNumberController.clear();
        return;
      }
      
      // Validate generated numbers exist
      if (generatedNumbers == null || generatedNumbers.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No ticket numbers found. Please book a ticket first.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        _cardNumberController.clear();
        return;
      }
      
      // Validate 15 numbers exist
      final numbers = generatedNumbers.split(',');
      if (numbers.length != 15) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invalid ticket: Expected 15 numbers, found ${numbers.length}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        _cardNumberController.clear();
        return;
      }
      
      // All validations passed
      if (token != null && gameId != null) {
        try {
          await BackendApiConfig.verifyCard(
            token: token,
            gameId: gameId,
            cardNumber: value,
          );
        } catch (e) {
          // Backend verification failed but local validation passed
          debugPrint('Backend verification failed: $e');
        }
      }
      
      BackgroundMusicService().stop();
      GameNumberService().startGame();
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GameTiltWidget()),
        );
      }
    }
  },

  decoration: InputDecoration(
    labelText: 'Enter your card number',
    labelStyle: TextStyle(
      color: Color(0xFF1E3A8A),
      fontSize: 12,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide.none,
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    counterText: '',
  ),
  style: TextStyle(
    color: Color(0xFF1E3A8A),
    fontSize: 12,
    fontWeight: FontWeight.bold,
    letterSpacing: 2,
  ),
),
 ),
                                        ),
                                      ),
                                      if (_generatedNumbers.isNotEmpty) ...[
                                        SizedBox(height: 12),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.9),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                'Your Numbers',
                                                style: TextStyle(
                                                  color: Color(0xFF1E3A8A),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Wrap(
                                                spacing: 3,
                                                runSpacing: 3,
                                                alignment: WrapAlignment.center,
                                                children: _generatedNumbers.split(',').map((num) => Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFF1E3A8A),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    num.trim(),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 8,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                )).toList(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            ),
                          ),
                        SizedBox(height: 45),
                        // Card Number section
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Card Number',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        // First row - 3 buttons
                        Row(
                          children: [
                            Expanded(
                              child: _buildCardButton('FIRST LINE', Color(0xFF1E3A8A)),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: _buildCardButton('SECOND LINE', Color(0xFF7F1D1D)),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: _buildCardButton('THIRD LINE', Color(0xFF065F46)),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        // Second row - 2 buttons
                        Row(
                          children: [
                            Expanded(
                              child: _buildCardButton('JALDHI', Color(0xFF78350F)),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: _buildCardButton('HOUSI', Color(0xFF831843)),
                            ),
                          ],
                        ),
                        SizedBox(height: 40),
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

  Widget _buildCardButton(String name, Color color) {
    final isSelected = selectedCardType == name;
    return GestureDetector(
      onTap: () async {
        setState(() {
          selectedCardType = name;
        });
        
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        final gameId = prefs.getString('gameId');
        
        if (token != null && gameId != null) {
          try {
            final winTypeMap = {
              'FIRST LINE': 'FIRST_LINE',
              'SECOND LINE': 'SECOND_LINE',
              'THIRD LINE': 'THIRD_LINE',
              'JALDHI': 'JALDI',
              'HOUSI': 'HOUSIE',
            };
            
            final winType = winTypeMap[name];
            if (winType != null) {
              await prefs.setString('selectedWinType', winType);
            }
          } catch (e) {
            // Silently fail
          }
        }
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniTicket(List<List<int?>> numbers) {
    return Container(
      width: 105,
      height: 105,
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: numbers.map((row) {
          return Expanded(
            child: Row(
              children: row.map((number) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.all(0.5),
                    decoration: BoxDecoration(
                      color: number == null ? Colors.transparent : Colors.white,
                      border: number != null
                          ? Border.all(color: Colors.black, width: 1.2)
                          : null,
                    ),
                    child: Center(
                      child: number != null
                          ? Text(
                              number.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            )
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}
