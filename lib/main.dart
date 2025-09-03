import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_strategy/url_strategy.dart';

import 'routing/app_router.dart';

void main() async {
  // Ensure Flutter is initialized properly
  WidgetsFlutterBinding.ensureInitialized();

  // Use path-based URLs instead of hash-based
  setPathUrlStrategy();

  // Add web-specific initialization safeguard
  if (kIsWeb) {
    await Future.delayed(Duration.zero); // Allow DOM to initialize properly
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pop-up Store Generator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
      // Add performance optimizations
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}
