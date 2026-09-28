import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/Providers/auth_provider.dart';
import 'package:movie_app/Screens/login_screen.dart';
import 'package:movie_app/Screens/home_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    switch (auth.status) {
      case AuthStatus.unknown:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      case AuthStatus.authenticated:
        return const HomeScreen();
      case AuthStatus.unauthenticated:
        return const LoginScreen();
    }
  }
}