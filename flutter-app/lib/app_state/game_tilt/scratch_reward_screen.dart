import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ush_app/widgets/loction_header.dart';
import '../../services/background_music_service.dart';
import '../../config/backend_api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scratcher/scratcher.dart';

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
  bool _isLoading = true;
  Map<String, dynamic>? _couponData;
  String _rewardAmount = "";
  String _rewardCode = "";
  bool _hasWon = false;

  @override
  void initState() {
    super.initState();
    BackgroundMusicService().play();
    _fetchCouponData();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    _animationController.repeat(); // Repeat the hand gesture animation

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

  Future<void> _fetchCouponData() async {
    try {
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('🎁 SCRATCH SCREEN: Loading coupon data');
      
      final prefs = await SharedPreferences.getInstance();
      
      // First try to get coupon from SharedPreferences (saved during claim-win)
      final savedCouponCode = prefs.getString('wonCouponCode');
      final savedCouponValue = prefs.getInt('wonCouponValue') ?? 0;
      
      debugPrint('🎁 SCRATCH SCREEN: Checking SharedPreferences');
      debugPrint('🎁 SCRATCH SCREEN: Saved Coupon Code = $savedCouponCode');
      debugPrint('🎁 SCRATCH SCREEN: Saved Coupon Value = ₹$savedCouponValue');
      
      if (savedCouponCode != null && savedCouponCode.isNotEmpty && savedCouponCode != 'NO_CODE') {
        // Use saved coupon data
        debugPrint('✅ SCRATCH SCREEN: Using coupon from SharedPreferences');
        if (mounted) {
          setState(() {
            _rewardAmount = '₹$savedCouponValue';
            _rewardCode = savedCouponCode;
            _hasWon = true;
            _isLoading = false;
          });
        }
        debugPrint('✅ SCRATCH SCREEN: Coupon loaded successfully');
        debugPrint('═══════════════════════════════════════════════════════');
        return;
      }
      
      // Fallback: Fetch from API if not in SharedPreferences
      debugPrint('🔄 SCRATCH SCREEN: No saved coupon, fetching from API');
      final token = prefs.getString('token');
      final gameId = prefs.getString('gameId');
      
      if (token == null || gameId == null) {
        debugPrint('❌ SCRATCH SCREEN: Missing credentials - token=$token, gameId=$gameId');
        throw Exception('Missing credentials');
      }
      
      debugPrint('📤 SCRATCH SCREEN: Calling getMyCoupons API');
      final response = await BackendApiConfig.getMyCoupons(token: token);
      final List<dynamic> couponsJson = response['coupons'] ?? [];
      
      debugPrint('📥 SCRATCH SCREEN: Received ${couponsJson.length} coupons');
      
      // Filter coupons for current game with ASSIGNED status
      final gameCoupons = couponsJson.where((c) => 
        c['gameId'] == gameId && c['status'] == 'ASSIGNED'
      ).toList();
      
      debugPrint('🎯 SCRATCH SCREEN: Found ${gameCoupons.length} coupons for current game');
      
      if (gameCoupons.isNotEmpty) {
        final coupon = gameCoupons.first;
        final couponCode = coupon['couponCode'];
        final couponValue = coupon['couponValue'] ?? 0;
        
        debugPrint('✅ SCRATCH SCREEN: Coupon found - Code=$couponCode, Value=₹$couponValue');
        
        if (mounted) {
          setState(() {
            _rewardAmount = '₹$couponValue';
            _rewardCode = couponCode ?? 'NO_CODE';
            _hasWon = true;
            _isLoading = false;
          });
        }
      } else {
        debugPrint('⚠️ SCRATCH SCREEN: No coupon found for this game');
        if (mounted) {
          setState(() {
            _rewardAmount = '₹0';
            _rewardCode = 'NO_CODE';
            _hasWon = false;
            _isLoading = false;
          });
        }
      }
      debugPrint('═══════════════════════════════════════════════════════');
    } catch (e) {
      debugPrint('❌❌❌ SCRATCH SCREEN ERROR: $e');
      debugPrint('═══════════════════════════════════════════════════════');
      if (mounted) {
        setState(() {
          _rewardAmount = '₹0';
          _rewardCode = 'NO_CODE';
          _hasWon = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _rewardAnimationController.dispose();
    super.dispose();
  }

  void _onScratchComplete() {
    if (!_isScratched && !_isLoading) {
      setState(() {
        _isScratched = true;
      });
      _rewardAnimationController.forward();
      
      // Show result after animation
      Future.delayed(Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            if (_hasWon) {
              _showCongratulations = true;
            } else {
              _showBetterLuck = true;
            }
          });
          
          // Auto navigate after showing result
          Future.delayed(Duration(seconds: 6), () {
            if (mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            }
          });
        }
      });
    }
  }

  void _copyCouponCode() {
    Clipboard.setData(ClipboardData(text: _rewardCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Coupon code copied!')),
    );
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
                        // Loading or Scratch Card Area or Reward Card
                        _isLoading 
                          ? _buildLoadingCard()
                          : _isScratched 
                            ? _buildRewardCard() 
                            : _buildScratchCard(),
                        SizedBox(height: 20),
                        // Text based on state
                        // Text(
                        //   _isLoading 
                        //     ? "Loading your reward..."
                        //     : _isScratched 
                        //       ? (_hasWon ? "Yay! You have won $_rewardAmount" : "Better luck next time!")
                        //       : "Scratch with your finger to reveal reward",
                        //   style: TextStyle(
                        //     fontSize: 18,
                        //     fontWeight: FontWeight.w500,
                        //     color: Colors.black87,
                        //   ),
                        //   textAlign: TextAlign.center,
                        // ),
                        if (_isScratched && _hasWon) ...[
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
          if (_showBetterLuck) _buildBetterLuckScreen(),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF1E3A8A)),
            SizedBox(height: 16),
            Text(
              'Preparing your reward...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScratchCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Scratcher(
        brushSize: 40,
        threshold: 50,
        color: Color(0xFF1E3A8A),
        onChange: (value) {
          debugPrint('Scratch progress: $value%');
        },
        onThreshold: () {
          debugPrint('Threshold reached!');
          _onScratchComplete();
        },
        child: Container(
          width: double.infinity,
          height: 250,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🎉', style: TextStyle(fontSize: 30)),
                  SizedBox(width: 10),
                  Text('🎊', style: TextStyle(fontSize: 30)),
                  SizedBox(width: 10),
                  Text('🎈', style: TextStyle(fontSize: 30)),
                ],
              ),
              SizedBox(height: 20),
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _rewardCode,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardCard() {
    return FadeTransition(
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
                      onTap: _copyCouponCode,
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

