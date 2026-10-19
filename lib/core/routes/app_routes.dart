import 'package:flutter/material.dart';

import '../../features/auth/presentation/view/screens/welcome_screen.dart';
import '../../features/auth/presentation/view/screens/login_screen.dart';
import '../../features/auth/presentation/view/screens/signup_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String welcome = '/';
  static const String login = '/login';
  static const String signup = '/signup';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const WelcomeScreen(),
        );

      case login:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );

      case signup:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SignUpScreen(),
        );

      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}
