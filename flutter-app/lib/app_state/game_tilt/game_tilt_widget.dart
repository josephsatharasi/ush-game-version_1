import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'game_tilt_model.dart';
import '../../widgets/loction_header.dart';

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
  bool _showCoin = false;
  late AnimationController _coinAnimationController;
  late Animation<double> _coinAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  int _currentNumber = 0;

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
    _startAnimation();
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
    _coinAnimationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startAnimation() {
    _currentJarFrame = 1;
    _playInitialJarShake();
  }

  void _playInitialJarShake() {
    _audioPlayer.play(AssetSource('audios/jar_shaking.mp3'));
    int frameCount = 0;
    _animationTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      setState(() {
        _currentJarFrame = (_currentJarFrame % 6) + 1;
        frameCount++;
        
        if (frameCount >= 6) {
          timer.cancel();
          _audioPlayer.stop();
          _showCoinPop();
        }
      });
    });
  }

  void _showCoinPop() {
    // Generate new number only if current is 0
    if (_currentNumber == 0) {
      _currentNumber = Random().nextInt(90) + 1;
    }
    
    setState(() {
      _showCoin = true;
    });
    
    _coinAnimationController.forward(from: 0).then((_) {
      _flutterTts.speak(_currentNumber.toString());
      Timer(const Duration(seconds: 4), () {
        _coinAnimationController.reverse().then((_) {
          setState(() {
            _showCoin = false;
          });
          // Don't repeat - stop after one cycle
        });
      });
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        // Numbers button
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/fam-playground', arguments: 'FIRST LINE');
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
                          // Coin Pop Animation (zooms from jar to center)
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
        ],
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
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 250,
                  height: 250,
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                );
              },
            ),
            Text(
              _currentNumber.toString(),
              style: const TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 10,
                    offset: Offset(2, 2),
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

  Widget _buildCardButtonWithNumber(String name, Color color, String number) {
    final isSelected = _model.selectedCardType == name;
    return GestureDetector(
      onTap: () {
        setState(() {
          _model.selectCardType(name);
        });
        // Navigate with current number
        if (name == 'FIRST LINE') {
          Navigator.pushNamed(context, '/game-tilt-first', arguments: _currentNumber);
        } else if (name == 'SECOND LINE') {
          Navigator.pushNamed(context, '/game-tilt-second', arguments: _currentNumber);
        } else if (name == 'THIRD LINE') {
          Navigator.pushNamed(context, '/game-tilt-third', arguments: _currentNumber);
        } else if (name == 'JALDHI') {
          Navigator.pushNamed(context, '/game-tilt-jaldhi', arguments: _currentNumber);
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
            Positioned(
              left: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: Text(
                  number,
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
