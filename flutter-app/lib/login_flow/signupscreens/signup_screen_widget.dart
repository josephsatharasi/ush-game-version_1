import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/backend_api_config.dart';

class SignupScreenWidget extends StatefulWidget {
  const SignupScreenWidget({super.key});

  @override
  State<SignupScreenWidget> createState() => _SignupScreenWidgetState();
}

class _SignupScreenWidgetState extends State<SignupScreenWidget> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fixed background gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0052D4),
                    Color(0xFF4364F7),
                    Color(0xFF6FB1FC),
                  ],
                ),
              ),
            ),
          ),
          // Calendar image (top right) - Red/Pink calendar
          Positioned(
            top: 80,
            right: -100,
            child: IgnorePointer(
              child: Transform.rotate(
                angle: 0.3,
                child: Image.asset(
                  'assets/images/image copy 2.png',
                  width: 300,
                  height: 300,
                ),
              ),
            ),
          ),
           Positioned(
            top: 100,
            left: -25,
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/coin13.png',
                width: 160,
                height: 160,
              ),
            ),
          ),
          // Hourglass image (left side coin 23)
          Positioned(
            top: 290,
            left: 190,
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/image copy.png',
                width: 120,
                height: 120,
              ),
            ),
          ),
          // Coin with "13" (top left)
          Positioned(
            top: 120,
            left: 0,
            child: IgnorePointer(
                child: Transform.rotate(
                angle: 0.0,
              child: Image.asset(
                'assets/images/image.png',
                width: 280,
                height: 280,
              ),
                )
            ),
          ),
          // Coin with "23" (center-bottom)
          Positioned(
            top: 60,
            left: 240,
            //MediaQuery.of(context).size.width / 2 - 45,
            child: IgnorePointer(
              child: Transform.rotate(
                angle: 0.1,
              child: Image.asset(
                'assets/images/image copy 3.png',
                width: 200,
                height: 200,
              ),
            ),
            )
          ),
      
          // Scrollable content that goes over the image
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 390),
                // Transparent to white gradient card with form
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.7),
                        Colors.white,
                      ],
                      stops: [0.0, 0.1, 0.2, 0.3],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Skip the wait.',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                           color: Color(0xFF535151),

                          ),
                        ),
                        Text(
                          'Get your ticket.',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                           color: Color(0xFF535151),

                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Create your Account',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 32),
                        // Name field
                        Text(
                          'Entre your User Name',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'Entre Your Name',
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 18),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Phone field
                        Text(
                          'Entre your phone number',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'Your Number',
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 12, right: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('🇮🇳', style: TextStyle(fontSize: 20)),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_drop_down, size: 20),
                                ],
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 18),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Password field
                        Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Create Password',
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 18),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Confirm Password field
                        Text(
                          'Conform Password',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Conform Password',
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 18),
                          ),
                        ),
                        SizedBox(height: 16),
                        // Terms checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _acceptTerms,
                              onChanged: (value) {
                                setState(() {
                                  _acceptTerms = value ?? false;
                                });
                              },
                              activeColor: Color(0xFF003D82),
                            ),
                            Expanded(
                              child: Text(
                                'Click the box to accept Terms and Conditions.',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                        // Sign In button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_nameController.text.isEmpty || _phoneController.text.isEmpty || 
                                  _passwordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Please fill all fields')),
                                );
                                return;
                              }
                              
                              if (_passwordController.text != _confirmPasswordController.text) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Passwords do not match')),
                                );
                                return;
                              }
                              
                              if (!_acceptTerms) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Please accept terms and conditions')),
                                );
                                return;
                              }
                              
                              try {
                                final result = await BackendApiConfig.register(
                                  username: _nameController.text,
                                  phone: _phoneController.text,
                                  password: _passwordController.text,
                                );
                                
                                if (mounted) {
                                  Navigator.pushNamed(context, '/otp', arguments: result['userId']);
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF003D82),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: Text(
                              'Sign IN',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Fixed Login button at top
          Positioned(
            top: 60,
            left: 24,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('Login', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          // Skip Now button at top right
          Positioned(
            top: 60,
            right: 24,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('Skip Now', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}