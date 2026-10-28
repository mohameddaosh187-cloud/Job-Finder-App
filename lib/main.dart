import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:job_finder/core/routes/app_routes.dart';
import 'package:job_finder/core/routes/theme/app_theme.dart';
import 'package:job_finder/core/routes/theme/theme_controller.dart';
import 'package:job_finder/core/routes/theme/locale_controller.dart';
import 'package:job_finder/firebase_options.dart';
import 'package:job_finder/l10n/app_localizations.dart';
import 'package:job_finder/features/auth/presentation/view/screens/welcome_screen.dart';
import 'package:job_finder/features/jobs/presentation/view/screens/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Load saved theme and language before displaying the app.
  await ThemeController.instance.loadTheme();
  await LocaleController.instance.loadLocale();

  runApp(const JobFinderApp());
}

class JobFinderApp extends StatelessWidget {
  const JobFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        ThemeController.instance,
        LocaleController.instance,
      ]),
      builder: (context, child) {
        final currentLocale = LocaleController.instance.locale;
        final currentTheme = ThemeController.instance.themeMode;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'JobFinder',

          // Light and dark themes.
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: currentTheme,

          // Arabic and English localization.
          locale: currentLocale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // Authentication and navigation.
          home: const AuthGate(),
          onGenerateRoute: AppRoutes.onGenerateRoute,
        );
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Wait for Firebase to determine the authentication state.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryBlue,
              ),
            ),
          );
        }

        // Display an error if authentication status cannot be checked.
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  Localizations.localeOf(context).languageCode == 'ar'
                      ? 'تعذر التحقق من حالة تسجيل الدخول. حاول مرة أخرى.'
                      : 'Could not check your login status. Please try again.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        // Open the main screen if the user is signed in.
        if (snapshot.data != null) {
          return const MainScreen();
        }

        // Otherwise, show the welcome screen.
        return const WelcomeScreen();
      },
    );
  }
}
