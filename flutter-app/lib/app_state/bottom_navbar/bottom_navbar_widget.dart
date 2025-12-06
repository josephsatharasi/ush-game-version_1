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
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
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
      child: SafeArea(
        top: false,
        child: Container(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: BottomNavbarModel.items.map((item) {
              final isSelected = currentIndex == item.index;
              return GestureDetector(
                onTap: () => onTap(item.index),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getIconData(item.iconPath),
                        color: isSelected ? Color(0xFF1E3A8A) : Colors.grey,
                        size: 24,
                      ),
                      SizedBox(height: 4),
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
                ),
              );
            }).toList(),
          ),
        ),
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
      case 'leaderboard':
        return Icons.leaderboard;
      default:
        return Icons.home;
    }
  }
}