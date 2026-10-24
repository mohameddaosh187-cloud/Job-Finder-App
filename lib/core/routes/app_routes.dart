import 'package:flutter/material.dart';

import '../../features/auth/presentation/view/screens/welcome_screen.dart';
import '../../features/auth/presentation/view/screens/login_screen.dart';
import '../../features/auth/presentation/view/screens/signup_screen.dart';
import '../../features/jobs/data/api/job_api.dart';
import '../../features/jobs/presentation/view/screens/home_screen.dart';
import '../../features/jobs/presentation/view/screens/main_screen.dart';
import '../../features/jobs/presentation/view/screens/search_screen.dart';
import '../../features/jobs/presentation/view_model/home_cubit.dart';

class AppRoutes {
  AppRoutes._();

  static const String welcome = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String search = '/search';
  static const String main = '/main';

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

      case home:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => HomeScreen(
            createCubit: () => HomeCubit(JobApi()),
          ),
        );

      case search:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SearchScreen(),
        );

      case main:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MainScreen(),
        );

      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Page not found'),
            ),
          ),
        );
    }
  }
}