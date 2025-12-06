import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bottom_navbar/bottom_navbar_widget.dart';
import '../../widgets/loction_header.dart';
import '../playground/game_starts_countdown.dart';
import '../../services/background_music_service.dart';
import '../../config/backend_api_config.dart';
// import 'adds_flow/card_review_screen.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  int _currentIndex = 0;
  bool _showMenu = false;
  int _carouselIndex = 0;
  bool _showTicket = false;
  final PageController _pageController = PageController();
  final List<String> _carouselImages = [
    'assets/images/burgar.png',
    'assets/images/burgar.png',
    'assets/images/burgar.png',
  ];
  String _ticketNumber = '';

  @override
  void initState() {
    super.initState();
    BackgroundMusicService().play();
    _loadTicketNumber();
    Future.delayed(Duration(seconds: 3), _autoScroll);
  }

  Future<void> _loadTicketNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final cardNumber = prefs.getString('cardNumber');
    if (cardNumber != null && mounted) {
      setState(() {
        _ticketNumber = cardNumber;
      });
    }
    _checkLiveGame();
  }

  Future<void> _checkLiveGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final gameId = prefs.getString('gameId');
      
      if (token != null && gameId != null) {
        final status = await BackendApiConfig.getGameStatus(
          token: token,
          gameId: gameId,
        );
        if (mounted && status['status'] == 'LIVE') {
          // Game is live, could show notification
        }
      }
    } catch (e) {
      // Silently fail if backend not available
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args?['showTicket'] == true && !_showTicket) {
      setState(() => _showTicket = true);
      Future.delayed(Duration(seconds: 3), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => GameStartsCountdown()),
          );
        }
      });
    }
  }

  void _autoScroll() {
    if (!mounted) return;
    int nextPage = (_carouselIndex + 1) % _carouselImages.length;
    _pageController.animateToPage(
      nextPage,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    Future.delayed(Duration(seconds: 3), _autoScroll);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.45,
  
                child: Column(
                  children: [
                    AppHeader(
                      onMenuTap: () => setState(() => _showMenu = !_showMenu),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: PageView.builder(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _carouselIndex = index;
                                });
                              },
                              itemCount: _carouselImages.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 16),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(40),
                                    child: Image.asset(
                                      _carouselImages[index],
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _carouselImages.asMap().entries.map((entry) {
                              return Container(
                                width: 8,
                                height: 8,
                                margin: EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _carouselIndex == entry.key
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.4),
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.grey[100],
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GameStartsCountdown(),
                              ),
                            );
                          },
                          child: Text('Start Game', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                        ),
                        SizedBox(height: 20),
                        Expanded(
                          child: Center(
                            child: SizedBox(
                              width: 260,
                              height: 260,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // TOP‑RIGHT BIG PUZZLE
                                  Positioned(
                                    top: 80,
                                    left: -120,
                                    child: Image.asset(
                                      'assets/images/toppuzzle.png',
                                      width: 250,
                                      height: 250,
                                    ),
                                  ),
                                  // BOTTOM‑LEFT SMALL PUZZLE
                                  Positioned(
                                    top: -300,
                                    right: -225,
                                    child: Image.asset(
                                      'assets/images/downpuzzle.png',
                                      width: 450,
                                      height: 450,
                                    ),
                                  ),
                                  // CENTER PLUS BOX
                                  Positioned(
                                    top: 10,
                                    left: 80,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(context, '/game-selection');
                                      },
                                      child: Container(
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.08),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(Icons.add, size: 36),
                                      ),
                                    ),
                                  ),
                                  // TICKET OVERLAY
                                  if (_showTicket)
                                    Positioned(
                                      top: 120,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        margin: EdgeInsets.symmetric(horizontal: 20),
                                        padding: EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 10,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Image.asset(
                                              'assets/images/Ticket_way.png',
                                              height: 120,
                                              fit: BoxFit.contain,
                                            ),
                                            SizedBox(height: 12),
                                            Text(
                                              _ticketNumber.isNotEmpty ? 'Ticket: $_ticketNumber' : 'No ticket booked',
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(height: 8),
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                Clipboard.setData(ClipboardData(text: _ticketNumber));
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Ticket number copied!')),
                                                );
                                              },
                                              icon: Icon(Icons.copy, size: 16),
                                              label: Text('Copy'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color(0xFF0A3B8E),
                                                foregroundColor: Colors.white,
                                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // TICKET BANNER
                        Padding(
                          padding: const EdgeInsets.only(left: 50),
                          // child: Image.asset(
                          //   'assets/images/Ticket_way.png',
                          //   height: 60,
                          //   width: 320,
                          //   fit: BoxFit.cover,
                          // ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_showMenu)
            Positioned(
              top: 120,
              right: 24,
              child: Container(
                width: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Column(
                  children: ['Settings', 'History', 'Cuppons'].map((item) {
                    String route;
                    switch (item) {
                      case 'Settings':
                        route = '/settings';
                        break;
                      case 'History':
                        route = '/history';
                        break;
                      default:
                        route = '/coupons';
                    }
                    return InkWell(
                      onTap: () {
                        setState(() => _showMenu = false);
                        Navigator.pushNamed(context, route);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)),
                        ),
                        child: Text(item, style: TextStyle(fontSize: 14, color: Colors.black87)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomNavbarWidget(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() => _currentIndex = index);
                if (index == 1) {
                  Navigator.pushNamed(context, '/delivery-status');
                } else if (index == 2) {
                  Navigator.pushNamed(context, '/playground');
                } else if (index == 3) {
                  Navigator.pushNamed(context, '/leaderboard');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}