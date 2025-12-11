import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_tilt_model.dart';
import '../../widgets/loction_header.dart';
import '../../config/backend_api_config.dart';

class DottedBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    const dotSize = 3.0;
    const spacing = 20.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class GameTiltWidget extends StatefulWidget {
  const GameTiltWidget({super.key});

  @override
  State<GameTiltWidget> createState() => _GameTiltWidgetState();
}

class _GameTiltWidgetState extends State<GameTiltWidget>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
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
  bool _isAppInBackground = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🎮 GAME START: GameTiltWidget initState called');
    WidgetsBinding.instance.addObserver(this);
    _coinAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _coinAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _coinAnimationController, curve: Curves.easeInOut),
    );
    debugPrint('🎮 GAME START: Animation controller initialized');
    _initTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🎮 GAME START: Post frame callback - fetching announced numbers');
      _fetchAnnouncedNumber();
    });
  }

  Future<void> _initTts() async {
    debugPrint('🔊 TTS: Initializing text-to-speech');
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    debugPrint('🔊 TTS: Text-to-speech initialized successfully');
  }

  @override
  void dispose() {
    debugPrint('🎮 GAME END: GameTiltWidget dispose called');
    WidgetsBinding.instance.removeObserver(this);
    _pauseAllActivities();
    _coinAnimationController.dispose();
    _audioPlayer.dispose();
    _flutterTts.stop();
    debugPrint('🎮 GAME END: All resources disposed');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('📱 APP LIFECYCLE: State changed to $state');
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        debugPrint('📱 APP LIFECYCLE: App going to background - pausing activities');
        _isAppInBackground = true;
        _pauseAllActivities();
        break;
      case AppLifecycleState.resumed:
        if (_isAppInBackground) {
          debugPrint('📱 APP LIFECYCLE: App resumed from background - resuming activities');
          _isAppInBackground = false;
          _resumeAllActivities();
        }
        break;
      case AppLifecycleState.hidden:
        debugPrint('📱 APP LIFECYCLE: App hidden');
        break;
    }
  }

  void _pauseAllActivities() {
    debugPrint('⏸️ PAUSE: Pausing all game activities');
    _animationTimer?.cancel();
    _numberFetchTimer?.cancel();
    _audioPlayer.stop();
    _flutterTts.stop();
    if (_coinAnimationController.isAnimating) {
      _coinAnimationController.stop();
    }
    if (mounted) {
      setState(() {
        _showCoin = false;
      });
    }
    debugPrint('⏸️ PAUSE: All activities paused');
  }

  void _resumeAllActivities() {
    debugPrint('▶️ RESUME: Resuming game activities');
    if (mounted && !_isAppInBackground) {
      _startContinuousAnimation();
      _startNumberPolling();
      debugPrint('▶️ RESUME: Activities resumed successfully');
    } else {
      debugPrint('▶️ RESUME: Cannot resume - mounted: $mounted, background: $_isAppInBackground');
    }
  }

  Future<void> _fetchAnnouncedNumber() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final gameId = prefs.getString('gameId');
      
      debugPrint('🔑 Token: ${token != null}, GameId: ${gameId != null}');
      
      if (token != null && gameId != null) {
        // First try to get announced numbers
        try {
          final result = await BackendApiConfig.getAnnouncedNumbers(
            token: token,
            gameId: gameId,
          );
          
          debugPrint('📦 Announced Numbers API Response: $result');
          
          if (mounted) {
            final currentNumber = result['currentNumber'] ?? 0;
            final announcedList = (result['announcedNumbers'] as List?)?.cast<int>() ?? [];
            final remaining = result['remaining'] ?? 0;
            
            debugPrint('✅ Backend Data - Current: $currentNumber, Announced: $announcedList, Remaining: $remaining');
            
            setState(() {
              _currentNumber = currentNumber;
              _announcedNumbers = announcedList;
            });
            
            // Show coin animation for current number if valid
            if (_currentNumber > 0) {
              debugPrint('⏳ Waiting for jar tilt to end before showing coin...');
              Future.delayed(const Duration(milliseconds: 2400), () {
                if (mounted) {
                  debugPrint('✅ Jar tilt ended, triggering coin animation for number: $_currentNumber');
                  _showCoinPop();
                }
              });
            }
          }
        } catch (announcedError) {
          debugPrint('❌ Announced Numbers API failed: $announcedError');
          
          // Fallback to game status API
          try {
            final statusResult = await BackendApiConfig.getGameStatus(
              token: token,
              gameId: gameId,
            );
            
            debugPrint('📦 Game Status API Response: $statusResult');
            
            if (mounted) {
              final currentNumber = statusResult['currentNumber'] ?? 0;
              final announcedList = (statusResult['announcedNumbers'] as List?)?.cast<int>() ?? [];
              
              debugPrint('✅ Status Data - Current: $currentNumber, Announced: $announcedList');
              
              setState(() {
                _currentNumber = currentNumber;
                _announcedNumbers = announcedList;
              });
              
              if (_currentNumber > 0) {
                Future.delayed(const Duration(milliseconds: 2400), () {
                  if (mounted) {
                    _showCoinPop();
                  }
                });
              }
            }
          } catch (statusError) {
            debugPrint('❌ Game Status API also failed: $statusError');
            // No fallback - rely purely on backend
          }
        }
      } else {
        debugPrint('❌ Missing token or gameId - cannot fetch from backend');
      }
      
      _startContinuousAnimation();
      _startNumberPolling();
    } catch (e) {
      debugPrint('❌ Critical error in _fetchAnnouncedNumber: $e');
      _startContinuousAnimation();
    }
  }

  void _startContinuousAnimation() {
    if (_animationTimer != null && _animationTimer!.isActive) {
      debugPrint('🏺 JAR ANIMATION: Already running, skipping start');
      return;
    }
    if (_isAppInBackground) {
      debugPrint('🏺 JAR ANIMATION: App in background, skipping start');
      return;
    }
    
    debugPrint('🏺 JAR ANIMATION: Starting jar tilt animation');
    _animationTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (!mounted || _isAppInBackground) {
        debugPrint('🏺 JAR ANIMATION: Stopping - mounted: $mounted, background: $_isAppInBackground');
        timer.cancel();
        return;
      }
      setState(() {
        _currentJarFrame = (_currentJarFrame % 6) + 1;
      });
    });
  }

  void _startNumberPolling() {
    if (_numberFetchTimer != null && _numberFetchTimer!.isActive) {
      debugPrint('🔄 POLLING: Already running, skipping start');
      return;
    }
    if (_isAppInBackground) {
      debugPrint('🔄 POLLING: App in background, skipping start');
      return;
    }
    
    debugPrint('🔄 POLLING: Starting number polling every 3 seconds');
    _numberFetchTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted || _isAppInBackground) {
        debugPrint('🔄 POLLING: Stopping - mounted: $mounted, background: $_isAppInBackground');
        timer.cancel();
        return;
      }
      
      debugPrint('🔄 POLLING: Fetching new numbers...');
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        final gameId = prefs.getString('gameId');
        
        if (token != null && gameId != null) {
          // Try announced numbers API first
          try {
            final result = await BackendApiConfig.getAnnouncedNumbers(
              token: token,
              gameId: gameId,
            );
            
            if (!mounted || _isAppInBackground) return;
            
            final newNumber = result['currentNumber'] ?? 0;
            final announcedList = (result['announcedNumbers'] as List?)?.cast<int>() ?? [];
            final remaining = result['remaining'] ?? 0;
            
            debugPrint('🔄 POLLING: API Response - Current: $newNumber, Announced: ${announcedList.length}, Remaining: $remaining');
            
            // Check if there's a new number to announce
            if (newNumber > 0 && newNumber != _currentNumber) {
              debugPrint('🔄 POLLING: New number detected: $newNumber (was $_currentNumber)');
              setState(() {
                _currentNumber = newNumber;
                _announcedNumbers = announcedList;
              });
              _model.updateFromAnnouncedNumbers(result);
              _showCoinPop();
            } else if (announcedList.isNotEmpty && announcedList.length != _announcedNumbers.length) {
              debugPrint('🔄 POLLING: Announced numbers list updated: ${announcedList.length} items');
              setState(() {
                _announcedNumbers = announcedList;
              });
              _model.updateFromAnnouncedNumbers(result);
            } else {
              debugPrint('🔄 POLLING: No changes detected');
            }
          } catch (announcedError) {
            debugPrint('🔄 POLLING: Announced numbers API failed, trying status API');
            final statusResult = await BackendApiConfig.getGameStatus(
              token: token,
              gameId: gameId,
            );
            
            if (!mounted || _isAppInBackground) return;
            
            final newNumber = statusResult['currentNumber'] ?? 0;
            final announcedList = (statusResult['announcedNumbers'] as List?)?.cast<int>() ?? [];
            
            if (newNumber > 0 && newNumber != _currentNumber) {
              debugPrint('🔄 POLLING: New number from status API: $newNumber');
              setState(() {
                _currentNumber = newNumber;
                _announcedNumbers = announcedList;
              });
              _model.updateFromGameStatus(statusResult);
              _showCoinPop();
            }
          }
        } else {
          debugPrint('🔄 POLLING: Missing token or gameId');
        }
      } catch (e) {
        debugPrint('❌ POLLING: Critical error - $e');
      }
    });
  }

  void _showCoinPop() {
    if (_isAppInBackground) {
      debugPrint('❌ Coin error: Unable to show - app in background');
      return;
    }
    if (_currentNumber == 0) {
      debugPrint('❌ Coin error: Unable to show - no valid number available');
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
      _audioPlayer.play(AssetSource('audios/jar_shaking.mp3')).catchError((e) {
        debugPrint('Audio play error: $e');
      });
      _flutterTts.speak(_currentNumber.toString()).catchError((e) {
        debugPrint('TTS error: $e');
      });
      
      if (mounted && !_isAppInBackground) {
        setState(() {
          _showCoin = true;
        });
        
        _coinAnimationController.reset();
        _coinAnimationController.forward().then((_) {
          if (!mounted || _isAppInBackground) return;
          
          Timer(const Duration(milliseconds: 4000), () {
            if (!mounted || _isAppInBackground) return;
            _coinAnimationController.reverse().then((_) {
              if (!mounted || _isAppInBackground) return;
              setState(() {
                _showCoin = false;
              });
              _audioPlayer.stop();
              debugPrint('🪙 Coin animation completed');
            });
          });
        });
      }
    } catch (e) {
      debugPrint('❌ Coin error: Unable to show - $e');
      if (mounted) {
        setState(() {
          _showCoin = false;
        });
      }
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
            child: CustomPaint(
              painter: DottedBackgroundPainter(),
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
                              child: Image.asset(
                                'assets/images/student_offer.png', 
                                width: 180,
                                height: 100,
                                fit: BoxFit.contain,
                              ),
                            );
                          },
                        ),
                        Row(
                          children: [
                            // Ticket button
                            GestureDetector(
                              onTap: () {
                                debugPrint('🎫 BUTTON: Ticket button tapped');
                                _showTicketDialog();
                              },
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
                                debugPrint('🔢 BUTTON: Numbers button tapped');
                                // Navigate to numbers screen without fam reference
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
                            AnimatedBuilder(
                              animation: _coinAnimation,
                              builder: (context, child) {
                                return Center(
                                  child: _buildCoin(),
                                );
                              },
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
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildCoin() {
    double progress = _coinAnimation.value.clamp(0.0, 1.0);
    double scale = 0.1 + (progress * 0.9);
    double opacity = progress.clamp(0.0, 1.0);
    
    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/images/fam_coin.png',
              width: 250,
              height: 250,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.monetization_on, color: Colors.white, size: 150),
                );
              },
            ),
            Text(
              _currentNumber.toString(),
              style: TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardButton(String name, Color color) {
    final isSelected = _model.selectedCardType == name;
    final isHousi = name == 'HOUSI';
    
    return GestureDetector(
      onTap: () {
        debugPrint('🎯 BUTTON: $name button tapped');
        setState(() {
          _model.selectCardType(name);
        });
        debugPrint('🎯 BUTTON: Card type selected: $name');
        // Navigate with current number
        if (name == 'HOUSI') {
          debugPrint('🎯 BUTTON: Navigating to HOUSI screen with number: $_currentNumber');
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
    debugPrint('🎫 TICKET: Opening ticket dialog');
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        debugPrint('🎫 TICKET: No token found, user needs to login');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please login first')),
          );
        }
        return;
      }
      
      debugPrint('🎫 TICKET: Fetching user bookings...');
      
      final result = await BackendApiConfig.getMyBookings(token: token);
      final bookingsList = result['bookings'] as List;
      
      debugPrint('🎫 TICKET: Found ${bookingsList.length} bookings');
      
      if (bookingsList.isEmpty) {
        debugPrint('🎫 TICKET: No tickets found for user');
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
      
      debugPrint('🎫 TICKET: Displaying ticket dialog with booking data');
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
      debugPrint('❌ TICKET: Failed to load tickets - $e');
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
        debugPrint('🎯 BUTTON: $name button tapped (with number $displayNumber)');
        setState(() {
          _model.selectCardType(name);
        });
        debugPrint('🎯 BUTTON: Card type selected: $name');
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
