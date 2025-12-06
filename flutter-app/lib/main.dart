
import 'package:flutter/material.dart';

import 'login_flow/signupscreens/signup_screen_widget.dart';
import 'login_flow/signupscreens/signup_screen_model.dart';
import 'login_flow/login_screen/login_screen_widget.dart';
import 'login_flow/splash_screen/splash_screen_widget.dart';
import 'app_state/home/home_widget.dart';
import 'widgets/delivery_status_widget.dart';

import 'app_state/playground/playground_widget.dart';
import 'app_state/game_selection_screen.dart';

import 'app_state/fam_playground/fam_playground_widget.dart';
import 'app_state/live_gametype1/live_gametype1_widget.dart' as live;
import 'app_state/game_tilt/buttons/first_button/first_button_widget.dart';
import 'app_state/game_tilt/buttons/second_button/second_button_widget.dart';
import 'app_state/game_tilt/buttons/third_button/third_button_widget.dart';
import 'app_state/game_tilt/buttons/jaldhi/jaldhi_widget.dart';
import 'app_state/game_tilt/buttons/housi/housi_widget.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ush App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreenWidget(),
        '/': (context) => const SignupScreenWidget(),
        '/signup': (context) => const SignupScreenWidget(),
       '/otp': (context) => const SignupScreenModel(),

        '/login': (context) => const LoginScreenWidget(),
        '/home': (context) => const HomeWidget(),
        '/delivery-status': (context) => const DeliveryStatusWidget(),
       
        '/playground': (context) => const PlaygroundWidget(),
        '/game-selection': (context) => const GameSelectionScreen(),
       
        '/live-gametype1': (context) => const live.LiveGametype1Widget(),
        '/fam-playground': (context) => const FamPlaygroundWidget(),
        '/game-tilt-first': (context) => GameTiltFirstButtonWidget(),
        '/game-tilt-second': (context) => GameTiltSecondButtonWidget(),
        '/game-tilt-third': (context) => GameTiltThirdButtonWidget(),
        '/game-tilt-jaldhi': (context) => GameTiltJaldhiWidget(),
        '/game-tilt-housi': (context) => GameTiltHousiWidget(),
      },
    );
  }
}