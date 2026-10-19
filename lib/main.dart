import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:job_finder/core/routes/app_routes.dart';
import 'package:job_finder/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const JobFinderApp());
}

class JobFinderApp extends StatelessWidget {
  const JobFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JobFinder',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F8FC),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF385CF2)),
      ),
      initialRoute: AppRoutes.welcome,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
