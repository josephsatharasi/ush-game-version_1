import 'package:flutter/material.dart';
import 'package:ush_app/widgets/loction_header.dart';

class AddsChipData {
  final String label;
  final Color background;
  final Color textColor;
  final Color? borderColor;

  const AddsChipData({
    required this.label,
    required this.background,
    required this.textColor,
    this.borderColor,
  });
}

class AddsFlowBaseScreen extends StatelessWidget {
  final Widget content;
  final List<AddsChipData> chips;

  const AddsFlowBaseScreen({
    super.key,
    required this.content,
    required this.chips,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: Column(
                children: [
                  _buildLocationCard(),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Center(child: content),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildChips(),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF3B82F6),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          )
        ],
      ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Location',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            SizedBox(height: 6),
            Text(
              '2-202, Visakhapatnam, Pendurthi…',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Numbers',
            style: TextStyle(
              color: Color(0xFF1E3A8A),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
    );
  }

  Widget _buildChips() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: chips
          .map(
            (chip) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: chip.background,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: chip.borderColor ?? Colors.transparent, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                chip.label,
                style: TextStyle(
                  color: chip.textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

