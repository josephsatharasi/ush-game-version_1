
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
import 'app_state/game_tilt/winner_screen.dart';
import 'services/app_lifecycle_service.dart';
import 'config/environment_config.dart';


void main() {
  EnvironmentConfig.printConfig();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppLifecycleService _lifecycleService = AppLifecycleService();

  @override
  void initState() {
    super.initState();
    _lifecycleService.initialize();
  }

  @override
  void dispose() {
    _lifecycleService.dispose();
    super.dispose();
  }

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
        '/winner': (context) => const WinnerScreen(),
      },
    );
  }
}