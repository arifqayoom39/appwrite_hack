import 'package:flutter/material.dart';
import 'landing_screen.dart';

class LandingScreenLoader extends StatelessWidget {
  const LandingScreenLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: FutureBuilder(
        future: Future.delayed(const Duration(milliseconds: 100)), // Short delay to let Flutter settle
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return const LandingScreen();
          }
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFD366E)),
            ),
          );
        },
      ),
    );
  }
}
