import 'package:flutter/material.dart';
import 'dart:async';
import '../services/game_number_service.dart';

class AnimatedJarWidget extends StatefulWidget {
  const AnimatedJarWidget({super.key});

  @override
  State<AnimatedJarWidget> createState() => _AnimatedJarWidgetState();
}

class _AnimatedJarWidgetState extends State<AnimatedJarWidget>
    with SingleTickerProviderStateMixin {
  int _currentJarFrame = 1;
  Timer? _animationTimer;
  bool _disposed = false;
  int _currentNumber = 0;
  bool _showCoin = false;
  late AnimationController _coinAnimationController;
  late Animation<double> _coinAnimation;
  StreamSubscription? _numberSubscription;

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
    _startJarAnimation();
    _listenToNumbers();
  }

  void _listenToNumbers() {
    // Get current number immediately
    _currentNumber = GameNumberService().currentNumber;
    
    // Listen for new numbers from main game widget
    _numberSubscription = GameNumberService().numberStream.listen((number) {
      if (_disposed || !mounted) return;
      
      setState(() {
        _currentNumber = number;
      });
      
      _showCoinAnimation();
    });
  }

  void _showCoinAnimation() {
    if (_disposed || !mounted || _showCoin || _currentNumber == 0) return;
    
    setState(() {
      _showCoin = true;
    });
    
    _coinAnimationController.reset();
    _coinAnimationController.forward().then((_) {
      if (_disposed || !mounted) return;
      
      Timer(const Duration(milliseconds: 2500), () {
        if (_disposed || !mounted) return;
        _coinAnimationController.reverse().then((_) {
          if (_disposed || !mounted) return;
          setState(() {
            _showCoin = false;
          });
        });
      });
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _animationTimer?.cancel();
    _numberSubscription?.cancel();
    _coinAnimationController.dispose();
    super.dispose();
  }

  void _startJarAnimation() {
    _currentJarFrame = 1;
    _animationTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (_disposed || !mounted) {
        timer.cancel();
        return;
      }
      if (mounted) {
        setState(() {
          _currentJarFrame = (_currentJarFrame % 6) + 1;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
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
          // Show coin with current number from backend
          if (_showCoin && _currentNumber > 0)
            AnimatedBuilder(
              animation: _coinAnimation,
              builder: (context, child) {
                double progress = _coinAnimation.value.clamp(0.0, 1.0);
                double scale = 0.1 + (progress * 0.9);
                double opacity = progress.clamp(0.0, 1.0);
                
                return Center(
                  child: Opacity(
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
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
