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
      _currentNumber = number;
      if (mounted) {
        setState(() {
          _showCoin = true;
        });
      }
      if (_disposed) return;
      _coinAnimationController.forward(from: 0).then((_) {
        if (_disposed || !mounted) return;
        _coinTimer = Timer(const Duration(seconds: 4), () {
          if (_disposed || !mounted) return;
          _coinAnimationController.reverse().then((_) {
            if (_disposed || !mounted) return;
            if (mounted) {
              setState(() {
                _showCoin = false;
              });
            }
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
    _animationTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
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
            AnimatedBuilder(
              animation: _coinAnimation,
              builder: (context, child) {
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
              },
            ),
        ],
      ),
    );
  }
}
