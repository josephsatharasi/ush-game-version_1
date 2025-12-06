import 'package:flutter/material.dart';
import '../widgets/loction_header.dart' as widgets show AppHeader;
import '../config/backend_api_config.dart';

class GameSelectionScreen extends StatefulWidget {
  const GameSelectionScreen({super.key});

  @override
  State<GameSelectionScreen> createState() => _GameSelectionScreenState();
}

class _GameSelectionScreenState extends State<GameSelectionScreen> {
  bool _showMenu = false;
  List<dynamic> _liveGames = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGames();
  }

  Future<void> _fetchGames() async {
    try {
      final response = await BackendApiConfig.getAllGames();
      setState(() {
        _liveGames = (response['games'] as List)
            .where((game) => game['status'] == 'LIVE' || game['status'] == 'SCHEDULED')
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching games: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Unified header
              widgets.AppHeader(
                onMenuTap: () => setState(() => _showMenu = !_showMenu),
              ),
              // White content section
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Select MODE',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        SizedBox(height: 24),

                        // Games List
                        Expanded(
                          child: _isLoading
                              ? Center(child: CircularProgressIndicator())
                              : _liveGames.isEmpty
                                  ? Center(child: Text('No games available'))
                                  : ListView.builder(
                                      itemCount: _liveGames.length,
                                      itemBuilder: (context, index) {
                                        final game = _liveGames[index];
                                        return Padding(
                                          padding: EdgeInsets.only(bottom: 20),
                                          child: _buildGameCard(
                                            gradient: LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                Color(0xFFFF8A80),
                                                Color(0xFFFFB74D),
                                              ],
                                            ),
                                            title: game['gameCode'],
                                            subtitle: game['status'],
                                            coinValues: ['${game['bookedSlots']}', '${game['totalSlots']}'],
                                            isLiveGame: true,
                                            onTap: () {
                                              Navigator.pushNamed(context, '/live-gametype1');
                                            },
                                          ),
                                        );
                                      },
                                    ),
                        ),


                      
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Menu overlay
          // if (_showMenu)
          //   Positioned(
          //     top: 140,
          //     right: 24,
          //     child: Container(
          //       width: 140,
          //       decoration: BoxDecoration(
          //         color: Colors.white,
          //         borderRadius: BorderRadius.circular(12),
          //         boxShadow: [
          //           BoxShadow(
          //               color: Colors.black26,
          //               blurRadius: 10,
          //               offset: Offset(0, 4))
          //         ],
          //       ),
          //       child: Column(
          //         children: ['Settings', 'History', 'Cuppons'].map((item) {
          //           return Container(
          //             width: double.infinity,
          //             padding:
          //                 EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          //             decoration: BoxDecoration(
          //               border: Border(
          //                   bottom:
          //                       BorderSide(color: Colors.grey[300]!, width: 1)),
          //             ),
          //             child: Text(item,
          //                 style:
          //                     TextStyle(fontSize: 14, color: Colors.black87)),
          //           );
          //         }).toList(),
          //       ),
          //     ),
          //   ),
        
        ],
      ),
    );
  }

  Widget _buildGameCard({
    required Gradient gradient,
    required String title,
    required String subtitle,
    required List<String> coinValues,
    required VoidCallback onTap,
    bool isLiveGame = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 148,
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Calendar/Ticket image for Live Game (top left)
            if (isLiveGame)
              Positioned(
                top: -15,
                left: 15,
                child: Transform.rotate(
                  angle: -0.25,
                  child: Image.asset(
                    'lib/assets/images/image copy 2.png',
                    width: 100,
                    height: 100,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      );
                    },
                  ),
                ),
              ),
            // Money/Cards images for FAM-JAM
            if (!isLiveGame) ...[
              Positioned(
                bottom: 15,
                left: 25,
                child: Transform.rotate(
                  angle: -0.2,
                  child: Image.asset(
                    'assets/images/image copy.png',
                    width: 70,
                    height: 70,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 30,
                left: 80,
                child: Image.asset(
                  'assets/images/image.png',
                  width: 50,
                  height: 50,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                ),
              ),
            ],
            // Coin badges with gradient
            ...coinValues.asMap().entries.map((entry) {
              int index = entry.key;
              String value = entry.value;
              return Positioned(
                top: index == 0 ? 15 : null,
                bottom: index == 1 ? 25 : null,
                right: index == 0 ? 25 : null,
                left: index == 1 ? 110 : null,
                child: Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFC107),
                        Color(0xFFFFB300),
                        Color(0xFFFFA000),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
            // Text content
            Positioned(
              right: 20,
              top: 0,
              bottom: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 6),
                  SizedBox(
                    width: 190,
                    child: Text(
                      subtitle,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 14),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Click Here',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 6),
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.arrow_forward,
                              color: gradient.colors.first,
                              size: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
