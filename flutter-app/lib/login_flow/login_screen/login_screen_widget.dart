import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/backend_api_config.dart';
import 'login_screen_model.dart';

class LoginScreenWidget extends StatefulWidget {
  const LoginScreenWidget({super.key});

  @override
  State<LoginScreenWidget> createState() => _LoginScreenWidgetState();
}

class _LoginScreenWidgetState extends State<LoginScreenWidget> {
  late LoginScreenModel model;

  @override
  void initState() {
    super.initState();
    
    model = LoginScreenModel();
  }

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
      
          // Scrollable content area
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 380),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.4),
                        Colors.white.withOpacity(0.75),
                        Colors.white,
                      ],
                      stops: const [0.0, 0.08, 0.18, 0.28],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        const Text(
                          'Experience the\nUsh magic!',
                          style: TextStyle(
                            fontSize: 36,
                            height: 1.15,
                            fontWeight: FontWeight.w800,
                           color: Color(0xFF535151),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'login to your Account',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF535151),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Username
                        const Text(
                          'Entre your User Name',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: model.usernameController,
                          decoration: InputDecoration(
                            hintText: 'Entre Your Username or Ph no',
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
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Password
                        const Text(
                          'Password',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: model.passwordController,
                          obscureText: model.obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Create Password',
                            filled: true,
                            fillColor: Colors.grey[200],
                            suffixIcon: IconButton(
                              icon: Icon(model.obscurePassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () {
                                setState(() => model.toggleObscure());
                              },
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
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          ),
                        ),

                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Forgot your Password ?',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (model.usernameController.text.isEmpty || model.passwordController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Please fill all fields')),
                                );
                                return;
                              }
                              
                              try {
                                final result = await BackendApiConfig.login(
                                  username: model.usernameController.text,
                                  password: model.passwordController.text,
                                );
                                
                                try {
                                  final prefs = await SharedPreferences.getInstance();
                                  await prefs.setString('token', result['token']);
                                  await prefs.setString('username', result['user']['username']);
                                  await prefs.setBool('hasRegistered', true);
                                } catch (prefsError) {
                                  print('SharedPreferences error: $prefsError');
                                }
                                
                                if (context.mounted) {
                                  Navigator.pushReplacementNamed(context, '/home');
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0A3B8E),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: const Text(
                              'log IN',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 60,
            left: 24,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('Signup', style: TextStyle(fontWeight: FontWeight.bold)),
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
