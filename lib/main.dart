import 'package:flutter/material.dart';
import 'package:kelontongku/features/pengaturan/screens/onboarding_screen.dart';

void main() {
  runApp(const KelontongKuApp());
}

class KelontongKuApp extends StatelessWidget {
  const KelontongKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KelontongKu',
      debugShowCheckedModeBanner: false,
      home: const OnboardingScreen(),
    );
  }
}
