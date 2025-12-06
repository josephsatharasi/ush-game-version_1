import 'package:flutter/material.dart';

class OrderSuccessful extends StatefulWidget {
  const OrderSuccessful({super.key});

  @override
  State<OrderSuccessful> createState() => _OrderSuccessfulState();
}

class _OrderSuccessfulState extends State<OrderSuccessful> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/delivery-status');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFEFCF9),
      body: SafeArea(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Top-left card (partially off-screen)
            Positioned(
              top: 0,
              left: -28,
              child: Transform.rotate(
                angle: 0.30,
                child: _decorativeImage(
                  'assets/images/image copy 3.png',
                  width: size.width * 0.34,
                ),
              ),
            ),
            // Top-right coin (partially inside)
            Positioned(
              top: 56,
              right: 16,
              child: _decorativeImage(
                'assets/images/fam_coin.png',
                width: 84,
              ),
            ),
            // Bottom-left cards cluster (partially off-screen)
            Positioned(
              left: -24,
              bottom: 64,
              child: Transform.rotate(
                angle: -0.22,
                child: _decorativeImage(
                  'assets/images/image copy 2.png',
                  width: size.width * 0.58,
                ),
              ),
            ),
            // Bottom-right hourglass
            Positioned(
              right: 8,
              bottom: 68,
              child: _decorativeImage(
                'assets/images/time.png',
                width: 192,
              ),
            ),

            // Center content
            Align(
              alignment: const Alignment(0, -0.05),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Large tick image (no background decoration)
                  _decorativeImage(
                    'assets/images/tick.png',
                    width: 360,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "You're all set!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'READY TO PLAY!!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF16A34A),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
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

  Widget _decorativeImage(String asset, {double? width, double? height}) {
    return Image.asset(
      asset,
      width: width,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) => SizedBox(
        width: width,
        height: height,
      ),
    );
  }
}
