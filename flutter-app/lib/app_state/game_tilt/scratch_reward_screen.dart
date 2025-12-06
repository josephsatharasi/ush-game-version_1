import 'package:flutter/material.dart';
import 'package:ush_app/widgets/loction_header.dart';
import '../../services/background_music_service.dart';

class ScratchRewardScreen extends StatefulWidget {
  const ScratchRewardScreen({super.key});

  @override
  State<ScratchRewardScreen> createState() => _ScratchRewardScreenState();
}

class _ScratchRewardScreenState extends State<ScratchRewardScreen> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _rewardAnimationController;
  late Animation<double> _rewardFadeAnimation;
  late Animation<double> _rewardScaleAnimation;
  
  bool _isScratched = false;
  bool _showCongratulations = false;
  bool _showBetterLuck = false;
  final String _rewardAmount = "₹500";
  final String _rewardCode = "KANUSH35";

  @override
  void initState() {
    super.initState();
    BackgroundMusicService().play();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _rewardAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );

    _rewardFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rewardAnimationController,
        curve: Curves.easeIn,
      ),
    );

    _rewardScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _rewardAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Start animation when screen appears
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _rewardAnimationController.dispose();
    super.dispose();
  }

  void _onScratchCardTapped() {
    if (!_isScratched) {
      setState(() {
        _isScratched = true;
      });
      _rewardAnimationController.forward();
    } else {
      _rewardAnimationController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _isScratched = false;
          });
          Future.delayed(Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _showCongratulations = true;
              });
              Future.delayed(Duration(seconds: 3), () {
                if (mounted) {
                  BackgroundMusicService().play();
                  Navigator.pushReplacementNamed(context, '/home');
                }
              });
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              AppHeader(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        SizedBox(height: 40),
                        // Scratch Card Area or Reward Card
                        _isScratched ? _buildRewardCard() : _buildScratchCard(),
                        SizedBox(height: 20),
                        // Text based on state
                        Text(
                          _isScratched ? "Yay! You have won $_rewardAmount" : "Scratch to get reward",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_isScratched) ...[
                          SizedBox(height: 10),
                          Text(
                            "Use the code in your KANMA wallet and this money will be added to your KANMA wallet.",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                    SizedBox(height: 30),
                    // "Tell your friends" button with share icon
                    GestureDetector(
                      onTap: () {
                        // Handle share action
                      },
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0xFF1E3A8A),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.share,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Tell your friends",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    // Radio button options
                    _buildRadioOption(
                      "Scratch to see your winning Amount",
                      false,
                    ),
                    SizedBox(height: 15),
                    _buildRadioOption(
                      "Use this Amount to Order anything you need in KANMA App",
                      false,
                    ),
                    SizedBox(height: 15),
                    _buildRadioOption(
                      "Use this CODE before 12th Dec 2025",
                      false,
                    ),
                    SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_showCongratulations) _buildCongratulationsScreen(),
        ],
      ),
    );
  }

  Widget _buildScratchCard() {
    return GestureDetector(
      onTap: _onScratchCardTapped,
      child: Container(
        width: double.infinity,
        height: 250,
        decoration: BoxDecoration(
          color: Color(0xFF1E3A8A), // Blue background
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // White "M" shape or pattern (placeholder - you can replace with actual image)
            Icon(
              Icons.card_giftcard,
              size: 120,
              color: Colors.white.withOpacity(0.3),
            ),
            // Yellow hand icon for scratching
            Positioned(
              right: 20,
              top: 20,
              child: Icon(
                Icons.touch_app,
                size: 40,
                color: Colors.amber,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardCard() {
    return GestureDetector(
      onTap: _onScratchCardTapped,
      child: FadeTransition(
        opacity: _rewardFadeAnimation,
        child: ScaleTransition(
          scale: _rewardScaleAnimation,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
            children: [
              // Confetti pattern (using emoji or icons)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🎉', style: TextStyle(fontSize: 30)),
                  SizedBox(width: 10),
                  Text('🎊', style: TextStyle(fontSize: 30)),
                  SizedBox(width: 10),
                  Text('🎈', style: TextStyle(fontSize: 30)),
                  SizedBox(width: 10),
                  Text('🎁', style: TextStyle(fontSize: 30)),
                ],
              ),
              SizedBox(height: 20),
              // Reward Amount
              Container(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  _rewardAmount,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Reward Code
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _rewardCode,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        // Copy code to clipboard
                      },
                      child: Icon(
                        Icons.copy,
                        size: 20,
                        color: Color(0xFF1E3A8A),
                      ),
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
  }

  Widget _buildRadioOption(String text, bool isSelected) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? Color(0xFF1E3A8A) : Colors.grey,
              width: 2,
            ),
            color: isSelected ? Color(0xFF1E3A8A) : Colors.transparent,
          ),
          child: isSelected
              ? Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.white,
                )
              : null,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCongratulationsScreen() {
    return Positioned.fill(
      child: Container(
        color: Colors.black,
        child: Column(
          children: [
            AppHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SizedBox(height: 40),
                      // BigBasket Image at top
                      Container(
                        width: double.infinity,
                        child: Image.asset(
                          'assets/images/bigBasket.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              child: Icon(Icons.store, size: 100, color: Colors.white),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 50),
                      // Congratulations Text below image
                      Text(
                        "Congratulations! 🎉",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 40),
                      Text(
                        "Use this code in KANMA wallet or Checkout page and claim your reward",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      // White Card with Reward
                      // Container(
                      //   width: double.infinity,
                      //   padding: EdgeInsets.all(25),
                      //   decoration: BoxDecoration(
                      //     color: Colors.white,
                      //     borderRadius: BorderRadius.circular(20),
                      //     boxShadow: [
                      //       BoxShadow(
                      //         color: Colors.black26,
                      //         blurRadius: 15,
                      //         offset: Offset(0, 6),
                      //       ),
                      //     ],
                      //   ),
                      //   child: Column(
                      //     children: [
                      //       Text(
                      //         "You won",
                      //         style: TextStyle(
                      //           fontSize: 24,
                      //           fontWeight: FontWeight.bold,
                      //           color: Colors.black87,
                      //         ),
                      //         textAlign: TextAlign.center,
                      //       ),
                      //       SizedBox(height: 10),
                      //       Text(
                      //         "₹50 Gift card",
                      //         style: TextStyle(
                      //           fontSize: 40,
                      //           fontWeight: FontWeight.bold,
                      //           color: Color(0xFF1E3A8A),
                      //         ),
                      //         textAlign: TextAlign.center,
                      //       ),
                      //       SizedBox(height: 30),
                      //       // Code with copy icon
                      //       Container(
                      //         padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      //         decoration: BoxDecoration(
                      //           color: Colors.grey[100],
                      //           borderRadius: BorderRadius.circular(15),
                      //           border: Border.all(color: Colors.grey[300]!),
                      //         ),
                      //         child: Row(
                      //           mainAxisSize: MainAxisSize.min,
                      //           children: [
                      //             Text(
                      //               _rewardCode,
                      //               style: TextStyle(
                      //                 fontSize: 20,
                      //                 fontWeight: FontWeight.w600,
                      //                 color: Colors.black87,
                      //                 letterSpacing: 2,
                      //               ),
                      //             ),
                      //             SizedBox(width: 15),
                      //             GestureDetector(
                      //               onTap: () {
                      //                 // Copy code to clipboard
                      //               },
                      //               child: Icon(
                      //                 Icons.copy,
                      //                 size: 22,
                      //                 color: Color(0xFF1E3A8A),
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //       SizedBox(height: 25),
                      //       Text(
                      //         "Use this code in KANMA wallet or Checkout page and claim your reward",
                      //         style: TextStyle(
                      //           fontSize: 14,
                      //           fontWeight: FontWeight.w400,
                      //           color: Colors.black54,
                      //         ),
                      //         textAlign: TextAlign.center,
                      //       ),
                      //     ],
                      //   ),
                      // ),
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

  Widget _buildBetterLuckScreen() {
     return Positioned.fill(
      child: Container(
        color: Colors.black,
        child: Column(
          children: [
            AppHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SizedBox(height: 40),
                      // BigBasket Image at top
                      Container(
                        width: double.infinity,
                        child: Image.asset(
                          'assets/images/nascafe.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              child: Icon(Icons.store, size: 100, color: Colors.white),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 50),
                      // Congratulations Text below image
                      Text(
                        "Better Luck Next Time! 🤞",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),

                    
                     
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
}

