import 'package:flutter/material.dart';

class GameMode {
  final String title;
  final String subtitle;
  final String buttonText;
  final String coinValue;
  final List<Color> gradientColors;

  GameMode({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.coinValue,
    required this.gradientColors,
  });
}

class PlaygroundModel {
  static const String selectModeText = "Select MODE";
  
  static final List<GameMode> gameModes = [
    GameMode(
      title: "Live Game",
      subtitle: "Play with Friends, Family & Strangers",
      buttonText: "Click Here",
      coinValue: "63",
      gradientColors: [Color(0xFFFF6B35), Color(0xFFFFB347)],
    ),
    // GameMode(
    //   title: "FAM-JAM",
    //   subtitle: "Play with Friends & Family",
    //   buttonText: "Click Here",
    //   coinValue: "35",
    //   gradientColors: [Color(0xFFE91E63), Color(0xFFFF6B9D)],
    // ),
  ];
}