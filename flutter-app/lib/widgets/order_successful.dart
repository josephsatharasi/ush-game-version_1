import 'package:flutter/material.dart';
import '../app_state/home/home_widget.dart';

class OrderSuccessful extends StatefulWidget {
  const OrderSuccessful({super.key});

  @override
  State<OrderSuccessful> createState() => _OrderSuccessfulState();
}

class _OrderSuccessfulState extends State<OrderSuccessful> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFEFCF9),
      body: SafeArea(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Top-left coin 23
            Positioned(
              top: -40,
              left: 10,
              child: _decorativeImage(
                'assets/images/coin 23.png.png',
                width: 100,
              ),
            ),
            // Top-right coin 13
            Positioned(
              top: 30,
              right: -30,
              child: _decorativeImage(
                'assets/images/coin13.png',
                width: 100,
              ),
            ),

            // Center content
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Green tick circle
                  Center(
                    child: _decorativeImage(
                      'assets/images/tick.png',
                      width: 320,
                      height: 180,
                    ),
                  ),
                  
                  // YOUR ORDER PLACED text
                  const Text(
                    'YOUR ORDER\nPLACED',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // You're all set!
                  const Text(
                    "You're all set!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  
                  // READY TO PLAY!!
                  const Text(
                    'READY TO PLAY!!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF16A34A),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      
                    ),
                  ),

                  
                  // Nescafe image
                    const SizedBox(height: 20),
                  _decorativeImage(
                    'assets/images/coffee.png',
                    width: size.width * 0.7,
                  ),
                  const SizedBox(height: 40),
                  
                  // Go back to Home button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeWidget(),
                              settings: RouteSettings(arguments: {'showTicket': true}),
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1E3A8A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          'Go back to Home',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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
