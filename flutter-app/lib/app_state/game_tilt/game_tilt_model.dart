import 'package:flutter/material.dart';

class GameTiltModel {
  String? selectedCardType;

  final List<Map<String, dynamic>> cardTypes = [
    {'name': 'FIRST LINE', 'color': Color(0xFF1E40AF)},
    {'name': 'SECOND LINE', 'color': Color(0xFFDC2626)},
    {'name': 'THIRD LINE', 'color': Color(0xFF059669)},
    {'name': 'JALDHI', 'color': Color(0xFFF59E0B)},
    {'name': 'HOUSI', 'color': Color(0xFF9F1239)},
  ];

  void selectCardType(String type) {
    selectedCardType = type;
  }
}
