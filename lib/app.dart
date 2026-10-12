import 'package:flutter/material.dart';
import 'auth_gate.dart';
import 'theme/app_theme.dart';

class CampusPilotApp extends StatelessWidget {
  const CampusPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CampusPilot AI',
      theme: AppTheme.light,
      home: const AuthGate(),
    );
  }
}
