import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_tilt_model.dart';
import '../../widgets/loction_header.dart';
import '../../config/backend_api_config.dart';

class GameTiltWidget extends StatefulWidget {
  const GameTiltWidget({super.key});

  @override
  State<GameTiltWidget> createState() => _GameTiltWidgetState();
}

class _GameTiltWidgetState extends State<GameTiltWidget>
    with SingleTickerProviderStateMixin {
  final GameTiltModel _model = GameTiltModel();
  int _currentJarFrame = 1;
  Timer? _animationTimer;
  Timer? _numberFetchTimer;
  bool _showCoin = false;
  late AnimationController _coinAnimationController;
  late Animation<double> _coinAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  int _currentNumber = 0;
  List<int> _announcedNumbers = [];

  @override
  void initState() {
    super.initState();
    _coinAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _coinAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _coinAnimationController, curve: Curves.easeInOut),
    );
    _initTts();
    _fetchAnnouncedNumber();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    _numberFetchTimer?.cancel();
    _coinAnimationController.dispose();
    _audioPlayer.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _fetchAnnouncedNumber() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final gameId = prefs.getString('gameId');
      
      debugPrint('🔑 Token: ${token != null}, GameId: ${gameId != null}');
      
      if (token != null && gameId != null) {
        final result = await BackendApiConfig.getAnnouncedNumbers(
          token: token,
          gameId: gameId,
        );
        
        debugPrint('📦 API Response: $result');
        
        if (mounted) {
          final newNumber = result['currentNumber'] ?? 0;
          final announcedList = (result['announcedNumbers'] as List?)?.cast<int>() ?? [];
          
          debugPrint('✅ Number fetched: $newNumber, Announced: $announcedList');
          
          if (newNumber > 0) {
            setState(() {
              _currentNumber = newNumber;
              _announcedNumbers = announcedList;
            });
            
            debugPrint('⏳ Waiting for jar tilt to end before showing coin...');
            Future.delayed(const Duration(milliseconds: 2400), () {
              if (mounted) {
                debugPrint('✅ Jar tilt ended, triggering coin animation');
                _showCoinPop();
              }
            });
          }
        }
      }
      
      _startContinuousAnimation();
      _startNumberPolling();
    } catch (e) {
      debugPrint('❌ Fetching error: Failed to fetch announced number: $e');
      _startContinuousAnimation();
    }
  }

  void _startContinuousAnimation() {
    if (_animationTimer != null && _animationTimer!.isActive) return;
    
    debugPrint('🏺 Jar tilt started');
    _animationTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _currentJarFrame = (_currentJarFrame % 6) + 1;
      });
    });
  }

  void _startNumberPolling() {
    if (_numberFetchTimer != null && _numberFetchTimer!.isActive) return;
    
    _numberFetchTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        final gameId = prefs.getString('gameId');
        
        if (token != null && gameId != null) {
          final result = await BackendApiConfig.getAnnouncedNumbers(
            token: token,
            gameId: gameId,
          );
          
          if (!mounted) return;
          
          final newNumber = result['currentNumber'] ?? 0;
          final announcedList = (result['announcedNumbers'] as List?)?.cast<int>() ?? [];
          
          if (newNumber > 0 && newNumber != _currentNumber) {
            debugPrint('✅ Number fetched (polling): $newNumber');
            setState(() {
              _currentNumber = newNumber;
              _announcedNumbers = announcedList;
            });
            _showCoinPop();
          }
        }
      } catch (e) {
        debugPrint('❌ Fetching error (polling): $e');
      }
    });
  }

  void _showCoinPop() {
    if (_currentNumber == 0) {
      debugPrint('❌ Coin error: Unable to show - number is 0');
      return;
    }
    if (!mounted) {
      debugPrint('❌ Coin error: Unable to show - widget not mounted');
      return;
    }
    if (_showCoin) {
      debugPrint('❌ Coin error: Unable to show - coin already showing');
      return;
    }
    
    debugPrint('🪙 Coin showing for number: $_currentNumber');
    
    try {
      _audioPlayer.play(AssetSource('audios/jar_shaking.mp3'));
      _flutterTts.speak(_currentNumber.toString());
      
      setState(() {
        _showCoin = true;
      });
      
      _coinAnimationController.reset();
      _coinAnimationController.forward().then((_) {
        if (!mounted) return;
        
        Timer(const Duration(milliseconds: 4000), () {
          if (!mounted) return;
          _coinAnimationController.reverse().then((_) {
            if (!mounted) return;
            setState(() {
              _showCoin = false;
            });
            _audioPlayer.stop();
            debugPrint('🪙 Coin animation completed');
          });
        });
      });
    } catch (e) {
      debugPrint('❌ Coin error: Unable to show - $e');
      setState(() {
        _showCoin = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Game?'),
            content: const Text('Do you want to exit the game?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        );
        return shouldExit ?? false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
        children: [
          const AppHeader(),
          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
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
                        Row(
                          children: [
                            // Ticket button
                            GestureDetector(
                              onTap: () => _showTicketDialog(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF059669),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: const Text(
                                  'Ticket',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Numbers button
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/fam-playground', arguments: 'FIRST LINE');
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
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
                      ],
                    ),
                    // Animated Coin Jar with Coin Pop
                    SizedBox(
                      height: 350,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          // Jar
                          Positioned(
                            top: 40,
                            child: Image.asset(
                              'assets/images/famjar$_currentJarFrame.png',
                              width: 170,
                              height: 210,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 170,
                                  height: 210,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(Icons.image_not_supported, size: 50),
                                );
                              },
                            ),
                          ),
                          // Coin Pop Animation - positioned above jar
                          if (_showCoin)
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: AnimatedBuilder(
                                animation: _coinAnimation,
                                builder: (context, child) {
                                  return Center(
                                    child: _buildCoin(),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // First row - 3 buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildCardButtonWithNumber('FIRST LINE', const Color(0xFF1E40AF), '1'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildCardButtonWithNumber('SECOND LINE', const Color(0xFFDC2626), '2'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildCardButtonWithNumber('THIRD LINE', const Color(0xFF059669), '3'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Second row - 2 buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildCardButtonWithNumber('JALDHI', const Color(0xFFF59E0B), '5'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildCardButton('HOUSI', const Color(0xFF9F1239)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildCoin() {
    double progress = _coinAnimation.value;
    double scale = 0.7 + (progress * 0.3);
    double opacity = progress < 0.15 ? progress * 6.67 : 1.0;
    
    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0xFFFFD700).withOpacity(0.6),
                blurRadius: 40,
                spreadRadius: 15,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/images/fam_coin.png',
                width: 280,
                height: 280,
                fit: BoxFit.contain,
              ),
              Text(
                _currentNumber.toString(),
                style: TextStyle(
                  fontSize: 120,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -5,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardButton(String name, Color color) {
    final isSelected = _model.selectedCardType == name;
    final isHousi = name == 'HOUSI';
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _model.selectCardType(name);
        });
        // Navigate with current number
        if (name == 'HOUSI') {
          Navigator.pushNamed(context, '/game-tilt-housi', arguments: _currentNumber);
        }
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (isHousi)
              Positioned(
                right: 20,
                top: 3,
                bottom: 3,
                child: Opacity(
                  opacity: 0.51,
                  child: Image.asset(
                    'assets/images/housi.png',
                    width: 36,
                    height: 44,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Text(
                        '💸',
                        style: TextStyle(
                          fontSize: 40,
                          color: Colors.white.withOpacity(0.51),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showTicketDialog() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please login first')),
          );
        }
        return;
      }
      
      final result = await BackendApiConfig.getMyBookings(token: token);
      final bookingsList = result['bookings'] as List;
      
      if (bookingsList.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No tickets found')),
          );
        }
        return;
      }
      
      final booking = bookingsList.first;
      final ticketNumbers = (booking['ticketNumbers'] as List?)?.cast<String>() ?? [];
      final cardNumbers = (booking['cardNumbers'] as List?)?.cast<String>() ?? [];
      final generatedNumbers = booking['generatedNumbers'] as List?;
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Your Tickets', style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (generatedNumbers != null)
                    ...List.generate(generatedNumbers.length, (index) {
                      final ticket = generatedNumbers[index] as Map<String, dynamic>;
                      final ticketId = ticketNumbers.length > index ? ticketNumbers[index] : 'Ticket ${index + 1}';
                      final cardId = cardNumbers.length > index ? cardNumbers[index] : '';
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index > 0) const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                ticketId,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF059669),
                                ),
                              ),
                              if (cardId.isNotEmpty)
                                Text(
                                  'Card: $cardId',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildTicketLine('1st Line', (ticket['firstLine'] as List?)?.cast<int>() ?? []),
                          const SizedBox(height: 8),
                          _buildTicketLine('2nd Line', (ticket['secondLine'] as List?)?.cast<int>() ?? []),
                          const SizedBox(height: 8),
                          _buildTicketLine('3rd Line', (ticket['thirdLine'] as List?)?.cast<int>() ?? []),
                        ],
                      );
                    }),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load tickets: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildTicketLine(String lineName, List<int> numbers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lineName,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: numbers.map((num) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              num.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildCardButtonWithNumber(String name, Color color, String displayNumber) {
    final isSelected = _model.selectedCardType == name;
    return GestureDetector(
      onTap: () {
        setState(() {
          _model.selectCardType(name);
        });
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              left: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: Text(
                  displayNumber,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
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
