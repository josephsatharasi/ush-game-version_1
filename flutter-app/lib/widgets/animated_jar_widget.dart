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
  Timer? _coinTimer;
  bool _showCoin = false;
  late AnimationController _coinAnimationController;
  late Animation<double> _coinAnimation;
  int _currentNumber = 0;
  StreamSubscription? _numberSubscription;
  bool _disposed = false;

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
    _numberSubscription = GameNumberService().numberStream.listen((number) {
      if (_disposed || !mounted) return;
      
      setState(() {
        _currentNumber = number;
      });
      
      // Wait for jar to complete one cycle before showing coin
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (_disposed || !mounted) return;
        
        setState(() {
          _showCoin = true;
        });
        
        _coinAnimationController.forward(from: 0).then((_) {
          if (_disposed || !mounted) return;
          _coinTimer = Timer(const Duration(milliseconds: 3000), () {
            if (_disposed || !mounted) return;
            _coinAnimationController.reverse().then((_) {
              if (_disposed || !mounted) return;
              setState(() {
                _showCoin = false;
              });
            });
          });
        });
      });
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _animationTimer?.cancel();
    _coinTimer?.cancel();
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
          if (_showCoin)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedBuilder(
                animation: _coinAnimation,
                builder: (context, child) {
                  double progress = _coinAnimation.value;
                  double scale = 0.7 + (progress * 0.3);
                  double opacity = progress < 0.15 ? progress * 6.67 : 1.0;
                  
                  return Center(
                    child: Opacity(
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
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
