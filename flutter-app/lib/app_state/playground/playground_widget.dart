import 'package:flutter/material.dart';
import 'playground_model.dart';
import '../bottom_navbar/bottom_navbar_widget.dart';
import '../../widgets/loction_header.dart';

class PlaygroundWidget extends StatefulWidget {
  const PlaygroundWidget({super.key});

  @override
  State<PlaygroundWidget> createState() => _PlaygroundWidgetState();
}

class _PlaygroundWidgetState extends State<PlaygroundWidget> {
  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Unified header
              AppHeader(),
              // Main content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Text(
                        PlaygroundModel.selectModeText,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 30),
                      // Game mode cards
                      Expanded(
                        child: ListView.builder(
                          itemCount: PlaygroundModel.gameModes.length,
                          itemBuilder: (context, index) {
                            final gameMode = PlaygroundModel.gameModes[index];
                            return Container(
                              margin: EdgeInsets.only(bottom: 20),
                              height: 120,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: gameMode.gradientColors,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Stack(
                                children: [
                                  // Game elements background
                                  Positioned(
                                    left: 20,
                                    top: 10,
                                    child: Transform.rotate(
                                      angle: -0.2,
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.3),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: GridView.builder(
                                          padding: EdgeInsets.all(4),
                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            childAspectRatio: 1,
                                            crossAxisSpacing: 1,
                                            mainAxisSpacing: 1,
                                          ),
                                          itemCount: 9,
                                          itemBuilder: (context, i) {
                                            final numbers = ['36', '37', '3', '8', '9', '5', '1', '4', '6'];
                                            return Container(
                                              decoration: BoxDecoration(
                                                color: i < 6 ? Colors.red.withValues(alpha: 0.8) : Colors.white,
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  i < numbers.length ? numbers[i] : '',
                                                  style: TextStyle(
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                    color: i < 6 ? Colors.white : Colors.black,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Coin
                                  Positioned(
                                    top: 15,
                                    right: 20,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.amber,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4,
                                            offset: Offset(1, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          gameMode.coinValue,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Content
                                  Positioned(
                                    left: 100,
                                    top: 20,
                                    right: 80,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          gameMode.title,
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          gameMode.subtitle,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white.withValues(alpha: 0.9),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Button
                                  Positioned(
                                    bottom: 15,
                                    right: 20,
                                    child: GestureDetector(
                                      onTap: () {
                                        if (index == 1) {
                                          // FAM-JAM button - navigate to fam_playground
                                          Navigator.pushNamed(context, '/fam_playground');
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              gameMode.buttonText,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Icon(
                                              Icons.arrow_forward,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Bottom navbar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomNavbarWidget(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
                if (index == 0) {
                  Navigator.pushReplacementNamed(context, '/home');
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