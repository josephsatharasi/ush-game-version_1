import 'package:flutter/material.dart';
import 'bottom_navbar_model.dart';

class BottomNavbarWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavbarWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth / BottomNavbarModel.items.length;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Curved slider indicator
          Container(
            height: 4,
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: currentIndex * itemWidth + (itemWidth - 40) / 2 - 8,
                  top: 0,
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Color(0xFF1E3A8A),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: BottomNavbarModel.items.map((item) {
                final isSelected = currentIndex == item.index;
                return GestureDetector(
                  onTap: () => onTap(item.index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/bottom_nav_icons/${item.iconPath}.png',
                        width: 20,
                        height: 20,
                        color: isSelected ? Color(0xFF1E3A8A) : Colors.grey[600],
                        errorBuilder: (context, error, stackTrace) {
                          print('Failed to load icon: ${item.iconPath}.png - Error: $error');
                          return Icon(
                            _getIconData(item.iconPath),
                            color: isSelected ? Color(0xFF1E3A8A) : Colors.grey,
                            size: 20,
                          );
                        },
                      ),
                      SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Color(0xFF1E3A8A) : Colors.grey,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          if (bottomPadding > 0)
            SizedBox(height: bottomPadding),
        ],
      ),
    );
  }

  IconData _getIconData(String iconPath) {
    switch (iconPath) {
      case 'home':
        return Icons.home;
      case 'tickets':
        return Icons.confirmation_number;
      case 'playground':
        return Icons.sports_esports;
      case 'leardboard':
        return Icons.leaderboard;
      default:
        return Icons.home;
    }
  }
}