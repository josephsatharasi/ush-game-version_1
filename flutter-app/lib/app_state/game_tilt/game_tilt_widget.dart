import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_tilt_model.dart';
import '../../widgets/loction_header.dart';
import '../../config/backend_api_config.dart';
import '../../services/game_number_service.dart';
import 'winner_screen.dart';

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
  final List<int> _numberQueue = [];
  bool _isProcessingNumber = false;
  String? _userId;
  Timer? _announcementTimer;

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
      _loadUserTicket();
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
  

  
  Future<void> _loadUserTicket() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      _userId = prefs.getString('userId');
      
      if (token != null) {
        final result = await BackendApiConfig.getMyBookings(token: token);
        final bookingsList = result['bookings'] as List;
        
        if (bookingsList.isNotEmpty) {
          final booking = bookingsList.first;
          final generatedNumbers = booking['generatedNumbers'] as List?;
          
          if (generatedNumbers != null && generatedNumbers.isNotEmpty) {
            final firstTicket = generatedNumbers[0] as Map<String, dynamic>;
            _model.loadTicketNumbers(firstTicket);
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Failed to load user ticket: $e');
    }
  }

  @override
  void dispose() {
    debugPrint('🎮 GAME END: GameTiltWidget dispose called');
    WidgetsBinding.instance.removeObserver(this);
    _animationTimer?.cancel();
    _numberFetchTimer?.cancel();
    _announcementTimer?.cancel();
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
    debugPrint('⏸️ PAUSE: Pausing visual activities only - keeping polling active');
    _animationTimer?.cancel();
    _animationTimer = null;
    _announcementTimer?.cancel();
    _announcementTimer = null;
    // Don't cancel number polling - let it continue in background
    // _numberFetchTimer?.cancel();
    // _numberFetchTimer = null;
    _audioPlayer.stop();
    _flutterTts.stop();
    if (_coinAnimationController.isAnimating) {
      _coinAnimationController.stop();
    }
    if (mounted) {
      try {
        setState(() {
          _showCoin = false;
        });
      } catch (e) {
        debugPrint('⏸️ PAUSE: setState error (widget disposed): $e');
      }
    }
    debugPrint('⏸️ PAUSE: All activities paused');
  }

  void stopGameCompletely() {
    debugPrint('🛑 GAME STOP: Stopping all game activities permanently');
    _pauseAllActivities();
    // Mark game as stopped to prevent any restart
    _isAppInBackground = true;
  }

  void _resumeAllActivities() {
    debugPrint('▶️ RESUME: Resuming visual activities');
    if (mounted && !_isAppInBackground) {
      _startContinuousAnimation();
      // Polling never stopped, no need to restart
      debugPrint('▶️ RESUME: Visual activities resumed successfully');
    } else {
      debugPrint('▶️ RESUME: Cannot resume - mounted: $mounted, background: $_isAppInBackground');
    }
  }

  Future<void> _fetchAnnouncedNumber() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final gameId = prefs.getString('gameId');
      
      debugPrint('🔑 BACKEND: Token: ${token != null}, GameId: ${gameId != null}');
      
      if (token != null && gameId != null) {
        final result = await BackendApiConfig.getAnnouncedNumbers(
          token: token,
          gameId: gameId,
        );
        
        debugPrint('📦 BACKEND: API Response: $result');
        
        if (mounted) {
          final currentNumber = result['currentNumber'] ?? 0;
          final announcedList = (result['announcedNumbers'] as List?)?.cast<int>() ?? [];
          final remaining = result['remaining'] ?? 0;
          
          debugPrint('✅ BACKEND: Current: $currentNumber, Announced: $announcedList, Remaining: $remaining');
          _model.updateFromAnnouncedNumbers(result);
          
          setState(() {
            _currentNumber = currentNumber;
            _announcedNumbers = announcedList;
          });
          
          // Show coin animation for current number if valid
          if (_currentNumber > 0) {
            debugPrint('🏺 JAR: Initial load - showing coin for: $_currentNumber');
            _processNumber(_currentNumber);
          }
        }
      } else {
        debugPrint('❌ BACKEND: Missing credentials - cannot fetch');
      }
      
      _startContinuousAnimation();
      _startNumberPolling();
    } catch (e) {
      debugPrint('❌ BACKEND: Critical error - $e');
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
    
    debugPrint('🔄 POLLING: Starting backend polling every 1 second');
    _numberFetchTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) {
        debugPrint('🔄 POLLING: Stopping - widget disposed');
        timer.cancel();
        return;
      }
      
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        final gameId = prefs.getString('gameId');
        
        if (token != null && gameId != null) {
          // Get game status first to check if game is LIVE
          final statusResult = await BackendApiConfig.getGameStatus(
            token: token,
            gameId: gameId,
          );
          
          if (!mounted) return;
          
          final gameStatus = statusResult['status'] ?? 'WAITING';
          final newNumber = statusResult['currentNumber'] ?? 0;
          final announcedList = (statusResult['announcedNumbers'] as List?)?.cast<int>() ?? [];
          final remaining = 90 - announcedList.length;
          
          debugPrint('🔄 BACKEND: Status: $gameStatus, Current: $newNumber, Count: ${announcedList.length}, Remaining: $remaining');
          debugPrint('🔢 BACKEND: Numbers: $announcedList');
          
          // Update model with game status
          _model.updateFromGameStatus(statusResult);
          
          // DEFENSIVE CHECK: Validate game completion
          if (gameStatus == 'COMPLETED') {
            final hasHousieWinner = statusResult['housieWinner'] != null && 
                                   statusResult['housieWinner']['userId'] != null &&
                                   statusResult['housieWinner']['userId'].toString().isNotEmpty;
            
            if (announcedList.length < 90 && !hasHousieWinner) {
              debugPrint('⚠️ WARNING: Backend marked game COMPLETED but only ${announcedList.length} numbers announced and no housie winner!');
              debugPrint('⚠️ Ignoring COMPLETED status and continuing game...');
              // Don't stop polling, continue game
              return;
            }
            
            debugPrint('✅ Game legitimately completed: ${announcedList.length} numbers or housie winner');
            debugPrint('⏹️ POLLING: Stopping - game completed');
            _numberFetchTimer?.cancel();
            _numberFetchTimer = null;
            _numberQueue.clear(); // Clear queue
            _handleGameCompletion();
            return;
          }
          
          // Stop polling if game is not LIVE and not COMPLETED
          if (gameStatus != 'LIVE') {
            debugPrint('⏹️ POLLING: Game status is $gameStatus - stopping announcements');
            _numberFetchTimer?.cancel();
            _numberFetchTimer = null;
            return;
          }
          
          // Check for new number announcement - announce immediately
          if (newNumber > 0 && newNumber != _currentNumber) {
            debugPrint('🎆 NEW NUMBER: $newNumber (was $_currentNumber)');
            
            setState(() {
              _currentNumber = newNumber;
              _announcedNumbers = announcedList;
            });
            
            // Broadcast to all screens
            GameNumberService().updateCurrentNumber(newNumber);
            GameNumberService().updateAnnouncedNumbers(announcedList);
            
            // Play audio and TTS
            _audioPlayer.play(AssetSource('audios/jar_shaking.mp3')).catchError((e) {
              debugPrint('❌ AUDIO: Error - $e');
            });
            
            _flutterTts.speak(newNumber.toString()).catchError((e) {
              debugPrint('❌ TTS: Error - $e');
            });
            
            // Show visual if on game screen
            if (mounted && !_isAppInBackground) {
              _processNumber(newNumber);
            }
          } else if (announcedList.length != _announcedNumbers.length) {
            debugPrint('🔄 BACKEND: List updated: ${announcedList.length} numbers');
            setState(() {
              _announcedNumbers = announcedList;
            });
            GameNumberService().updateAnnouncedNumbers(announcedList);
          }
        }
      } catch (e) {
        debugPrint('❌ BACKEND: Polling error - $e');
        // Continue polling even on error
      }
    });
  }


  void _processNumber(int number) {
    _showCoinPop();
  }

  void _showCoinPop() {
    if (_currentNumber == 0 || !mounted || _isAppInBackground) {
      return;
    }
    
    // Skip if already showing coin
    if (_showCoin) {
      return;
    }
    
    debugPrint('🪙 COIN: Showing visual for: $_currentNumber');
    
    setState(() {
      _showCoin = true;
    });
    
    _coinAnimationController.reset();
    _coinAnimationController.forward().then((_) {
      if (!mounted) return;
      
      Timer(const Duration(milliseconds: 2500), () {
        if (!mounted) return;
        _coinAnimationController.reverse().then((_) {
          if (!mounted) return;
          setState(() {
            _showCoin = false;
          });
          debugPrint('🪙 COIN: Animation completed for $_currentNumber');
        });
      });
    });
  }



  void _handleGameCompletion() {
    if (!mounted) return;
    
    // Stop all activities
    _pauseAllActivities();
    
    // Navigate to winner screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const WinnerScreen(),
      ),
    );
  }

  Future<void> _exitGame() async {
    debugPrint('🚪 EXIT: User requested to exit game');
    
    // Clean up game state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isInGame', false);
    debugPrint('🚪 EXIT: Game state cleared');
    
    // Stop all activities before navigation
    _pauseAllActivities();
    
    if (mounted) {
      // Navigate to home and clear all previous routes
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/home',
        (route) => false,
      );
      debugPrint('🚪 EXIT: Navigated to home screen');
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
                onPressed: () {
                  Navigator.of(context).pop(true);
                  _exitGame();
                },
                child: const Text('Yes'),
              ),
            ],
          ),
        );
        return false; // Prevent default back behavior
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
                        Flexible(
                          flex: 5,
                          child: Image.asset(
                            'assets/images/student_offer.png', 
                            width: 150,
                            height: 100,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 150,
                                height: 100,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.orange, width: 2),
                                ),
                                child: Image.asset(
                                  'assets/images/student_offer.png', 
                                  width: 150,
                                  height: 100,
                                  fit: BoxFit.contain,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          flex: 5,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Ticket button
                              Flexible(
                                child: GestureDetector(
                                  onTap: () {
                                    debugPrint('🎫 BUTTON: Ticket button tapped');
                                    _showTicketDialog();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF059669),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: const Text(
                                      'Ticket',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Numbers button
                              Flexible(
                                child: GestureDetector(
                                  onTap: () async {
                                    debugPrint('🔢 BUTTON: Numbers button tapped');
                                    debugPrint('🔢 BUTTON: Navigating to fam-playground - keeping announcements running');
                                    // Don't stop activities - let them run in background
                                    await Navigator.pushNamed(context, '/fam-playground');
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E3A8A),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: const Text(
                                      'Numbers',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                          child: _buildLineButton('FIRST LINE', const Color(0xFF1E40AF), '1'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildLineButton('SECOND LINE', const Color(0xFFDC2626), '2'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildLineButton('THIRD LINE', const Color(0xFF059669), '3'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Second row - 2 buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildLineButton('JALDHI', const Color(0xFFF59E0B), '5'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildLineButton('HOUSI', const Color(0xFF9F1239), null),
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

   Future<void> _handleLineButtonTap(String lineType) async {
    debugPrint('🎯 BUTTON: $lineType tapped');
    
    // Check if already completed
    bool alreadyClaimed = false;
    switch (lineType) {
      case 'FIRST LINE':
        alreadyClaimed = _model.firstLineCompleted;
        break;
      case 'SECOND LINE':
        alreadyClaimed = _model.secondLineCompleted;
        break;
      case 'THIRD LINE':
        alreadyClaimed = _model.thirdLineCompleted;
        break;
      case 'JALDHI':
        alreadyClaimed = _model.jaldhiCompleted;
        break;
      case 'HOUSI':
        alreadyClaimed = _model.housiCompleted;
        break;
    }
    
    if (alreadyClaimed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$lineType already claimed!'),
          backgroundColor: Colors.grey,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    // Load marked numbers to validate
    final prefs = await SharedPreferences.getInstance();
    final markedList = prefs.getStringList('markedNumbers') ?? [];
    final markedNumbers = markedList.map((e) => int.parse(e)).toSet();
    
    // Get line numbers
    List<int> lineNumbers = [];
    switch (lineType) {
      case 'FIRST LINE':
        lineNumbers = _model.firstLineNumbers;
        break;
      case 'SECOND LINE':
        lineNumbers = _model.secondLineNumbers;
        break;
      case 'THIRD LINE':
        lineNumbers = _model.thirdLineNumbers;
        break;
      case 'JALDHI':
      case 'HOUSI':
        lineNumbers = _model.allTicketNumbers;
        break;
    }
    
    // Validate: all line numbers must be announced AND marked
    bool allAnnounced = lineNumbers.every((num) => _announcedNumbers.contains(num));
    bool allMarked = lineNumbers.every((num) => markedNumbers.contains(num));
    
    if (!allAnnounced) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$lineType not completed yet! Wait for all numbers.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    if (!allMarked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please mark all numbers in the number board first!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    await _claimWin(lineType);
  }
  
  Future<void> _claimWin(String winType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final gameId = prefs.getString('gameId');
      final cardNumber = prefs.getString('cardNumber');
      
      if (token == null || gameId == null || cardNumber == null) {
        throw Exception('Missing credentials');
      }
      
      debugPrint('🏆 Claiming win for $winType with card $cardNumber');
      
      final winTypeMap = {
        'FIRST LINE': 'FIRST_LINE',
        'SECOND LINE': 'SECOND_LINE',
        'THIRD LINE': 'THIRD_LINE',
        'JALDHI': 'JALDI',
        'HOUSI': 'HOUSIE',
      };
      
      final response = await BackendApiConfig.claimWin(
        token: token,
        gameId: gameId,
        winType: winTypeMap[winType]!,
        cardNumber: cardNumber,
      );
      
      // Save coupon data from response
      if (response['couponCode'] != null) {
        await prefs.setString('wonCouponCode', response['couponCode']);
        await prefs.setInt('wonCouponValue', response['couponValue'] ?? 0);
        debugPrint('🎟️ Coupon saved: ${response['couponCode']} - ₹${response['couponValue']}');
      }
      
      if (mounted) {
        setState(() {
          switch (winType) {
            case 'FIRST LINE':
              _model.firstLineCompleted = true;
              prefs.setBool('firstLineCompleted', true);
              break;
            case 'SECOND LINE':
              _model.secondLineCompleted = true;
              prefs.setBool('secondLineCompleted', true);
              break;
            case 'THIRD LINE':
              _model.thirdLineCompleted = true;
              prefs.setBool('thirdLineCompleted', true);
              break;
            case 'JALDHI':
              _model.jaldhiCompleted = true;
              prefs.setBool('jaldhiCompleted', true);
              break;
            case 'HOUSI':
              _model.housiCompleted = true;
              prefs.setBool('housiCompleted', true);
              break;
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 $winType claimed successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Navigate to winner screen after ANY win
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            stopGameCompletely();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const WinnerScreen(),
              ),
            );
          }
        });
      }
    } catch (e) {
      debugPrint('❌ Failed to claim win: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to claim: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

  Widget _buildLineButton(String name, Color color, String? displayNumber) {
    bool isCompleted = false;
    switch (name) {
      case 'FIRST LINE':
        isCompleted = _model.firstLineCompleted;
        break;
      case 'SECOND LINE':
        isCompleted = _model.secondLineCompleted;
        break;
      case 'THIRD LINE':
        isCompleted = _model.thirdLineCompleted;
        break;
      case 'JALDHI':
        isCompleted = _model.jaldhiCompleted;
        break;
      case 'HOUSI':
        isCompleted = _model.housiCompleted;
        break;
    }
    
    final isHousi = name == 'HOUSI';
    
    return GestureDetector(
      onTap: () => _handleLineButtonTap(name),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isCompleted ? Colors.grey : color,
          borderRadius: BorderRadius.circular(25),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isCompleted)
                    const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(Icons.check_circle, color: Colors.white, size: 18),
                    ),
                ],
              ),
            ),
            if (displayNumber != null)
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
}
